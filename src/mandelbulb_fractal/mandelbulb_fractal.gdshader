shader_type canvas_item;

const vec3 light_source_vector = vec3(-1., -1., -1.);

uniform float mandelboox_space_scale = 0.1;

uniform float ratio = 1.77777777777;
uniform float scale = 1.;
uniform vec3 camPos = vec3(0., 0., -3.);
uniform vec3 camDir = vec3(0., 0., 1.);

uniform vec3 initial_z = vec3(0.);
uniform vec3 constant_c = vec3(0.5, 0.1, 0.3);

uniform float lower_bound = 0.00001;
uniform float upper_bound = 100.;
uniform float ray_march_iterations = 350;
uniform float iterations = 50;
uniform float exponent = 8.;


uniform float hit_pos_strength = 0.33;
uniform float iteratios_coloring_strength = 0.33;
uniform float lighting_strength = 0.33;
uniform float ambient_light = 0.15;

uniform vec3 bg_color = vec3(0.);
uniform bool single_color_bg = false;

uniform sampler2D gradient;
uniform float gradient_repetition = 350;
uniform float gradient_attenuation = 1.;
uniform float gradient_offset = 0.;

uniform bool julia = false;
uniform bool mandelbox = false;

uniform float mandelbox_f = 1.;
uniform float mandelbox_s = 2.;
uniform float mandelbox_r = 0.5;
uniform float mandelbox_or = 1.0;

vec3 boxFold(vec3 z){
    return clamp(z, -1.0, 1.0) * 2.0 - z;
}

vec3 sphereFold(in vec3 z, inout float dz) {
    float r2 = dot(z, z);
    float inv_r2 = inversesqrt(r2 + 1e-8);
    float r = r2 * inv_r2;

    float cond1 = step(r, mandelbox_r);
    float cond2 = step(r, mandelbox_or) * (1.0 - cond1);

    float scale1 = 4.0;
    float scale2 = 1.0 / (r2 + 1e-8);

    float s = cond1 * scale1 + cond2 * scale2 + (1.0 - cond1 - cond2);

    z *= s;
    dz *= s;

    return z;
}


// ------------------Signed Distance Functions------------------ //
float sdMandelbulb(vec3 pos) {
	vec3 z = initial_z;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < int(iterations); i++) {
		r = length(z);
		if (r < 0.0000001) {
            r = 0.0000001;
        }
		if (r>4.0) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, exponent-1.0)*exponent*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,exponent);
		theta = theta*exponent;
		phi = phi*exponent;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}

	return 0.5*log(r)*r/dr;
}

float sdJuliaMandelbulb(vec3 pos) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < int(iterations); i++) {
		r = length(z);
		if (r < 0.000001) {
            r = 0.000001;
        }
		if (r>4.0) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow(r, exponent-1.0) * exponent * dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,exponent);
		theta = theta*exponent;
		phi = phi*exponent;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z += constant_c;
	}

	return 0.5*log(r)*r/dr;
}

float sdMandelbox(vec3 pos) {
	vec3 z = initial_z;
	float s = mandelbox_s;
	vec3 c = pos;
	float dr = 1.0;
	
	for (int n = 0; n < int(iterations); n++) {
		z = mandelbox_f * boxFold(z);
		z = sphereFold(z, dr);
		z = s * z + c;
		dr = dr * abs(s) + 1.0;
	}
	
	float r = length(z);
	return r / abs(dr);
}

float sdJuliaMandelbox(vec3 pos) {
	vec3 z = pos;
	float s = mandelbox_s;
	vec3 c = constant_c;
	float dr = 1.0;
	for (int n = 0; n < int(iterations); n++) {

		z = boxFold(z);
		z = sphereFold(z, dr);
		z = s * z + c;
		dr = dr * abs(s) + 1.0;
	}
	
	float r = length(z);
	return r / abs(dr);
}

// ------------------OP Funtions------------------ //

float opUnion(in float d1, in float d2) {
	return min(d1, d2);
}

float opSubstraction(in float d1, in float d2) {
	return max(d1, -d2);
}

float opIntersection(in float d1, in float d2) {
	return max(d1, d2);
}

float opSmoothUnion(in float d1, in float d2, in float k ) {
	float h = clamp(0.5+0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) - k*h*(1.0-h);
}

float opSmoothSubtraction(in float d1, in float d2, in float k ) {
	float h = clamp(0.5-0.5*(d2+d1)/k, 0.0, 1.0);
	return mix( d1, -d2, h ) + k*h*(1.0-h);
}

float opSmoothIntersection(in float d1, in float d2, in float k ) {
	float h = clamp(0.5-0.5*(d2-d1)/k, 0.0, 1.0 );
	return mix( d2, d1, h ) + k*h*(1.0-h);
}


mat2 rot2D(float angle) {
	float s = sin(angle);
	float c = cos(angle);
	return mat2(
        vec2(c, -s),
        vec2(s,  c)
    );
}

float map(in vec3 p) {
	if (mandelbox) {
		p *= mandelboox_space_scale;
		float d = julia ? sdJuliaMandelbox(p) : sdMandelbox(p);
	
		return d / mandelboox_space_scale;
	}
	
	return julia ? sdJuliaMandelbulb(p) : sdMandelbulb(p);
}

vec3 normals(in vec3 p) {
	float e = lower_bound;
	vec2 k = vec2(1, -1);
	vec3 normals = 
		k.xyy * map(p + k.xyy * e) +
		k.yyx * map(p + k.yyx * e) +
		k.yxy * map(p + k.yxy * e) +
		k.xxx * map(p + k.xxx * e);
	return normalize(normals);
}


void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, -1.) * scale;
	float iters;
	
	vec3 camRight = normalize(cross(camDir, vec3(0.0, 1.0, 0.0)));
	vec3 camUp    = cross(camRight, camDir);

	vec3 rayDir = normalize(
    	camDir +
    	uv.x * camRight +
    	uv.y * camUp
	);
	vec3 rayPos;
	
	float t = 0.;
	bool hit = false;

	for (int i = 0; i < int(ray_march_iterations); i++) {
    	rayPos = camPos + rayDir * t;
    	float d = map(rayPos);
		
		iters = fract(float(i) / float(gradient_repetition));
	    if (d < lower_bound) {
        	hit = true;
        	break;
    	}

    	if (d > upper_bound) {
        	break;
    	}

    	t += min(2, d);
	}

	if (hit || !single_color_bg) {
    	vec3 n = normals(rayPos);
    	float dp = dot(normalize(-light_source_vector), n);
		
		iters = pow(iters, gradient_attenuation);
		iters = fract(iters + gradient_offset);
		vec3 grad_color = texture(gradient, vec2(iters, 0.)).xyz * iteratios_coloring_strength;
		
		vec3 base = (rayPos / 2. + .5) * hit_pos_strength  + grad_color * iteratios_coloring_strength;
		COLOR = vec4(max(vec3(0.), base * (ambient_light + dp * lighting_strength)), 1.);
	} else {
		COLOR = vec4(bg_color, 1.);
	}
}

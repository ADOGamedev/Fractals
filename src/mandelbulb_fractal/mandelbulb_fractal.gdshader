shader_type canvas_item;

const vec3 light_dir = normalize(vec3(-1., -1., -1.));

const float mandelboox_space_scale = 10.;

uniform float ratio = 1.77777777777;
uniform float scale = 1.;
uniform vec3 camPos = vec3(0., 0., -3.);
uniform vec3 camDir = vec3(0., 0., 1.);
uniform vec3 camRight = vec3(0., 0., 0.);
uniform vec3 camUp = vec3(0., 0., 0.);

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


// ------------------Signed Distance Functions------------------ //
float sdMandelbulb(vec3 pos) {
	vec3 z = initial_z;
	float dr = 1.0;
	float r = 0.0;
	int max_i = int(iterations);
	
	for (int i = 0; i < max_i; i++) {
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

	float lr = log(max(r,1e-6));
	return 0.5*lr*r/dr;
}

float sdJuliaMandelbulb(vec3 pos) {
	vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
	int max_i = int(iterations);
	
	for (int i = 0; i < max_i; i++) {
		r = length(z);
		if (r < 0.000001) {
            r = 0.000001;
        }
		if (r>4.0) break;
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow(r, exponent-1.0) * exponent * dr + 1.;
		
		// scale and rotate the point
		float zr = pow( r,exponent);
		theta = theta*exponent;
		phi = phi*exponent;
		
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z += constant_c;
	}
	
	float lr = log(max(r, 1e-6));
    return 0.5 * lr * r / dr;
}

float sdMandelbox(vec3 pos) {
	vec3 z = initial_z;
	float s = mandelbox_s;
	float dr = 1.0;
	float r2;
	
	float min_r2 = mandelbox_r * mandelbox_r;
    float fixed_r2 = mandelbox_or * mandelbox_or;
    int max_i = int(iterations);
	
	for (int n = 0; n < max_i; n++) {
        z = clamp(mandelbox_f * z, -1.0, 1.0) * 2.0 - mandelbox_f * z;
        
        r2 = dot(z, z);
        if (r2 > 400.0) break;
        
        float factor = fixed_r2 / clamp(r2, min_r2, fixed_r2);
        z *= factor;
        dr *= factor;
        
        z = s * z + pos;
        dr = dr * abs(s) + 1.;
	}
	
	return sqrt(r2) / abs(dr);
}

float sdJuliaMandelbox(vec3 pos) {
	vec3 z = pos;
	float s = mandelbox_s;
	float dr = 1.0;
	float r2;
	
	float min_r2 = mandelbox_r * mandelbox_r;
    float fixed_r2 = mandelbox_or * mandelbox_or;
    int max_i = int(iterations);
	
	for (int n = 0; n < max_i; n++) {
        z = clamp(mandelbox_f * z, -1.0, 1.0) * 2.0 - mandelbox_f * z;
        
       r2 = dot(z, z);
        if (r2 > 400.0) break;
        
        float factor = fixed_r2 / clamp(r2, min_r2, fixed_r2);
        z *= factor;
        dr *= factor;
        
        z = s * z + constant_c;
        dr = dr * abs(s) + 1.0;
	}
	
	return sqrt(r2) / abs(dr);
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
		float d = julia ? sdJuliaMandelbox(p) : sdMandelbox(p);
	
		return abs(d);
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
	
	vec3 camera_position = camPos * (mandelbox ? mandelboox_space_scale : 1.);
	vec3 rayDir = normalize(
    	camDir +
    	uv.x * camRight +
    	uv.y * camUp
	);
	vec3 rayPos;
	
	float t = 0.;
	bool hit = false;
	
	int max_i = int(ray_march_iterations);

	for (int i = 0; i < max_i; i++) {
    	rayPos =  camera_position + rayDir * t;
    	float d = map(rayPos);
		
		iters = fract(float(i) / float(gradient_repetition));
	    if (d < lower_bound) {
        	hit = true;
        	break;
    	}

    	if (t > upper_bound) {
        	break;
    	}

    	t += min(3., d);
	}

	if (hit || !single_color_bg) {
		float dp = 0.;
		vec3 n;
		if (hit && abs(lighting_strength) > 1e-10) {
    		n = normals(rayPos);
    		dp = dot(light_dir, n);
		}
		
		iters = pow(iters, gradient_attenuation);
		iters = fract(iters + gradient_offset);
		vec3 grad_color = texture(gradient, vec2(iters, 0.)).xyz * iteratios_coloring_strength;
		
		vec3 base = (rayPos * 0.5 + .5) * hit_pos_strength  + grad_color * iteratios_coloring_strength;
		COLOR = vec4(max(vec3(0.), base * (ambient_light + dp * lighting_strength)), 1.);
	} else {
		COLOR = vec4(bg_color, 1.);
	}
}
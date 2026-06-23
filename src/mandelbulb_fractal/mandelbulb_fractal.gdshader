shader_type canvas_item;

const vec3 light_source_vector = vec3(-1., -1., -1.);

uniform float ratio = 1.77777777777;
uniform float scale = 1.;
uniform vec3 camPos = vec3(0., 0., -3.);
uniform vec3 camDir = vec3(0., 0., 1.);

uniform vec3 initial_z = vec3(0.);
uniform vec3 constant_c = vec3(0.5, 0.1, 0.3);

uniform float lower_bound = 0.00001;
uniform float upper_bound = 100.;
uniform int ray_march_iterations = 350;
uniform int iterations = 50;
uniform float epsilon = 0.00001;
uniform float exponent = 8.;

uniform bool julia = false;

// ------------------Signed Distance Functions------------------ //
float sdSphere(in vec3 p, in float r) {
	return length(p) - r;
}

// d is half the dimension of the box, since we take the space to be simetric
float sdBox(in vec3 p, in vec3 d) {
	vec3 q = abs(p) - d;
	return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdMandelbulb(vec3 pos) {
	vec3 z = initial_z;
	float dr = 1.0;
	float r = 0.0;
	for (int i = 0; i < iterations; i++) {
		r = length(z);
		if (r < 0.000001) {
            r = 0.000001;
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
	for (int i = 0; i < iterations ; i++) {
		r = length(z);
		if (r < 0.000001) {
            r = 0.000001;
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
		z+=constant_c;
	}

	return 0.5*log(r)*r/dr;
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
	float sphere = julia ? sdJuliaMandelbulb(p) : sdMandelbulb(p);
	
	return sphere;
}

vec3 normals(in vec3 p) {
	float e = epsilon;
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
	vec3 col;
	
	vec3 camRight = normalize(cross(camDir, vec3(0.0, 1.0, 0.0)));
	vec3 camUp    = cross(camRight, camDir);

	vec3 rayDir = normalize(
    	camDir +
    	uv.x * camRight +
    	uv.y * camUp
	);
	vec3 rayPos;
	
	float t = 0.;
	vec3 hitPos;
	bool hit = false;

	for (int i = 0; i < ray_march_iterations; i++) {
    	rayPos = camPos + rayDir * t;
    	float d = map(rayPos);
		
		col = vec3(float(i) / float(ray_march_iterations));

	    if (d < lower_bound) {
        	hit = true;
			hitPos = rayPos;
        	break;
    	}

    	if (d > upper_bound) {
        	break;
    	}

    	t += d;
	}

	if (hit) {
    	vec3 n = normals(rayPos);
    	float dp = dot(normalize(-light_source_vector), n);
    	//col = vec3(0.49 * dp + 0.3);
		COLOR = vec4((hitPos / 2. + .5) * 0.8 + col * 2., 1.);
	} else {
	    col = vec3(0.0);
		COLOR = vec4(col, 1.);
	}
}

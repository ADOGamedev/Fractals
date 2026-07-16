shader_type canvas_item;

#define PHI 1.61803398874989484820

const int POLY_VERTEX_COUNT[5] = int[](4, 8, 6, 20, 12);
const int POLY_START_INDEX[5] = int[](0, 4, 12, 18, 38);

const vec3 POLYHEDRON_VERTICES[50] = vec3[](
	vec3( -1.0,  -1.0,  -1.0), 
	vec3( -1.0, 1.0, 1.0),
	vec3(1.0,  -1.0, 1.0), 
	vec3(1.0, 1.0,  -1.0),

	vec3(-0.57735, -0.57735, -0.57735), vec3( 0.57735, -0.57735, -0.57735),
	vec3( 0.57735,  0.57735, -0.57735), vec3(-0.57735,  0.57735, -0.57735),
	vec3(-0.57735, -0.57735,  0.57735), vec3( 0.57735, -0.57735,  0.57735),
	vec3( 0.57735,  0.57735,  0.57735), vec3(-0.57735,  0.57735,  0.57735),

	vec3( 1.0,  0.0,  0.0), vec3(-1.0,  0.0,  0.0),
	vec3( 0.0,  1.0,  0.0), vec3( 0.0, -1.0,  0.0),
	vec3( 0.0,  0.0,  1.0), vec3( 0.0,  0.0, -1.0),

	vec3(-0.57735, -0.57735, -0.57735), vec3( 0.57735, -0.57735, -0.57735),
	vec3( 0.57735,  0.57735, -0.57735), vec3(-0.57735,  0.57735, -0.57735),
	vec3(-0.57735, -0.57735,  0.57735), vec3( 0.57735, -0.57735,  0.57735),
	vec3( 0.57735,  0.57735,  0.57735), vec3(-0.57735,  0.57735,  0.57735),
	vec3( 0.0, -0.35682, -0.93417), vec3( 0.0,  0.35682, -0.93417),
	vec3( 0.0, -0.35682,  0.93417), vec3( 0.0,  0.35682,  0.93417),
	vec3(-0.35682, -0.93417,  0.0), vec3( 0.35682, -0.93417,  0.0),
	vec3(-0.35682,  0.93417,  0.0), vec3( 0.35682,  0.93417,  0.0),
	vec3(-0.93417,  0.0, -0.35682), vec3( 0.93417,  0.0, -0.35682),
	vec3(-0.93417,  0.0,  0.35682), vec3( 0.93417,  0.0,  0.35682),

	vec3( 0.0, -0.52573, -0.85065), vec3( 0.0,  0.52573, -0.85065),
	vec3( 0.0, -0.52573,  0.85065), vec3( 0.0,  0.52573,  0.85065),
	vec3(-0.52573, -0.85065,  0.0), vec3( 0.52573, -0.85065,  0.0),
	vec3(-0.52573,  0.85065,  0.0), vec3( 0.52573,  0.85065,  0.0),
	vec3(-0.85065,  0.0, -0.52573), vec3( 0.85065,  0.0, -0.52573),
	vec3(-0.85065,  0.0,  0.52573), vec3( 0.85065,  0.0,  0.52573)
);


const vec3 light_dir = normalize(vec3(-1., -1., -1.));

uniform int polyhedron_index = 0;

uniform float radius = 1.0;
uniform float ratio = 1.77777777777;
uniform float scale = 1.;
uniform vec3 camPos = vec3(0., 0., -3.);
uniform vec3 camDir = vec3(0., 0., 1.);
uniform vec3 camRight = vec3(0., 0., 0.);
uniform vec3 camUp = vec3(0., 0., 0.);

uniform float lower_bound = 0.00001;
uniform float upper_bound = 100.;
uniform float ray_march_iterations = 350;
uniform float iterations = 50;
uniform float exponent = 8.;

uniform bool include_center = false;
uniform bool auto_scale = false;

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

float get_scale() {
	if (!auto_scale) {
		return scale;
	}
	
	switch (polyhedron_index) {
		case 0:
			return 0.5;
		case 1:
			return 0.5;
		case 2:
			return 0.5;
		case 3:
			return 0.276393;
		case 4:
			return 0.381966;
	}
}

vec3 inverse_child_transform(in vec3 p, in int index, in int k, in float R, in float r) {
	vec3 v = POLYHEDRON_VERTICES[POLY_START_INDEX[index] + k];
	vec3 offset = v * (R - R*r);
	
	return (p - offset) / r;
}

// ------------------Signed Distance Functions------------------ //
float sdRegularPolyhedron(vec3 p, int index, float r) {
    if (index == 0) {
        p.xy = (p.x + p.y < 0.0) ? -p.yx : p.xy;
        p.xz = (p.x + p.z < 0.0) ? -p.zx : p.xz;
        p.yz = (p.y + p.z < 0.0) ? -p.zy : p.yz;
        return (p.x + p.y + p.z - r) * 0.577350269;
    }
    
    if (index == 1) {
        vec3 d = abs(p) - vec3(r);
        return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
    }
    
    if (index == 2) {
        p = abs(p);
        return (p.x + p.y + p.z - r) * 0.577350269;
    }
    
    if (index == 3) {
        p = abs(p);
        vec3 n = normalize(vec3(PHI, 1.0, 0.0));
        float d = dot(p, n);
        
        d = max(d, dot(p.yzx, n));
        d = max(d, dot(p.zxy, n));
        return d - r;
    }
    
    if (index == 4) {
        p = abs(p);
        
        const vec3 n1 = normalize(vec3(2.61803398875, 1.0, 0.0));
        
        const float n2 = 0.57735026919; 
        
        float a = dot(p, n1.xyz);
        float b = dot(p, n1.zxy);
        float c = dot(p, n1.yzx);
        float d = dot(p, vec3(n2)); 
        
        return max(max(max(a, b), c), d) - r;
    }

    return 0.0;
}

float sdSierpinskiPolyhedron(in vec3 p, in int index) {
	float real_scale = get_scale();
	float s = 1.0;
	float d = 0.0;
	
	for (int i = 0; i < int(iterations); i++) {
		
		vec3 best_child = p;
		float best_length = 1e20;
		
		for (int k = 0; k < POLY_VERTEX_COUNT[index]; k++) {
			vec3 child = inverse_child_transform(p, index, k, radius, real_scale);
			float dist = sdRegularPolyhedron(child, index, radius);
			
			if (length(child) < best_length) {
				best_length = length(child);
				best_child = child;
				d = dist;
			}
			
		}
		
		if (include_center) {
			vec3 child = p / real_scale;
			float dist = sdRegularPolyhedron(child, index, radius);
			
			if (length(child) < best_length) {
				best_length = length(child);
				best_child = child;
				d = dist;
			}
		}
		
		p = best_child;
		s *= real_scale;
	}
	
	d = sdRegularPolyhedron(p, index, radius) * s;
	return d;
}


float map(in vec3 p) {
	return sdSierpinskiPolyhedron(p, polyhedron_index);
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
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, -1.);
	float iters;
	
	vec3 camera_position = camPos;
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

    	t += d;
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
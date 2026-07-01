shader_type canvas_item;

const float ratio = 1.777777777;

uniform float iterations = 5;
uniform float sides = 6;
uniform float scale = 0.5;
uniform float radius = 0.4;
uniform bool include_center = false;

uniform bool auto_scale = false;

uniform bool negative_space = false;
uniform bool color_by_position = false;
uniform bool color_by_iterations = false;
uniform bool color_by_overlap = false;

uniform vec4 bg_color : source_color = vec4(vec3(0.), 1.);
uniform vec4 color : source_color = vec4(1.);

uniform sampler2D gradient;
uniform float gradient_repetition = 7;
uniform float gradient_attenuation = 1.;


float get_scale() {
	if (!auto_scale) {
		return scale;
	}
	
	float s = 1.;
	int limit = int(floor(float(sides) / 4.));
	
	for (int k = 1; k <= limit; k++) {
		s += cos(2. * PI * float(k) / float(sides));
	}
	s *= 2.;
	return 1. / s;
}

vec2 rotate(in vec2 p, in float angle) {
    float c = cos(angle);
    float s = sin(angle);

    return vec2(
        c * p.x - s * p.y,
        s * p.x + c * p.y
    );
}

bool is_inside_regular_polygon(in vec2 p, in float r, in float n) {
	float delta = 2. * PI / float(n);
	float ap = r * cos(delta / 2.);
	
	float angle = atan(p.y, p.x);
	float sector = mod(angle, delta);
	
	float proj = length(p) * cos(delta / 2. - sector);
	
	return proj < ap;
}

vec2 inverse_child_transform(in vec2 p, in int k, in float r, in float R) {
	float angle = float(k) * 2. * PI / float(sides);
	vec2 v = vec2(cos(angle), sin(angle));
	vec2 offset = v * (R - R*r);
	
	return (p - offset) / r;
}

float n_flake(in vec2 p) {
	float s = get_scale();
	
	float overlap_accum = 0.0;
	for (int i = 0; i < int(iterations); i++) {
		bool hit = false;
		
		int overlaps = 0;
        for (int k = 0; k < int(sides); k++) {
            vec2 child_test = inverse_child_transform(p, k, s, radius);
            if (is_inside_regular_polygon(child_test, radius, sides)) {
                overlaps++;
            }
        }
		
        if (overlaps > 1) {
            overlap_accum += float(overlaps - 1);
        }
		
		
		if (include_center) {
			vec2 center = p / s;
			if (is_inside_regular_polygon(center, radius, sides)) {
				p = center;
				hit = true;
			}
		}
		
		float best_dist = 1e20;
		bool found = false;
		vec2 best_child;
		
		for (int k = 0; k < int(sides); k++) {
			vec2 child = inverse_child_transform(p, k, s, radius);
			if (i == 0) {
				child = p;
			}
			
			if (is_inside_regular_polygon(child, radius, sides)) {
        		float d = length(child);

        		if (d < best_dist) {
            		best_dist = d;
            		best_child = child;
            		found = true;
        		}
			}
		}
		
		if (found) {
    		p = best_child;
    		hit = true;
		}
		
		if (!hit) {
			if (color_by_iterations) {
				return fract(float(i) / gradient_repetition);
			}
			return 0.;
		}
	}
	
	if (color_by_overlap) {
		return fract(float(overlap_accum) / gradient_repetition);
	}
	return 1.;
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, 1.);
	vec2 prev_uv = uv;
	uv = rotate(uv, radians(90));
	
	if (!is_inside_regular_polygon(uv, radius, sides)) {
		COLOR = bg_color;
	}
	else {
		float f = n_flake(uv);
		if (negative_space) {
			f = 1. - f;
		}
		float hue = (atan(prev_uv.y, prev_uv.x) + PI) / (2. * PI);
		
		if (color_by_iterations || color_by_overlap) {
			f = pow(f, gradient_attenuation);
			COLOR = texture(gradient, vec2(f, 0.));
		}
		else if (color_by_position) {
			COLOR = vec4(f * hsv_to_rgb(vec3(hue, 0.5, 1.)), 1.);
		} else {
			COLOR = mix(bg_color, color, f);
		}
	}
}


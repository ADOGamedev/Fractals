shader_type canvas_item;

const float ratio = 1.777777777;

uniform int iterations = 5;
uniform int sides = 6;
uniform float scale = 0.5;
uniform float radius = 0.4;
uniform bool include_center = false;

vec2 rotate(in vec2 p, in float angle) {
    float c = cos(angle);
    float s = sin(angle);

    return vec2(
        c * p.x - s * p.y,
        s * p.x + c * p.y
    );
}

bool is_inside_regular_polygon(in vec2 p, in float r, in int n) {
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
	for (int i = 0; i < iterations; i++) {
		bool hit = false;
		
		if (include_center) {
			vec2 center = p / scale;
			if (is_inside_regular_polygon(center, radius, sides)) {
				p = center;
				hit = true;
			}	
		}
		
		for (int k = 0; k < sides; k++) {
			vec2 child = inverse_child_transform(p, k, scale, radius);
			
			if (is_inside_regular_polygon(child, radius, sides)) {
				p = child;
				hit = true;
				break;
			}
		}
		
		if (!hit) {
			return 0.;
		}
	}
	
	return 1.;
}

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, 1.);
	uv = rotate(uv, radians(90));
	
	COLOR = vec4(vec3(n_flake(uv)), 1.);
}


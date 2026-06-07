shader_type canvas_item;

uniform float ratio = 1.7777777777777;
uniform float scale = 0.35;
uniform int iterations = 2;

vec4 fractal(in vec2 p) {
	
	for (int i = 0; i < iterations; i++) {
		p.x = fract(p.x);
		p.y = fract(p.y);
		if (p.x < 1.0 && p.y < 1.0 && p.x + p.y > 1.0) {
			return vec4(0.0);
		}
		p *= 2.0;
	}
	
	return vec4(1.0);
}

void fragment() {
	vec2 uv = (UV - vec2(0.5, 0.5)) / scale;
	uv *= vec2(ratio * sqrt(3) / 2., 1.0);
	uv += vec2(0.5);
	
	uv.y = 1.0 - uv.y;
	uv.x -= uv.y / 2.0;
	
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0);
	}
	else {
		COLOR = fractal(uv);
	}
}

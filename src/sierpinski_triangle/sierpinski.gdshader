shader_type canvas_item;

uniform float ratio = 1.7777777777777;
uniform float scale = 0.35;
uniform int iterations = 7;

uniform bool negative_space = false;
uniform bool color_by_position = false;
uniform bool color_by_iterations = false;

uniform vec4 bg_color : source_color = vec4(vec3(0.), 1.);
uniform vec4 color : source_color = vec4(1.);

uniform sampler2D gradient;
uniform float gradient_repetition = 7;
uniform float gradient_attenuation = 1.;

float fractal(in vec2 p) {
	for (int i = 0; i < iterations; i++) {
		p = fract(p);
		if (p.x + p.y > 1.0) {
			if (color_by_iterations) {
				return fract(float(i) / float(gradient_repetition));
			}
			return 0.;
		}
		p *= 2.0;
	}
	
	return 1.;
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

void fragment() {
	vec2 uv = (UV - vec2(0.5, 0.5)) / scale;
	
	uv *= vec2(ratio * sqrt(3) / 2., 1.0);
	vec2 prev_uv = uv - vec2(0., scale * 1. / 4.);
	
	uv += vec2(0.5);
	
		
	uv.y = 1.0 - uv.y;
	uv.x -= uv.y / 2.0;
	
	if (uv.x < 0.0 || uv.y < 0.0 || uv.x + uv.y > 1.) {
		COLOR = bg_color;
	}
	else {
		float f = fractal(uv);
		if (negative_space) {
			f = 1. - f;
		}
		float hue = (atan(prev_uv.y, prev_uv.x) + PI) / (2. * PI);
		
		if (color_by_iterations) {
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

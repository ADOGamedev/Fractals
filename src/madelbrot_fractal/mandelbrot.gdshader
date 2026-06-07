shader_type canvas_item;

const float pi = 3.141592653589793238;
const float phi = 1.618033988749;
uniform float ratio = 1.77777777777777777777777777777;
uniform int iterations = 300;
uniform float scale = 0.4;
uniform sampler2D gradient;
uniform vec4 set_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_attenuation = 0.8;
uniform float gradient_repetition = 400;
uniform vec2 offset = vec2(0.5, 0.0);
uniform vec2 exponent = vec2(2.0, 0.0);

uniform vec2 constant_c = vec2(0.5);
uniform vec2 initial_z = vec2(0.0);
uniform bool julia = false;
uniform bool burning_ship = false;
uniform bool rings_fractal = false;

uniform bool smooth_grad = true;

vec2 complex_sqr(in vec2 z) {
	return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

vec2 complex_ln(in vec2 z) {
    float r = length(z);
    if (r == 0.0) return vec2(-1e20, 0.0);
    return vec2(log(r), atan(z.y, z.x));
}

vec2 complex_mul(in vec2 z, in vec2 w) {
	return vec2(z.x * w.x - z.y * w.y, z.x * w.y + z.y * w.x);
}


vec2 complex_exp(in vec2 z) {
	return exp(z.x) * vec2(cos(z.y), sin(z.y));
}

vec2 complex_pow(in vec2 z, in vec2 x) {
	return complex_exp(complex_mul(x, complex_ln(z)));
}

vec2 complex_div(in vec2 z, in vec2 w) {
	return complex_mul(z, complex_pow(w, vec2(-1., 0.0)));
}

float get_point_scape_iterations(in vec2 z, in vec2 c) {
	vec2 current_number = vec2(z);
	
	bool is_default_exp = abs(exponent.x - 2.0) < 1e-4 && abs(exponent.y) < 1e-4;
	
	for (int i = 0; i < iterations; i++) {
		float threshold = is_default_exp ? 2.0 : 100.0;
		if (length(current_number) > threshold) {
			if (!smooth_grad) {
				return float(i);
			}
			return float(i) + 1.0 - log(log(length(current_number))) / log(2);
		}
		
		
		if (rings_fractal) {
			vec2 z_pow = is_default_exp ? complex_sqr(current_number) : complex_pow(current_number, exponent);
			vec2 numerator = complex_mul(
		    	complex_mul(z_pow, z_pow + c),
    			complex_exp(vec2(0.0, 2.0 * pi * phi))
			);
			vec2 denominator = complex_mul(c, z_pow) + vec2(1.0, 0.0);
			current_number = complex_div(numerator, denominator);
		}
		else if (burning_ship) {
	    	current_number = (is_default_exp ? complex_sqr(abs(current_number)) : complex_pow(abs(current_number), exponent)) + c;
		}
		else {
    		current_number = (is_default_exp ? complex_sqr(current_number) : complex_pow(current_number, exponent)) + c;
		}
		
	}
	
	return -1.0;
}


void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, 1.0) / scale - offset;

	float scape_iterations = julia ? get_point_scape_iterations(uv, constant_c) : get_point_scape_iterations(initial_z, uv);
	
	if (scape_iterations < 0.0) {
		COLOR = set_color;
	}
	else {
		float gradient_value = fract(scape_iterations / float(gradient_repetition));
		COLOR = texture(gradient, vec2(pow(gradient_value, gradient_attenuation), 0.0));
	}
}



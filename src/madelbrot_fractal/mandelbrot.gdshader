shader_type canvas_item;

const float pi = 3.141592653589793238;
const float phi = 1.618033988749;
uniform float ratio = 1.77777777777777;

uniform int iterations = 300;
uniform float scale = 0.4;
uniform sampler2D gradient;
uniform vec4 set_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float gradient_attenuation = 0.8;
uniform float gradient_repetition = 400;
uniform vec2 offset = vec2(0.5, 0.0);
uniform vec2 exponent = vec2(2.0, 0.0);

uniform float threshold = 10.0;

uniform vec2 constant_c = vec2(0.5);
uniform vec2 initial_z = vec2(0.0);
uniform bool julia = false;

uniform bool burning_ship = false;
uniform bool rings_fractal = false;


uniform bool smooth_grad = true;
uniform bool gradient_mapping = false;
uniform bool glow_rainbow = false;
uniform bool color_inside = false;

vec2 complex_sqr(in vec2 z) {
	return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

vec2 complex_ln(in vec2 z) {
    float r = length(z);
    if (r == 0.0) return vec2(-1e20, 0.0);
    return vec2(log(r), atan(z.y, z.x));
}

vec2 complex_log_base(in vec2 b, in vec2 z) {
	return complex_ln(z) / complex_ln(b);
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

vec2 complex_cos(vec2 z) {
    return vec2(cos(z.x) * cosh(z.y), -sin(z.x) * sinh(z.y));
}

float get_point_scape_iterations(in vec2 z, in vec2 c, in int iters) {
	vec2 current_number = vec2(z);
	
	bool is_default_exp = abs(exponent.x - 2.0) < 1e-4 && abs(exponent.y) < 1e-4;
	
	for (int i = 0; i < iters; i++) {
		if (length(current_number) > threshold) {
			if (!smooth_grad) {
				return float(i);
			}
			float first_log = log(length(current_number)) / log(threshold);
			vec2 smooth_i = float(i) + 1.0 - complex_log_base(exponent, vec2(first_log, 0.0));
			return smooth_i.x;
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
	
	if (color_inside) {
		return log(length(current_number) + 1.0) * float(iters);
	}
	else {
		return -1.;
	}
}

vec2 get_gradient(in vec2 z, in vec2 c, in int iters) {
	float h = 0.000005;
	float fx1 = julia
		? get_point_scape_iterations(z - vec2(h, 0.0), c, iters)
		: get_point_scape_iterations(z, c - vec2(h, 0.0), iters);
	float fy1 = julia
		? get_point_scape_iterations(z - vec2(0.0, h), c, iters)
		: get_point_scape_iterations(z, c - vec2(0.0, h), iters);
	float fx2 = julia
		? get_point_scape_iterations(z + vec2(h, 0.0), c, iters)
		: get_point_scape_iterations(z, c + vec2(h, 0.0), iters);
	float fy2 = julia
		? get_point_scape_iterations(z + vec2(0.0, h), c, iters)
		: get_point_scape_iterations(z, c + vec2(0.0, h), iters);
	
	return vec2((fx1 - fx2) / (2.0*h), (fy1 - fy2) / (2.0*h));
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, 1.0) / scale - offset;

	float scape_iterations = julia ? get_point_scape_iterations(uv, constant_c, iterations) : get_point_scape_iterations(initial_z, uv, iterations);
	
	if (scape_iterations < 0.0) {
		COLOR = set_color;
	}
	else if (gradient_mapping) {
	    vec2 grad = julia ? 
	        get_gradient(uv, constant_c, iterations) :
	        get_gradient(initial_z, uv, iterations);
		
		float mag = log(pow(length(grad), 1./gradient_attenuation));
		if (!glow_rainbow) {
			mag = 1. - mag;
		}
		
		grad = normalize(grad);
		
		float angle = atan(grad.y, grad.x) / (2.*pi) + 0.25;
		float cicles = float(iterations) / gradient_repetition;
		angle = fract(angle * cicles);
		if (!glow_rainbow) {
			angle = 1. - angle;
		}
		
	    COLOR = vec4(hsv_to_rgb(vec3(angle, 0.5, mag)), 1.0);
	}
	else {
		float gradient_value = fract(scape_iterations / float(gradient_repetition));
		COLOR = texture(gradient, vec2(pow(gradient_value, gradient_attenuation), 0.0));
	}
}



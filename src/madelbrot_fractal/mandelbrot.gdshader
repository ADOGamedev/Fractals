shader_type canvas_item;

uniform float ratio = 1.77777777777777777777777777777;
uniform int iterations = 300;
uniform float scale = 2.0;
uniform sampler2D gradient;
uniform float gradient_attenuation = 0.8;
uniform vec2 offset = vec2(0.5, 0.0);
uniform float exponent = 2.0;

vec2 complex_sqr(in vec2 z) {
	return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
}

vec2 complex_pow(in vec2 z, in float x) {
    float r = length(z);
    float theta = atan(z.y, z.x);
    
    float r_pow = pow(r, x);
    float theta_mult = theta * x;
    
    return vec2(
        r_pow * cos(theta_mult),
        r_pow * sin(theta_mult)
    );
}


int get_point_scape_iterations(in vec2 p) {
	vec2 current_number = vec2(0.0);
	
	for (int i = 0; i < iterations; i++) {
		if (length(current_number) > 2.0) {
			return i;
		}
		
		current_number = (exponent == 2.0 ? complex_sqr(current_number) : complex_pow(current_number, exponent)) + p;
	}
	
	return -1;
}


void fragment() {
	vec2 uv = (UV - vec2(0.5)) * vec2(ratio, 1.0) * scale - offset;

	int scape_iterations = get_point_scape_iterations(uv);
	
	float gradient_value = clamp(float(scape_iterations) / float(iterations), 0.0, 1.0);
	COLOR = texture(gradient, vec2(pow(gradient_value, gradient_attenuation)));
}



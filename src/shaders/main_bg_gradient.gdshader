shader_type canvas_item;

uniform float speed = 0.1;
uniform float intensity = 1.0;
uniform float scale = 1.0;
uniform float contrast = 1.0;

uniform sampler2D gradient;

float pattern(vec2 uv) {
    float t = TIME * speed;

    float a = sin((uv.x + t) * 6.28318);
    float b = sin((uv.y - t) * 6.28318);
    float c = sin((uv.x + uv.y + t * 0.5) * 6.28318);
    float d = cos((uv.x - uv.y - t * 0.7) * 6.28318);

    return (a + b + c + d) * 0.25;
}

void fragment() {
    vec2 uv = UV * scale;

    float p = pattern(uv);

    float gray = p * 0.5 + 0.5;
    gray = pow(gray, contrast);

    gray *= intensity;

    COLOR = vec4(texture(gradient, vec2(gray, 0.)).xyz, 1.0);
}
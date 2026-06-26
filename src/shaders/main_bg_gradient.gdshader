shader_type canvas_item;

uniform float speed = 0.1;
uniform float intensity = 0.25;
uniform float scale = 1.0;
uniform float saturation = 0.5;
uniform float brightness = 1.0;

float pattern(vec2 uv) {
    float t = TIME * speed;

    float a = sin((uv.x + t) * 6.28318);
    float b = sin((uv.y - t) * 6.28318);
    float c = sin((uv.x + uv.y + t * 0.5) * 6.28318);
    float d = cos((uv.x - uv.y - t * 0.7) * 6.28318);

    return (a + b + c + d) * 0.25;
}

vec3 hsv2rgb(vec3 c){
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0,4.0,2.0),6.0)-3.0)-1.0,0.0,1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    vec2 uv = UV * scale;

    float p = pattern(uv);

    // Convierte el patrón en un tono del arcoíris
    float hue = fract(p * 0.85 + TIME * speed * 0.05);

    vec3 col = hsv2rgb(vec3(hue, saturation, brightness));

    // Da un poco de volumen al color
    col += p * intensity;

    COLOR = vec4(col, 1.0);
}

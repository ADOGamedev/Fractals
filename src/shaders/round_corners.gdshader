shader_type canvas_item;

uniform float radius : hint_range(0.0, 1000.0) = 20.0;

void fragment() {
    vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 p = UV * size;

    vec2 q = min(p, size - p);
    
    if (q.x < radius && q.y < radius) {
        vec2 corner = vec2(radius);
        if (distance(q, corner) > radius) {
            discard;
        }
    }

    COLOR = texture(TEXTURE, UV);
}
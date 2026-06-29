shader_type canvas_item;

// Parámetros del poly-flake
uniform int   u_sides        : hint_range(3, 12) = 6;   // N: nº de lados del polígono
uniform float u_radius                     = 1.0;      // R: radio circunscrito del polígono base
uniform float u_scale                      = 0.33;     // r: factor de escala de las copias
uniform bool  u_include_center             = true;     // ¿copia central sí/no?
uniform int   u_iterations   : hint_range(1, 20) = 10; // nº máx de iteraciones IFS

// Color
uniform vec4  u_color_inside = vec4(0.8, 0.9, 1.0, 1.0);
uniform vec4  u_color_outside = vec4(0.0, 0.0, 0.0, 1.0);

// Polígono regular centrado en el origen
bool inside_regular_polygon(vec2 p, int n, float r) {
    float angle = atan(p.y, p.x);
    float delta = 2. * PI / float(n);
    float theta = mod(angle, delta) - delta / 2.0;
  
    float lengthPD         = r * cos(delta / 2.0);
    float lengthProjection = length(p) * cos(theta);
    return (lengthProjection - lengthPD) < 0.;
}

// Transformación inversa de una copia hija en el vértice k
vec2 inverse_child_transform(vec2 p, int k, int N, float r, float R) {
    float sector = 2.0 * PI / float(N);
    float angle  = sector * float(k);
    vec2 offset  = vec2(cos(angle), sin(angle)) * R * (1.0 - r);
    // Inversa: deshacer traslación y escala
    return (p - offset) / r;
}

vec4 polyflake_color(vec2 p) {
    vec2 z = p;
    int hits = 0;

    for (int i = 0; i < u_iterations; i++) {
        bool transformed = false;

        // Copia central (opcional)
        if (u_include_center) {
            vec2 z_center = z / u_scale;
            if (inside_regular_polygon(z_center, u_sides, u_radius)) {
                z = z_center;
                hits += 1;
                transformed = true;
            }
        }

        // Copias en los vértices
        if (!transformed) {
            // límite máximo de lados para el bucle
            const int MAX_SIDES = 32;
            for (int k = 0; k < MAX_SIDES; k++) {
                if (k >= u_sides) break;

                vec2 z_child = inverse_child_transform(z, k, u_sides, u_scale, u_radius);
                if (inside_regular_polygon(z_child, u_sides, u_radius)) {
                    z = z_child;
                    hits += 1;
                    transformed = true;
                }
            }
        }

        if (!transformed) {
            break;
        }
    }

    if (hits >= 0) {
        float t = 0.4*float(hits) / float(u_iterations);
        return vec4(vec3(t), 1.0);
    } else {
        return u_color_outside;
    }
}

void fragment() {
    // UV en [-1,1], corrigiendo aspecto
    vec2 uv = (UV * 2.0 - 1.0);
    float aspect = 1.7777777777;
    uv.x *= aspect;

    COLOR = polyflake_color(uv);
}

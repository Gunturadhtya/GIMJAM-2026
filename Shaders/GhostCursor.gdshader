shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
uniform float line_thickness : hint_range(0, 10) = 2;

void fragment() {
    vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
    vec4 current_pixel = texture(TEXTURE, UV);

    float a_up    = texture(TEXTURE, UV + vec2(0, -size.y)).a;
    float a_down  = texture(TEXTURE, UV + vec2(0, size.y)).a;
    float a_left  = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
    float a_right = texture(TEXTURE, UV + vec2(size.x, 0)).a;

    bool is_edge = (current_pixel.a > 0.1) && (a_up < 0.1 || a_down < 0.1 || a_left < 0.1 || a_right < 0.1);

    if (is_edge) {
        COLOR = line_color;
    } else {
        discard;
    }
}
shader_type canvas_item;

// The screen texture
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Define your palette (max 16 for performance, but can be more)
uniform vec3 palette[16];
uniform int palette_size = 16;

void fragment() {
    // Get the original screen color
    vec4 screen_col = texture(screen_texture, SCREEN_UV);
    vec3 original_rgb = screen_col.rgb;
    
    vec3 closest_color = palette[0];
    float min_distance = distance(original_rgb, palette[0]);
    
    // Loop through palette to find the nearest color
    for (int i = 1; i < palette_size; i++) {
        float dist = distance(original_rgb, palette[i]);
        if (dist < min_distance) {
            min_distance = dist;
            closest_color = palette[i];
        }
    }
    
    COLOR = vec4(closest_color, screen_col.a);
}
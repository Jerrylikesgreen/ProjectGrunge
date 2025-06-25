shader_type canvas_item;

/* 0 → fully monochrome, 1 → full colour */
uniform float colorize : hint_range(0.0, 1.0) = 0.0;

/* Bind the screen buffer so we can post-process it */
uniform sampler2D screen_tex : hint_screen_texture;

void fragment() {
    // Sample the already-drawn framebuffer
    vec4 src  = texture(screen_tex, SCREEN_UV);

    // Convert to grayscale luminance
    float gray = dot(src.rgb, vec3(0.299, 0.587, 0.114));

    // Interpolate FROM gray TO full colour by the uniform
    vec3 final_rgb = mix(vec3(gray), src.rgb, colorize);

    COLOR = vec4(final_rgb, src.a);
}

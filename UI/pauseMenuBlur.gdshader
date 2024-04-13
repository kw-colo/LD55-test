shader_type canvas_item;

uniform float blur: hint_range(0.0,5) = 2.5;
uniform float brightness: hint_range(0.0, 1.0) = 1;
uniform float saturation: hint_range(0.0, 1.0) = 1;
uniform float hue: hint_range(0.0, 360.0) = 0; // Maybe not a range?


uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	COLOR.rgb = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur).rgb;
	COLOR.rgb *= brightness;
	// Place fragment code here.
}
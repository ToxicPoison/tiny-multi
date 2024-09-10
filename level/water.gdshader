shader_type canvas_item;

uniform float speed = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV + vec2(TIME * speed / 100.0, 0.0));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

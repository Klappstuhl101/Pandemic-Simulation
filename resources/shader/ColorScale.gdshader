shader_type canvas_item;
render_mode unshaded;

uniform sampler2D infectGradient;
// uniform sampler2D twoColorGradient;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	vec3 sampled = texture(infectGradient, vec2(1.0-UV.y, 1.0-UV.x)).rgb;
	COLOR = vec4(sampled,alpha);
}


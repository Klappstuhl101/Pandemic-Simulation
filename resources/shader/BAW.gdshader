shader_type canvas_item;
render_mode unshaded;

uniform float incidenceRatio = 0.2;

uniform sampler2D infectGradient;
uniform sampler2D twoColorGradient;

void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	vec3 sampled = texture(infectGradient, vec2(incidenceRatio,0)).rgb;
	COLOR = vec4(sampled,alpha);
}


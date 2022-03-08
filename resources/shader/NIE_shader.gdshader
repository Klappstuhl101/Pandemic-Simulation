shader_type canvas_item;
//render_mode unshaded;
//
//uniform float green_space = 3.0;
//
//uniform float vaccinated=0.4; // use for color and height of color
//uniform float infected=0.5; // use same as vaccinated 
//
//uniform sampler2D infectGradient;
//// uniform sampler2D twoColorGradient;
//
//vec3 colorValues(float UVy, float UVx) {
//	if (UVy <= (1.0/green_space)) {
//		if (UVx <= vaccinated) {
//			return vec3(UVy*green_space,1,UVy*green_space);
//		} else {
//			return vec3(1,1,1);
//		}
//	} else {
//		float red_space = (1.0-(1.0/green_space)); // Höhe des roten Anzeigebereichs
//		float infect_height = 1.0 - (infected*red_space);
//
//		if(UVy >= infect_height) {
//			float gradient_uvy = (UVy - infect_height)*(1.0/(1.0-infect_height));
//			vec3 sampled = texture(twoColorGradient, vec2(1.0-gradient_uvy,0)).rgb;
//			return sampled;
//		} else {
//			return vec3(1,1,1);
//		}
//
//	}
//}
//
//
//void fragment() {
//	float alpha = texture(TEXTURE, UV).a;
//	if((infected == 0.0) && (vaccinated == 0.0)) {
//		COLOR = vec4(1,1,1,alpha);
//	} else {
//		COLOR = vec4(colorValues(UV.y, UV.x), alpha);
//	}
//}

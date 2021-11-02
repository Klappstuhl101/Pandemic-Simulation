shader_type canvas_item;
render_mode unshaded;

uniform float green_space = 3.0;
//uniform float green_space = (1.0/green);

uniform float vaccinated=0.4; // use for color and height of color
uniform float infected=0.5; // use same as vaccinated 

uniform sampler2D infectGradient;
uniform sampler2D twoColorGradient;

//vec3 colorValues(float UVy) {
//	if (UVy <= 0.4) {
//		return vec3((1.0-vaccinated)*(UVy), (1.0-vaccinated)*1.0, (1.0-vaccinated)*(UVy)); // nah dran an Lösung
//	} else {
//		return vec3(1, (1.0-infected)*2.0*(1.0-UVy), (1.0-infected)*2.0*(1.0-UVy)); // auch nah dran
//	}
//}
//
float meanColor(float color, float sampledUVY) {
	return ((1.0-sampledUVY)+(sampledUVY*color))/2.0;
}

vec3 colorValues2(float UVy, float UVx) {
	if (UVy <= (1.0/green_space)) {
		if (UVx <= vaccinated) {
			return vec3(UVy*green_space,1,UVy*green_space);
		} else {
			return vec3(1,1,1);
		}
	} else {
		float red_space = (1.0-(1.0/green_space)); // Höhe des roten Anzeigebereichs
		
		float infect_height = 1.0 - (infected*red_space);
		
		vec3 sampled_color = texture(infectGradient, vec2(infected, 0)).rgb;
		
		
		if(UVy >= infect_height) {
			float neg_gradient_uvy = (UVy - (1.0/green_space)) * (1.0/red_space); // Höhe von [0,1] innerhalb red_space
			float gradient_uvy = 1.0 - neg_gradient_uvy;
			vec3 sampled = texture(twoColorGradient, vec2(gradient_uvy,0)).rgb;
//			vec3 sampled = vec3(sampled_color.r*gradient_uvy, sampled_color.g*gradient_uvy, sampled_color.b*gradient_uvy);
//			vec3 sampled = sampled_color;
//			vec3 sampled = vec3(meanColor(sampled_color.r,gradient_uvy), meanColor(sampled_color.g, gradient_uvy), meanColor(sampled_color.b,gradient_uvy));
			return sampled;
		} else {
			return vec3(1,1,1);
		}
		
	}
}


void fragment() {
	float alpha = texture(TEXTURE, UV).a;
	if((infected == 0.0) && (vaccinated == 0.0)) {
		COLOR = vec4(1,1,1,alpha);
	} else {
//		COLOR = vec4(infected*UV.y , vaccinated*(1.0-UV.y) , blueValue(UV.y)*UV.y, alpha);
//		COLOR = vec4(infected*UV.y , vaccinated*(1.0-UV.y) , 0, alpha);
//		COLOR = vec4(infected*redValue(UV.y), vaccinated*greenValue(UV.y), 0, alpha);
//		COLOR = vec4(colorValues(UV.y), alpha);
		COLOR = vec4(colorValues2(UV.y, UV.x), alpha);
	}
}


	
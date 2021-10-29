shader_type canvas_item;
render_mode unshaded;

uniform float green_space = 3.0;
//uniform float green_space = (1.0/green);

uniform float vaccinated=0.4; // use for color and height of color
uniform float infected=0.5; // use same as vaccinated 

uniform sampler2D infectGradient;

uniform vec3 testcolor = vec3(0.0,0.0,0.0);

//vec3 colorValues(float UVy) {
//	if (UVy <= 0.4) {
//		return vec3((1.0-vaccinated)*(UVy), (1.0-vaccinated)*1.0, (1.0-vaccinated)*(UVy)); // nah dran an Lösung
//	} else {
//		return vec3(1, (1.0-infected)*2.0*(1.0-UVy), (1.0-infected)*2.0*(1.0-UVy)); // auch nah dran
//	}
//}

float meanColor(float color) {
	return (infected*color + (1.0-infected))/2.0;
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
		
		vec3 sampled = vec3(meanColor(sampled_color.r), meanColor(sampled_color.g), meanColor(sampled_color.b));
		
		if(UVy >= infect_height) {
			return sampled_color;
		} else {
			return vec3(1,1,1);
		}
		
//		vec3 sampled = vec3(sampled_color.r, sampled_color.g, sampled_color.b);
//		vec3 sampled_color = texture(infectGradient, vec2(1.0-UVy, 1.0-UVx)).rgb;
//		return sampled_color;
//		if((1.0-UVy) <= infected) {
//			return vec3((1.0-infected)*1.0,0,infected); // fade-out fehlt noch
//		} else {
//			return vec3(1,1,1);
//		}
//		return vec3(1, (1.0-infected)*3.0*(1.0-UVy), (1.0-infected)*3.0*(1.0-UVy)); // auch nah dran
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


	
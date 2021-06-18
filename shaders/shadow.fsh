#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float isWater;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;

	if(isWater > 0.9)
		gl_FragData[0] = vec4(color.rgb, 0.4);
	else
		gl_FragData[0] = color;
}
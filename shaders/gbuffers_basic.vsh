#version 120

varying vec2 lmcoord;
varying vec4 glcolor;

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	gl_Position = ftransform();
}
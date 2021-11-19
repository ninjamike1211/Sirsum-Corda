#version 120

varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 normal;

void main() {
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	normal = gl_NormalMatrix * gl_Normal;

	gl_Position = ftransform();
}
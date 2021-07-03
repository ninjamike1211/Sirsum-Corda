#version 120

#include "include.glsl"

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;

attribute vec4 at_tangent;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

	normal = gl_NormalMatrix * gl_Normal;
}
#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float isWater;

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

#include "include.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	isWater = float(mc_Entity.y == 1);
	gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + vec4(waveOffset(getBlockType(mc_Entity.x), gl_Vertex, texcoord, mc_midTexCoord, gl_Normal), 0.0));
	gl_Position.xyz = distort(gl_Position.xyz);
}
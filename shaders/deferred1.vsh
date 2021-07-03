#version 120

#include "include.glsl"

varying vec2 texcoord;
varying vec3 bottomSkyColor;
varying vec3 viewVector;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	vec4 ray = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;

	#ifndef Old_Sky
		float timeFactor = dayTimeFactor();
		bottomSkyColor = getBottomSkyColor(timeFactor);
	#endif
}
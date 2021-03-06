#version 120

#include "include.glsl"

varying vec2 texcoord;
varying vec3 viewVector;
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying vec3 sunPosNorm;
varying vec3 lightPos;
varying vec3 upPosition;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	vec4 ray = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;

	sunPosNorm = fixedSunPosition();
	lightPos = fixedLightPosition();

	#ifndef Old_Sky
		topSkyColor = getTopSkyColor(timeFactor);
		bottomSkyColor = getBottomSkyColor(timeFactor);
		sunColor = getSunColor(timeFactor);
		sunBlurColor = getSunBlurColor(timeFactor);
		upPosition = mat3(gbufferModelView) * vec3(0.0, 1.0, 0.0);
	#endif
}
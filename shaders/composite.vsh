#version 120

#include "include.glsl"

varying vec2 texcoord;
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying float timeFactor;
varying vec3 sunPosNorm;
varying vec3 moonPosNorm;
varying vec3 upPosition;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	timeFactor = dayTimeFactor();

	topSkyColor = getTopSkyColor(timeFactor);
	bottomSkyColor = getBottomSkyColor(timeFactor);
	sunColor = getSunColor(timeFactor);
	sunBlurColor = getSunBlurColor(timeFactor);

	upPosition = mat3(gbufferModelView) * vec3(0.0, 1.0, 0.0);

	sunPosNorm = fixedSunPosition();
}
#version 120

#include "include.glsl"

#define SUN_POSITION_FIX

uniform vec3 sunPosition;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 moonColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying float timeFactor;
varying float adjustedTimeFactor;
varying vec3 sunPosNorm;
varying vec3 moonPosNorm;
varying vec3 upPosition;

void main() {
	gl_Position = ftransform();
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));

	#ifndef Old_Sky
		timeFactor = dayTimeFactor();
		topSkyColor = getTopSkyColor(timeFactor);
		bottomSkyColor = getBottomSkyColor(timeFactor);
		sunColor = getSunColor(timeFactor);
		sunBlurColor = getSunBlurColor(timeFactor);
		upPosition = mat3(gbufferModelView) * vec3(0.0, 1.0, 0.0);

		#ifdef SUN_POSITION_FIX
			sunPosNorm = fixedSunPosition();
		#else
			sunPosNorm = normalize(sunPosition);
		#endif
	#endif
}
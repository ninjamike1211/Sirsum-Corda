#version 120

#include "include.glsl"

#define SUN_POSITION_FIX

uniform vec3 sunPosition;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying vec3 sunPosNorm;
varying vec3 upPosition;
// varying vec4 glcolor;

void main() {
	gl_Position = ftransform();
	// gl_Position.z = -far;
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	// starData = vec4(0.0);
	// glcolor = gl_Color;

	#ifndef Old_Sky
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
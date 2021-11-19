#version 120

#include "include.glsl"

uniform vec3 moonPosition;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying vec3 sunPosNorm;
varying vec3 upPosition;
// varying vec4 glcolor;

void main() {
	vec3 color;

	// gl_FragDepth = 0.0;

	vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
	pos = gbufferProjectionInverse * pos;
	vec3 baseColor = getSkyColor(normalize(pos.xyz), topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor, false);
	// vec3 baseColor = vec3(0.5);

	// starData = vec4(0.0);

	if (starData.a > 0.5) {
		baseColor = vec3(0.0);
		color = starData.rgb;
	}
	else {
		color = baseColor;
	}

/* RENDERTARGETS: 0,11 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
	gl_FragData[1] = vec4(baseColor, 1.0);
}
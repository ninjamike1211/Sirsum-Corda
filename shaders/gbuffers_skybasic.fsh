#version 120

#include "include.glsl"

uniform vec3 moonPosition;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 moonColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying float timeFactor;
varying float adjustedTimeFactor;
varying vec3 sunPosNorm;
varying vec3 upPosition;

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(topSkyColor, bottomSkyColor, fogify(max(upDot, 0.0), 0.1));
}

void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = getSkyColor(normalize(pos.xyz), topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor);
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
	// gl_FragData[1] = vec4(0.0, 0.0, -9999999.0, 1.0); //gcolor
}
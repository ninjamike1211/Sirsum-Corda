#version 120

#include "include.glsl"

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
varying vec3 sunColor;
varying vec3 moonColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying float timeFactor;
varying float adjustedTimeFactor;

void main() {
	gl_Position = ftransform();
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));

	timeFactor = dayTimeFactor();
	adjustedTimeFactor = sign(timeFactor) * sqrt(abs(timeFactor));

	topSkyColor = mix(vec3(0.0, 0.01, 0.04), vec3(0.3, 0.5, 0.8), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
	bottomSkyColor = mix(vec3(0.04, 0.04, 0.1), vec3(0.6, 0.8, 1.0), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));

	sunColor = mix(vec3(1.0, 0.65, 0.3), topSkyColor, max(adjustedTimeFactor, 0.0));
	moonColor = max(vec3(0.15, 0.15, 0.25), topSkyColor);

	// topSkyColor = vec3(0.0, 0.01, 0.04);
	// bottomSkyColor = vec3(0.04, 0.04, 0.1);
}
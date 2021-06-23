#version 120

#include "include.glsl"

#define SUN_POSITION_FIX

#ifdef SUN_POSITION_FIX
	const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994)); //Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
#endif

uniform mat4 gbufferModelView;
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

	timeFactor = dayTimeFactor();
	adjustedTimeFactor = sign(timeFactor) * sqrt(abs(timeFactor));

	topSkyColor = mix(vec3(0.0, 0.01, 0.04), vec3(0.3, 0.5, 0.8), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
	bottomSkyColor = mix(vec3(0.06, 0.07, 0.1), mix(vec3(0.75, 0.6, 0.5), vec3(0.6, 0.8, 1.0), clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0)), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));

	// sunColor = mix(vec3(1.0, 0.65, 0.3), topSkyColor, max(adjustedTimeFactor, 0.0));
	// sunColor = mix(mix(vec3(1.0, 0.55, 0.2), vec3(1.0, 0.6, 0.2), clamp(4.0 * (timeFactor + 0.05), 0.0, 1.0)), topSkyColor, clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0));
	// sunColor = mix(vec3(1.0, 0.55, 0.2), topSkyColor, clamp(3.0 * (timeFactor - 0.2), 0.0, 1.0));
	sunColor = mix(vec3(0.9, 0.4, 0.1), vec3(1.0, 0.6, 0.2), clamp(4.0 * (timeFactor + 0.05), 0.0, 1.0));
	sunBlurColor = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 1.0, 1.0), 1.0 - clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0));
	moonColor = max(vec3(0.15, 0.15, 0.25), topSkyColor);

	upPosition = mat3(gbufferModelView) * vec3(0.0, 1.0, 0.0);

	#ifdef SUN_POSITION_FIX
		//minecraft's native calculateCelestialAngle() function, ported to GLSL.
		float ang = fract(worldTime / 24000.0 - 0.25);
		ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959; //0-2pi, rolls over from 2pi to 0 at noon.

		//this one tracks optifine's sunPosition uniform.
		sunPosNorm = mat3(gbufferModelView) * vec3(-sin(ang), cos(ang) * sunRotationData);
		//this one tracks the center of the *actual* sun, which is ever-so-slightly different.
		//sunPosNorm = normalize((gbufferModelView * vec4(sin(ang) * -100.0, (cos(ang) * 100.0) * sunRotationData, 1.0)).xyz);
		//I choose to use the sunPosition one for 2 reasons:
		//1: it's simpler.
		//2: it's consistent with other programs which are sensitive to subtle differences.
	#else
		sunPosNorm = normalize(sunPosition);
	#endif
}
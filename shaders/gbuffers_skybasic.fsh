#version 120

#define SKY_SPLIT_OLD_NEW
//#define OLD_SUN

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 moonPosition;
uniform int worldTime;

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

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	#ifdef SKY_SPLIT_OLD_NEW
	if(gl_FragCoord.x < 960)
	#endif
		return mix(topSkyColor, bottomSkyColor, fogify(max(upDot, 0.0), 0.1));
	#ifdef SKY_SPLIT_OLD_NEW
	else
		return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
	#endif
}

void main() {
	vec3 color;
	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		pos.xyz = normalize(pos.xyz);
		color = calcSkyColor(pos.xyz);

		float sunDotV = max(dot(sunPosNorm, normalize(pos.xyz)), 0.0);
		// float sunBlur = pow(sunDotV, 500.0);
		float sunBlur = smoothstep(0.996, 0.9975, sunDotV);
		#ifdef OLD_SUN
			sunBlur = 0.0;
		#endif
		// sunBlur *= smoothstep(-0.02, -0.01, dot(pos.xyz, normalize(upPosition)));
		// float sunBlurAmount = clamp(sunBlur - 0.01, 0.0, 1.0);
		float sunAmount = pow(sunDotV, 2.0);
		sunAmount -= sunBlur;
		// sunAmount *= 1.0 - clamp(1.5 * (adjustedTimeFactor - 0.5), 0.0, 1.0);
		sunAmount *= smoothstep(-0.3, -.16, timeFactor);
		sunAmount *= 1.0 - clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0);
		sunAmount *= min(pow(1.0 - dot(pos.xyz, normalize(upPosition)), 3.0), 1.0);
		
		// float moonAmount = pow(max(dot(normalize(moonPosition), normalize(pos.xyz)), 0.0), 4.0);
		// moonAmount = 0.0;

		// vec3 sunBlurColor = vec3(2.0, 2.0, 2.0);
		// vec3 sunBlurColor = sunColor;

		#ifdef SKY_SPLIT_OLD_NEW
		if(gl_FragCoord.x < 960)
		#endif
		{
			color = sunAmount * sunColor + sunBlur * sunBlurColor + max(1.0 - sunAmount - sunBlur, 0.0) * color;
		}
		// color = moonAmount * moonColor + (1.0 - moonAmount);

		// color = vec3(sunAmount, moonAmount, 0.0);

		// color = vec3(pow(1.0 - max(dot(pos.xyz, normalize(upPosition)), 0.0), 10.0));

		// color = vec3(acos(1.0 / normalize(sunPosition).y - pos.y));

		// color = vec3(clamp(adjustedTimeFactor + 0.0, 0.0, 1.0));
		// color = vec3(adjustedTimeFactor + 1.0);
		// color = vec3(1.0 - clamp(1.2 * adjustedTimeFactor - 0.2, 0.0, 1.0));

		// color = vec3(sunAmount) + sunBlur * vec3(2.0, 2.0, 2.0);

		// color = vec3(dot(pos.xyz, upPosition));
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
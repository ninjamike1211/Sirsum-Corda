#version 120

#include "include.glsl"

#define dof_enable
#define blurSize 1.0 		//[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define hexagon_blur
#define hand_blur
#define near_blur
//#define distance_blur
#define distance_blur_distance 0.0 //[0.0 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
// #define max_blur 0.2 //[0.0 0.025 0.05 0.075 0.1 0.15 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define focalLength 0.0001
// #define water_blur

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex8;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D depthtex0;
uniform float centerDepthSmooth;

varying vec2 texcoord;
varying vec3 viewVector;
varying vec3 sunColor;
varying vec3 sunBlurColor;
varying vec3 topSkyColor;
varying vec3 bottomSkyColor;
varying vec3 sunPosNorm;
varying vec3 lightPos;
varying vec3 upPosition;

const float centerDepthHalflife = 1.0;	//[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0]

/* RENDERTARGETS: 0,8,10 */
void main() {

	vec3 finalColor = texture2D(colortex0, texcoord).rgb;

	vec3 lmcoord = texture2D(colortex3, texcoord).rgb;
	vec3 specMap = texture2D(colortex4, texcoord).rgb;
	float depth = texture2D(depthtex0, texcoord).r;
	#ifdef Combine_Normal_Buffers
		vec3 normal = normalize(decodeNormal(texture2D(colortex1, texcoord).rg));
	#else
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
	#endif

// ---------------------------SSR---------------------------
	#ifdef SSR
		vec4 F0 = calcF0(specMap, texture2D(colortex0, texcoord).rgb);
		float isWeather = lmcoord.b;
		
		if(depth != 1.0 && isWeather == 0.0 && (specMap.r > SSR_Bottom || F0.a == 1.0 || wetness > 0.0 /* || isEyeInWater == 1 */)) {
			vec3 viewPos = calcViewPos(viewVector, depth);
			float isWater = texture2D(colortex6, texcoord).r;

			vec3 fresnel = max(smoothstep(SSR_Bottom, SSR_Top, specMap.r), wetness) * clamp(fresnelSchlick(dot(normalize(viewVector), normal), F0.rgb), 0.0, 1.0);

			vec3 viewPosNorm = normalize(viewPos);
			vec3 reflectDir = reflect(viewPosNorm, normal);
			float RdotUp = dot(reflectDir, normalize(upPosition));
			vec3 skyColor = getSkyColor(reflectDir, topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor, false);
			skyColor = mix(finalColor, skyColor, float(!(isWater == 1.0 && isEyeInWater == 1.0)) * eyeBrightnessSmooth.y / 240.0);

			if(isWater == 1.0 && isEyeInWater == 1.0) {
				// fresnel = vec3(0.0);
				// skyColor = finalColor;
			}

			#ifdef SSR_Multi
				float roughFactor = mix(SSR_Max_Roughness * 0.05, 0.0, smoothstep(SSR_Bottom, SSR_Top, specMap.r));
				
				vec3 reflectionPos = calcReflection(texcoord, viewPos.xyz, normal, specMap, depthtex0, colortex6, isWater < 0.1);
				vec3 finalReflection = mix(skyColor, texture2D(colortex0, reflectionPos.xy).rgb, reflectionPos.z);

				if(roughFactor > 0.0) {
					for(int i = 1; i < reflectionKernel.length(); ++i) {
						reflectDir = reflect(viewPosNorm, normalize(normal + vec3(reflectionKernel[i] * roughFactor, 0.0)));
						reflectionPos = calcSSR(viewPos, reflectDir, depthtex0, colortex6, isWater < 0.1);
						finalReflection += mix(skyColor, texture2D(colortex0, reflectionPos.xy).rgb, reflectionPos.z);
					}

					finalReflection *= /* fresnel * */ /* max(max(smoothstep(SSR_Bottom, SSR_Top, specMap.r), wetness), isEyeInWater*0.8) */ 1.0 / reflectionKernel.length();
				}
			#else
				// vec3 reflectDir = reflect(normalize(viewPos), normal);
				// float RdotUp = dot(reflectDir, normalize(upPosition));
				vec3 reflectionPos = calcReflection(texcoord, viewPos.xyz, normal, specMap, depthtex0, colortex6, isWater < 0.1);
				// vec3 skyColor = smoothstep(-0.5, 0.0, RdotUp) * float(!(isWater == 1.0 && isEyeInWater == 1.0)) * (eyeBrightnessSmooth.y / 240.0) * getSkyColor(reflectDir, topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor, false);

				vec3 finalReflection = /* fresnel * */ /* max(max(smoothstep(SSR_Bottom, SSR_Top, specMap.r), wetness), isEyeInWater*0.8) * */ mix(skyColor, texture2D(colortex0, reflectionPos.xy).rgb, reflectionPos.z);
			#endif

			finalReflection = blendToFog(finalReflection, viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
			finalColor = mix(finalColor, finalReflection, fresnel);

			// finalColor = vec3(float(fresnel.r == 1.0), float(fresnel.g == 1.0), float(fresnel.b == 1.0));
			// finalColor = fresnel;

			// finalColor = finalReflection;
			// finalColor += fresnel * finalReflection;
			// finalColor = finalReflection;
		}
	#endif

	if(depth != 1.0)
		// finalColor += pbrSpecular(normalize(viewVector), finalColor, normal, normalize(shadowLightPosition), specMap, lightmapSky(lmcoord.g));
		finalColor += texture2D(colortex12, texcoord).rgb;


// ---------------------------Bloom---------------------------
	#ifdef bloom
		vec2 tex_offset = Bloom_Spread / vec2(viewWidth, viewHeight); // gets size of single texel
		vec3 color = texture2D(colortex8, texcoord).rgb * bloomWeight[0]; // current fragment's contribution

		for(int i = 1; i < bloomWeight.length(); ++i) {
			color += texture2D(colortex8, texcoord + vec2(tex_offset.x * i, 0.0)).rgb * bloomWeight[i];
			color += texture2D(colortex8, texcoord - vec2(tex_offset.x * i, 0.0)).rgb * bloomWeight[i];
		}

		gl_FragData[1] = vec4(color, 1.0); //gcolor
	#endif

// ---------------------------DOF---------------------------
	#ifdef dof_enable
		float hand = texture2D(colortex5, texcoord).b;
		float depthDOF = linearDepth(texture2D(depthtex0, texcoord).x) + hand * 0.005;

		if(lmcoord.b != 0.0)
			depthDOF = linearDepth(lmcoord.b);

		#ifdef water_blur
			float centerDepth = linearDepth(texture2D(depthtex0, vec2(0.5, 0.5)).r);
		#else
			float centerDepth = linearDepth(centerDepthSmooth);
		#endif

		#ifdef distance_blur
			//float CoC = max((depth-1.0) / (1.0 - distance_blur_distance) + 1.0, 0.0);
			float CoC = max(blurSize * (depthDOF - distance_blur_distance), 0.0);
		#else
			//float focalLength = 1.0 / (1.0 / centerDepth + 1.0 / blurPower);
			//float CoC = -blurSize * (focalLength * (centerDepth - depth)) / (depth * (centerDepth - focalLength));
			// float CoC = blurSize * (depthDOF - centerDepth) * (1.0 - centerDepth);
			// float CoC = min(abs(blurSize * (depthDOF - centerDepth)), max_blur);
			//float CoC = blurSize * ((depth * depth - 1.0) / (1.0 - linearDepth(centerDepthSmooth)) + 1.0);

			// float CoC = blurSize * (depthDOF - centerDepth) / depthDOF;
			float CoC = 20.0 * blurSize * abs(focalLength / (centerDepth - focalLength)) * (1.0 - (centerDepth / depthDOF));
			// float CoC = blurSize * (depthDOF - centerDepth);
			// float CoC = pow(log(2.0 * abs(depthDOF - centerDepth) + 1), 1.0);
		#endif

		// CoC = min(abs(CoC), max_blur);

		#ifndef hand_blur
			if(hand == 1.0)
				CoC = 0.0;
		#endif

		#ifndef near_blur
			if(hand != 1.0)
				CoC = max(CoC, 0.0);
		#endif

		gl_FragData[2] = vec4(abs(CoC), 0.0, 0.0, 1.0);
	#endif
	
	gl_FragData[0] = vec4(finalColor, 1.0);
}
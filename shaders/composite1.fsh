#version 120

#include "include.glsl"

#define Shadow_On_Transparent //Controls whether shadows can be cast on top of transparent objects.
#define Water_Refraction
#define Water_Refraction_CA
#define Water_Refraction_CA_Amount 0.2 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5]
#define Water_Refraction_Index 0.75 // [0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]

uniform sampler2D colortex0;		// Albedo
uniform sampler2D colortex1;		// Normal
uniform sampler2D colortex2;		// Geometry normal
uniform sampler2D colortex3;		// rg = Light map, b = weather
uniform sampler2D colortex4;		// Specular map
uniform sampler2D colortex5;		// r = height map, g = ao, b = hand
uniform sampler2D colortex6;		// r = water g = SSAO
uniform sampler2D colortex7;		// Deferred output
uniform sampler2D colortex8;		// Bloom output
// uniform sampler2D colortex9;		// TAA Velocity
// uniform sampler2D colortex10;	// Water refraction output
uniform sampler2D colortex11;		// Sky Color
uniform sampler2D colortex12;		// Specular output
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

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
	/* RENDERTARGETS: 0,8,10,12 */

// --------------------------- Reading buffers ------------------------------
	vec4 deferredColor = texture2D(colortex7, texcoord);
	vec4 waterColor = texture2D(colortex0, texcoord);
	float depth = texture2D(depthtex0, texcoord).r;
	vec3 viewPos = calcViewPos(viewVector, depth);
	vec4 lmcoord = texture2D(colortex3, texcoord);

	vec3 color = deferredColor.rgb;
	vec3 specular;


// --------------------------- SSAO ------------------------------
	#if SSAO > 1
		float occlusion;
		if(length(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0) > 0.9) {
			vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
			occlusion = 0.0;
			for (int x = -2; x < 2; ++x) 
			{
				for (int y = -2; y < 2; ++y) 
				{
					vec2 offset = vec2(float(x), float(y)) * texelSize;
					occlusion += texture2D(colortex6, texcoord + offset).g;
				}
			}
			occlusion /= 16.0;

			deferredColor.a = min(min(occlusion, deferredColor.a), 1.0 - (SSAO_Strength * (1.0 - texture2D(colortex5, texcoord).g)));
		}
		else {
			// occlusion = 1.0;
			// deferredColor.a = 1.0;
		}
	#else
		float occlusion = 1.0;
	#endif


// --------------------------- Transparent Rendering ---------------------------
	if(waterColor.a > 0.0) {
		vec3 specularMap = texture2D(colortex4, texcoord).rgb;
		vec3 material = texture2D(colortex5, texcoord).rgb;
		float isWater = texture2D(colortex6, texcoord).r;
		float deferredDepth = texture2D(depthtex1, texcoord).r;

		#ifdef Combine_Normal_Buffers
			vec3 normal = normalize(decodeNormal(texture2D(colortex1, texcoord).rg));
			vec3 geometryNorm = decodeNormal(texture2D(colortex1, texcoord).ba);
		#else
			vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
			vec3 geometryNorm = normalize(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0);
		#endif

		#if SSAO == 0
			waterColor.rgb *= material.g;
		#endif

		vec3 shadow = vec3(1.0);
		float NdotL = 1.0;


		if(deferredDepth != 1.0) {
			// deferredColor.rgb += pbrSpecular(normalize(viewVector), deferredColor.rgb, normal, normalize(shadowLightPosition), specMap, lightmapSky(lmcoord.g));
			deferredColor.rgb += texture2D(colortex12, texcoord).rgb;
		}

	// --------------------------- Weather ---------------------------
		if(lmcoord.b > 0.0) {
			depth = lmcoord.b;
			viewPos = calcViewPos(viewVector, depth);
			waterColor.rgb *= 0.5;
			// waterColor.rgb *= adjustLightMapShadow(vec3(1.0), lmcoord.rg);
			// waterColor.rgb = blendToFog(waterColor.rgb, viewPos.xyz, isEyeInWater, bottomSkyColor, lmcoord.rg);
			// waterColor = vec4(1.0);
		}
	// --------------------------- Non-Weather ---------------------------
		else {

		// --------------------------- Shadows ---------------------------
			NdotL = dot(normal, normalize(shadowLightPosition));

			#ifdef Shadow_On_Transparent
				vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
				vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
				float distortFactor = getDistortFactor(shadowPos.xy);
				shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
				shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
				shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NdotL); //apply shadow bias

				shadow = calculateShadow(shadowPos, texcoord);
			#endif

			vec3 shadowFinal = min(shadow, max(NdotL, 0.0));


		// --------------------------- PBR Lighting ---------------------------
			#ifdef PBR_Lighting
				waterColor.rgb = pbrDiffuse(normalize(viewVector), waterColor.rgb, normal, normalize(shadowLightPosition), specularMap, material, lightmapSky(lmcoord.g) * shadowFinal, lmcoord.rg);
				specular = pbrSpecular(normalize(viewVector), waterColor.rgb, normal, normalize(shadowLightPosition), specularMap, lightmapSky(lmcoord.g) * shadowFinal);
				specular *= 1.0 - blendTo(viewPos.xyz, isEyeInWater);
			#else
				waterColor.rgb *= adjustLightMapShadow(shadowFinal, lmcoord.rg);
			#endif
		}

	// --------------------------- Apply Ambient Occlusion ---------------------------
		deferredColor.rgb *= deferredColor.a;
		waterColor.rgb *= occlusion;
		

	// --------------------------- Water Refraction + Water Fog ---------------------------
		if(isWater > 0.1) {
			#ifdef Water_Refraction
				float refractionIndex = isEyeInWater == 1.0 ? (1.2 * Water_Refraction_Index) : Water_Refraction_Index;
				
				vec3 refractDir = normalize(refract(normalize(viewPos), geometryNorm - normal, refractionIndex));
				vec3 refractPos = calcRefraction(viewPos, normal, geometryNorm, refractionIndex, depthtex1, colortex6);
				refractPos.xy = mix(texcoord, refractPos.xy, refractPos.z);
				deferredColor.rgb = texture2D(colortex7, refractPos.xy).rgb;

				#ifdef Water_Refraction_CA
					vec3 refractDirR = normalize(refract(normalize(viewPos), geometryNorm - normal, refractionIndex - Water_Refraction_CA_Amount));
					vec3 refractDirB = normalize(refract(normalize(viewPos), geometryNorm - normal, refractionIndex + Water_Refraction_CA_Amount));
					vec3 refractPosR = calcRefraction(viewPos, normal, geometryNorm, refractionIndex - Water_Refraction_CA_Amount, depthtex1, colortex6);
					vec3 refractPosB = calcRefraction(viewPos, normal, geometryNorm, refractionIndex + Water_Refraction_CA_Amount, depthtex1, colortex6);
					refractPosR.xy = mix(texcoord, refractPosR.xy, refractPosR.z);
					refractPosB.xy = mix(texcoord, refractPosB.xy, refractPosB.z);
					deferredColor.r = texture2D(colortex7, refractPosR.xy).r;
					deferredColor.b = texture2D(colortex7, refractPosB.xy).b;
				#endif

				if(isEyeInWater == 1 && refractPos.z == 0.0)
					deferredColor.rgb = getSkyColor(refractDir, topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor, true);

				if(isEyeInWater == 0)
					deferredColor.rgb = waterFog(deferredColor.rgb, lmcoord.g, calcViewPos(refractPos.xy, texture2D(depthtex1, refractPos.xy).r), viewPos, 1.0 - dot(upPosition, normalize(viewPos)));
				else if(texture2D(depthtex1, refractPos.xy).r != 1.0)
					deferredColor.rgb = blendToFog(deferredColor.rgb, calcViewPos(refractPos.xy, texture2D(depthtex1, refractPos.xy).r), 0, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
					// deferredColor.rgb = waterFog(deferredColor.rgb, skyLightColor(), viewPos.xyz, viewPos, 1.0 - dot(upPosition, normalize(viewPos)));
			#else
				deferredColor.rgb = waterFog(deferredColor.rgb, lmcoord.g, calcViewPos(viewVector, deferredDepth), viewPos, 1.0 - dot(upPosition, normalize(viewPos)));
			#endif

			// deferredColor.rgb = waterFog(deferredColor.rgb, lmcoord.g, calcViewPos(viewVector, deferredDepth), viewPos, 1.0 - dot(upPosition, normalize(viewPos)));

			waterColor.rgb = blendToFog(waterColor.rgb, viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
			deferredColor.rgb = blendToFog(deferredColor.rgb, viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
			gl_FragData[2] = vec4(deferredColor.rgb, 1.0);
		}
	
	// --------------------------- Non-Water Fog ---------------------------
		else {
			waterColor.rgb = blendToFog(waterColor.rgb, viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
			if(deferredDepth != 1.0) {
				deferredColor.rgb = blendToFog(deferredColor.rgb, calcViewPos(viewVector, deferredDepth), isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
			}
		}


	// --------------------------- Transparent blending ---------------------------
		color = mix(deferredColor.rgb, waterColor.rgb, waterColor.a);

	}

// ---------------------------Opaque Rendering---------------------------
	else if(depth !=  1.0 || isEyeInWater == 1) {
		color *= deferredColor.a;
		color = blendToFog(color, viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);
		// color = vec3(-1.0+viewPos.z);

		// color = blendToFog(vec3(1.0), viewPos.xyz, isEyeInWater, texture2D(colortex11, texcoord).rgb, lmcoord.rg);

		specular = texture2D(colortex12, texcoord).rgb;
		specular *= 1.0 - blendTo(viewPos.xyz, isEyeInWater);
		// specular = vec3(0.0);

	}

	
// ---------------------------Final Output + Bloom---------------------------
	gl_FragData[0] = vec4(color, 1.0);

	float brightness = dot(color + specular, vec3(0.2126, 0.7152, 0.0722));
	float emissiveness = texture2D(colortex4, texcoord).a;
	gl_FragData[1] = vec4((brightness > Bloom_Threshold) ? (color + specular) : texture2D(colortex8, texcoord).rgb, 1.0); // bloom

	gl_FragData[3] = vec4(specular, 1.0);
}
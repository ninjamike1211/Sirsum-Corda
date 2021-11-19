#version 120

#include "include.glsl"

#define Shadow_On_Opaque

uniform sampler2D colortex0;	// Albedo
uniform sampler2D colortex1;	// Normal
uniform sampler2D colortex2;	// Geometry normal
uniform sampler2D colortex3;	// Light map
uniform sampler2D colortex4;	// Specular map
uniform sampler2D colortex5;	// r = height map, g = ao, b = Hand
uniform sampler2D colortex6;	// SSAO
// uniform sampler2D colortex7;	// Deferred output
uniform sampler2D colortex8;	// Bloom output
// uniform sampler2D colortex9;	// TAA velocity
uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 texcoord;
varying vec3 bottomSkyColor;
varying vec3 viewVector;
varying vec3 sunPosNorm;

void main() {
/* RENDERTARGETS: 7,8,12 */

// ---------------------------- Read buffers -------------------------------
	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec4 lmcoord = texture2D(colortex3, texcoord);

	// Ignore sky
	if(lmcoord.a == 0.0) {
		gl_FragData[0] = vec4(color, 1.0);
		return;
	}

	// Decode normal buffers
	#ifdef Combine_Normal_Buffers
		vec3 normal = normalize(decodeNormal(texture2D(colortex1, texcoord).rg));
		vec3 geometryNorm = decodeNormal(texture2D(colortex1, texcoord).ba);
	#else
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
		vec3 geometryNorm = normalize(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0);
	#endif

	float depth = texture2D(depthtex0, texcoord).r;
	vec3 specularMap = texture2D(colortex4, texcoord).rgb;
	vec3 material = texture2D(colortex5, texcoord).rgb;

	vec3 viewPos = calcViewPos(viewVector, depth);


// ---------------------------- SSAO -------------------------------
	#if SSAO == 1 || SSAO == 3
		float occlusion = 0.0;
		if(length(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0) > 0.9) {
			vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
			for (int x = -2; x < 2; ++x) 
			{
				for (int y = -2; y < 2; ++y) 
				{
					vec2 offset = vec2(float(x), float(y)) * texelSize;
					occlusion += texture2D(colortex6, texcoord + offset).g;
				}
			}
			occlusion /= 16.0;

			// occlusion = min(occlusion, texture2D(colortex5, texcoord).g);
			occlusion = min(occlusion, 1.0 - (SSAO_Strength * (1.0 - texture2D(colortex5, texcoord).g)));
		}
		else {
			occlusion = 1.0;
		}
	#elif SSAO == 0
		float occlusion = material.g;
	#else
		float occlusion = texture2D(colortex5, texcoord).g;
	#endif


// ---------------------------- Shadows -------------------------------
	float NdotL = dot(normal, normalize(shadowLightPosition));

	#ifdef Shadow_On_Opaque
		vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
		vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
		float distortFactor = getDistortFactor(shadowPos.xy);
		shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
		shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
		shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(dot(geometryNorm, normalize(shadowLightPosition))); //apply shadow bias

		vec3 shadow = calculateShadow(shadowPos, texcoord);
		shadow = min(shadow, max(NdotL, 0.0));

	#else
		vec3 shadow = vec3(max(NdotL, 0.0));
	#endif


// ---------------------------- PBR lighting -------------------------------
	#ifdef PBR_Lighting
		gl_FragData[2] = vec4(pbrSpecular(normalize(viewVector), color, normal, normalize(shadowLightPosition), specularMap, lightmapSky(lmcoord.g) * shadow), 1.0);
		color = pbrDiffuse(normalize(viewVector), color, normal, normalize(shadowLightPosition), specularMap, vec3(material.r, 1.0, material.b), lightmapSky(lmcoord.g) * shadow, lmcoord.rg);
	#else
		color *= adjustLightMapShadow(shadow, lmcoord.rg);
	#endif


// ---------------------------- Output to Buffers -------------------------------
	gl_FragData[0] = vec4(color, occlusion); //gcolor

	// float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	// gl_FragData[1] = vec4((brightness > Bloom_Threshold) ? color : texture2D(colortex8, texcoord).rgb, 1.0);
}
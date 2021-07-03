#version 120

#include "include.glsl"

#define Shadow_On_Transparent //Controls whether shadows can be cast on top of transparent objects.

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // TAA velocity
uniform sampler2D colortex3; // Light map
uniform sampler2D colortex4; // Specular map
uniform sampler2D colortex5; // r = height map, g = ao, b = Hand
uniform sampler2D colortex6; // r = water
uniform sampler2D colortex7; // Deferred output
uniform sampler2D colortex8; // Bloom output
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
varying float timeFactor;
varying vec3 sunPosNorm;
varying vec3 moonPosNorm;
varying vec3 upPosition;

void main() {
	vec3 deferredColor = texture2D(colortex7, texcoord).rgb;
	vec4 waterColor = texture2D(colortex0, texcoord);

	vec3 color = deferredColor;

	if(waterColor.a > 0.0) {
	// if(false) {
		float depth = linearDepth(texture2D(depthtex0, texcoord).r);
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
		vec4 lmcoord = texture2D(colortex3, texcoord);
		vec3 specularMap = texture2D(colortex4, texcoord).rgb;
		vec3 material = texture2D(colortex5, texcoord).rgb;

		vec3 viewPos = calcViewPos(viewVector, texture2D(depthtex0, texcoord).r);

		// Handle weather (and how it doesn't write to depth buffer)
		if(lmcoord.b > 0.0) {
			depth = linearDepth(lmcoord.b);
			waterColor.rgb *= adjustLightMapShadow(vec3(1.0), lmcoord.rg);
		}
		else {
			float NdotL = dot(normal, normalize(shadowLightPosition));

			#ifdef Shadow_On_Transparent
				vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
				vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
				float distortFactor = getDistortFactor(shadowPos.xy);
				shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
				shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
				shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NdotL); //apply shadow bias

				vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
			#else
				vec3 shadow = vec3(max(NdotL, 0.0));
			#endif
			// vec3 specular = shadow * calcSpecular(normal, depth, specularMap, texcoord, 64.0);

			// waterColor.rgb *= adjustLightMap(shadow, lmcoord.rg) + specular;
			// waterColor.rgb += specular;
			// waterColor *= material.g;

			if(texture2D(colortex6, texcoord).r > 0.0) {
				vec3 reflectDir = -reflect(normalize(viewVector), normal);
				waterColor.rgb *= getSkyColor(normalize(reflectDir), topSkyColor, bottomSkyColor, sunColor, sunBlurColor, sunPosNorm, upPosition, timeFactor);
				// deferredColor = mix(deferredColor, vec3(0.0, 0.05, 0.15), clamp(8.0 * (linearDepth(texture2D(depthtex1, texcoord).r) - depth) + 0.2, 0.0, 1.0));
				// deferredColor = waterColor.rgb;
			}

			#ifdef PBR_Lighting
				waterColor.rgb = PBRLighting(texcoord, normalize(viewVector), waterColor.rgb, normal, specularMap, material, lightmapSky(lmcoord.g) * shadow, lmcoord.rg);
			#else
				waterColor.rgb *= adjustLightMapShadow(shadow, lmcoord.rg);
			#endif

			waterColor.rgb = blendToFog(waterColor.rgb, viewPos, bottomSkyColor);
		}

		// waterColor.rgb = blendToFog(waterColor.rgb, viewPos.xyz, bottomSkyColor);

		color = mix(deferredColor, waterColor.rgb, waterColor.a);
		// vec3 color = deferredColor;

		// color = lmcoord.rgb;
		// color = normal;
		// color = material;
		// color = shadowPos;
		// color = viewPos.xyz;
		// color = vec3(linearDepth(depth));
		// color = vec3(abs(depth - texture2D(depthtex1, texcoord).r));
	}

/* DRAWBUFFERS:08 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor

	float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	gl_FragData[1] = vec4((brightness > Bloom_Threshold) ? color : texture2D(colortex8, texcoord).rgb, 1.0); // bloom
}
#version 120

#include "include.glsl"

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // View space position
uniform sampler2D colortex3; // Light map
uniform sampler2D colortex4; // Specular map
uniform sampler2D colortex5; // r = height map, g = ao, b = Hand
uniform sampler2D colortex6; // 
uniform sampler2D colortex7; // Deferred output
uniform sampler2D colortex8; // Bloom output
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 texcoord;

void main() {
	vec3 deferredColor = texture2D(colortex7, texcoord).rgb;
	vec4 waterColor = texture2D(colortex0, texcoord);

	vec3 color = deferredColor;

	if(waterColor.a > 0.0) {
	// if(false) {
		float depth = texture2D(depthtex0, texcoord).r;
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
		vec4 viewPos = texture2D(colortex2, texcoord);
		vec4 lmcoord = texture2D(colortex3, texcoord);
		vec3 specularMap = texture2D(colortex4, texcoord).rgb;
		vec3 material = texture2D(colortex5, texcoord).rgb;

		float NdotL = dot(normal, normalize(shadowLightPosition));

		vec4 playerPos = gbufferModelViewInverse * viewPos;
		vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
		float distortFactor = getDistortFactor(shadowPos.xy);
		shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
		shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
		shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NdotL); //apply shadow bias

		vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
		// vec3 specular = shadow * calcSpecular(normal, depth, specularMap, texcoord, 64.0);

		if(lmcoord.b != 0.0) {
			depth = lmcoord.b;
			shadow = vec3(1.0);
		}

		// waterColor.rgb *= adjustLightMap(shadow, lmcoord.rg) + specular;
		// waterColor.rgb += specular;
		// waterColor *= material.g;

		waterColor.rgb = PBRLighting(texcoord, depth, waterColor.rgb, normal, specularMap, material, 2.0 * lightmapSky(lmcoord.g) * shadow, lmcoord.rg);

		waterColor.rgb = blendToFog(waterColor.rgb, depth);

		color = mix(deferredColor, waterColor.rgb, waterColor.a);
	}
	// vec3 color = deferredColor;

	// color = lmcoord.rgb;
	// color = normal;
	// color = material;
	// color = shadowPos;
	// color = vec3(linearDepth(depth));
	// color = vec3(abs(depth - texture2D(depthtex1, texcoord).r));

/* DRAWBUFFERS:08 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor

	float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	gl_FragData[1] = vec4((brightness > 1.1) ? color : texture2D(colortex8, texcoord).rgb, 1.0); // bloom
}
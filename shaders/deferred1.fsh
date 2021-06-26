#version 120

#include "include.glsl"

#define Shadow_On_Opaque

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // view space position
uniform sampler2D colortex3; // Light map
uniform sampler2D colortex4; // Specular map
uniform sampler2D colortex5; // r = height map, g = ao, b = Hand
uniform sampler2D colortex6; // SSAO
uniform sampler2D colortex7; // Deferred output
uniform sampler2D colortex8; // Bloom output
uniform sampler2D colortex9; // Native normal
uniform sampler2D depthtex0;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 texcoord;

void main() {
	float depth = texture2D(depthtex0, texcoord).r;
	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
	vec4 viewPos = texture2D(colortex2, texcoord);
	vec4 lmcoord = texture2D(colortex3, texcoord);
	vec3 specularMap = texture2D(colortex4, texcoord).rgb;
	vec3 material = texture2D(colortex5, texcoord).rgb;

	if(lmcoord.a == 0.0) {
		gl_FragData[0] = vec4(color, 1.0);
		return;
	}

	#if SSAO != 0
		vec2 texelSize = 1.0 / vec2(viewWidth, viewHeight);
		float occlusion = 0.0;
		for (int x = -2; x < 2; ++x) 
		{
			for (int y = -2; y < 2; ++y) 
			{
				vec2 offset = vec2(float(x), float(y)) * texelSize;
				occlusion += texture2D(colortex6, texcoord + offset).r;
			}
		}
		occlusion /= 16.0;
	#else
		float occlusion = material.g;
	#endif


	float NdotL = dot(normal, normalize(shadowLightPosition));

	#ifdef Shadow_On_Opaque
		vec4 playerPos = gbufferModelViewInverse * viewPos;
		vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
		float distortFactor = getDistortFactor(shadowPos.xy);
		shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
		shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
		shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NdotL); //apply shadow bias

		vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
	#else
		vec3 shadow = vec3(max(NdotL, 0.0));
	#endif
	// vec3 specular = shadow * calcSpecular(normal, depth, specularMap, texcoord, 16.0);

	// color *= min(adjustLightMap(shadow, lmcoord.rg), vec3(material.g)) + specular;
	// color += specular;
	// color *= material.g;

	#ifdef PBR_Lighting
		color = PBRLighting(texcoord, depth, color, normal, specularMap, vec3(material.r, occlusion, material.b), lightmapSky(lmcoord.g) * shadow, lmcoord.rg);
	#else
		color *= adjustLightMapShadow(shadow, lmcoord.rg);
	#endif
	// color *= occlusion;

	color = blendToFog(color, depth);

	// color = texture2D(shadowtex0, texcoord).rgb;
	// color = texture2D(shadowtex0, shadowPos.xy).rgb;
	// color = vec3(linearDepth(depth));
	// color = vec3(shadowPos.z);
	// color = vec3(shadowPos.z - shadowDepth);
	// color = shadowPos.xyz;
	// color = vec3(shadow);
	// color = normal;
	// color = vec3(lmcoord.rg, 0.0);
	// color = lmcoord.rgb;
	// color = specularMap;
	// color = material;
	// color = shadow;
	// color = viewPos.xyz;
	// color = vec3(viewPos.z * -1.0);
	// color = vec3(material.g);
	// color = vec3(occlusion);
	// color = texture2D(colortex0, texcoord).rgb;
	// color = vec3(mod(texcoord.x * viewWidth, 16.0) / 16.0, mod(texcoord.y * viewHeight, 16.0) / 16.0, 0.0);
	// color = vec3(dot(getCameraVector(depth, texcoord), normalize(-shadowLightPosition)));
	// color = vec3(specularMap.g == 230.0/255.0);
	// color = vec3((specularMap.g - 229.0 / 255.0) * 255.0 / 8.0);
	// color = vec3((specularMap.b < 64.9 / 255.0) ? specularMap.b * 2.0 : 0.0);

	// vec3 lightDir = normalize(shadowLightPosition);
    // vec3 viewDir = getCameraVector(depth, texcoord);
    // vec3 halfwayDir = normalize(viewDir + lightDir);
	// color = vec3(dot(normal, halfwayDir));
	// float mult = material.r * 1.0 + wetness * 0.2;
    // color = vec3(mult * pow(max(dot(normal, halfwayDir), 0.0), 64.0)) * shadow;

/* DRAWBUFFERS:78 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor

	float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
	gl_FragData[1] = vec4((brightness > Bloom_Threshold) ? color : texture2D(colortex8, texcoord).rgb, 1.0);
}
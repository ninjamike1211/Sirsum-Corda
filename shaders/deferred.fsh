#version 120

#include "include.glsl"

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // view space position
uniform sampler2D colortex3; // Light map
uniform sampler2D colortex4; // Specular map
uniform sampler2D colortex5; // r = height map, g = ao, b = Hand
uniform sampler2D colortex6; // 
uniform sampler2D colortex7; // Deferred output
uniform sampler2D colortex8; // Bloom output
uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 texcoord;

const vec3 aoKernel[64] = vec3[64](
	vec3(-0.034980517, -0.07308654, 0.058606513),
	vec3(0.03756984, -0.072102696, 0.0585978),
	vec3(0.06918004, 0.034017343, 0.065065324),
	vec3(-0.005725489, -0.017689845, 0.10026818),
	vec3(-0.0024451462, -0.10229702, 0.015646892),
	vec3(-0.031925168, -0.02320752, 0.09783151),
	vec3(-0.06793229, 0.05529296, 0.063027725),
	vec3(-0.01209211, 0.043860555, 0.10099145),
	vec3(0.10555697, 0.008753485, 0.042324428),
	vec3(0.081875466, -0.048372656, 0.069518544),
	vec3(-0.02898162, -0.0020893984, 0.11846109),
	vec3(-0.10734179, -0.038997177, 0.054600425),
	vec3(0.001121658, 0.10839674, 0.07468697),
	vec3(0.0382355, -0.13062601, 0.016750216),
	vec3(-0.10653227, -0.024923487, 0.09218294),
	vec3(0.020593332, -0.10940843, 0.09968734),
	vec3(0.10870629, -0.05270174, 0.09909357),
	vec3(-0.101664364, 0.07077516, 0.10671365),
	vec3(-0.09397825, -0.13871153, 0.03512405),
	vec3(-0.07309548, -0.010214948, 0.16342837),
	vec3(-0.13357458, -0.060898818, 0.11726911),
	vec3(-0.1812479, 0.0051940037, 0.07675678),
	vec3(-0.13638212, 0.09606439, 0.12145328),
	vec3(0.081188925, 0.14238939, 0.14103664),
	vec3(0.14691381, 0.08068207, 0.15243787),
	vec3(0.12507543, 0.09452677, 0.17817385),
	vec3(-0.029932378, -0.15652287, 0.19072066),
	vec3(0.16865447, -0.18223238, 0.07772384),
	vec3(0.18051505, 0.13493875, 0.15275605),
	vec3(-0.02180126, 0.22166462, 0.17746793),
	vec3(0.138826, 0.2622502, 0.024689237),
	vec3(0.15371771, 0.11623063, 0.2442952),
	vec3(0.13526349, 0.2697097, 0.12077029),
	vec3(0.1313422, 0.31269744, 0.009053342),
	vec3(-0.0022185133, 0.31079093, 0.16947818),
	vec3(-0.273788, -0.19623113, 0.15105066),
	vec3(-0.16376108, 0.298388, 0.17941986),
	vec3(-0.197984, -0.21250074, 0.27620816),
	vec3(0.32193616, 0.15964846, 0.21212348),
	vec3(-0.029422954, -0.3082821, 0.30435112),
	vec3(-0.112089105, 0.019694295, 0.4369861),
	vec3(-0.27036008, -0.37540528, 0.07921735),
	vec3(-0.44118622, -0.17253464, 0.115490176),
	vec3(0.3170158, 0.014442723, 0.39446947),
	vec3(-0.3384772, 0.34697533, 0.20267364),
	vec3(0.45703468, 0.06094783, 0.29046714),
	vec3(-0.37736368, -0.24280304, 0.34322315),
	vec3(-0.21585187, -0.4170773, 0.3494561),
	vec3(0.008988276, 0.3492018, 0.49549612),
	vec3(0.26397067, 0.3077667, 0.47899377),
	vec3(0.15404774, -0.57045406, 0.26918998),
	vec3(0.48351988, 0.40117705, 0.23704346),
	vec3(0.10314443, -0.6246343, 0.2846478),
	vec3(-0.10114718, -0.5171652, 0.48652062),
	vec3(-0.5003709, -0.24524792, 0.48800862),
	vec3(-0.54776156, -0.43065378, 0.3149907),
	vec3(0.1332165, -0.53897214, 0.56069785),
	vec3(-0.15972456, 0.39317474, 0.69449353),
	vec3(-0.688053, 0.18012664, 0.44533956),
	vec3(0.7846323, 0.08730391, 0.3531672),
	vec3(-0.6566118, 0.50826424, 0.32316768),
	vec3(-0.32328036, 0.2777686, 0.8126062),
	vec3(0.56942135, -0.6181151, 0.43129668),
	vec3(-0.84336746, -0.41986006, 0.2396183)
);

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

	float NdotL = dot(normal, normalize(shadowLightPosition));

	vec4 playerPos = gbufferModelViewInverse * viewPos;
	vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos.xy);
	shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
	shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
	shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NdotL); //apply shadow bias

	vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
	// vec3 specular = shadow * calcSpecular(normal, depth, specularMap, texcoord, 16.0);

	// color *= min(adjustLightMap(shadow, lmcoord.rg), vec3(material.g)) + specular;
	// color += specular;
	// color *= material.g;

	// vec3 rvec = texture2D(noisetex, texcoord).xyz * 2.0 - 1.0;
	vec3 rvec = vec3(1.0);
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);

	// vec4 fragPos = vec4(texcoord, linearDepth(depth), 1.0);
	// fragPos *= gbufferProjectionInverse;
	// fragPos.xyz /= fragPos.w;
	vec3 fragPos = getCameraVector(depth, texcoord) * linearDepth(depth);


	float occlusion = 0.0;
	float radius = 0.05;
	for (int i = 0; i < 64; i++) {
		// get sample position:
		vec3 sample = tbn * aoKernel[i];
		sample = sample * radius + fragPos.xyz;
		
		// project sample position:
		vec4 offset = vec4(sample, 1.0);
		offset = gbufferProjection * offset;
		offset.xy /= offset.w;
		offset.xy = offset.xy * 0.5 + 0.5;
		
		// get sample depth:
		float sampleDepth = linearDepth(texture2D(depthtex0, offset.xy).r);
		
		// range check & accumulate:
		// float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z + sampleDepth));
		// float rangeCheck= abs(fragPos.z - sampleDepth) < radius ? 1.0 : 0.0;
		float rangeCheck = 1.0;
		occlusion += (sampleDepth <= sample.z ? 1.0 : 0.0) * rangeCheck;
	}

	occlusion /= 64.0;

	color = PBRLighting(texcoord, depth, color, normal, specularMap, material, 2.0 * lightmapSky(lmcoord.g) * shadow, lmcoord.rg);

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
	// color = vec3(0.0);
	// color = specularMap;
	// color = material;
	// color = shadow;
	// color = viewPos.xyz;
	// color = vec3(viewPos.z * -1.0);
	// color = vec3(material.g);
	// color = vec3(occlusion);
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
	gl_FragData[1] = vec4((brightness > 1.1) ? color : texture2D(colortex8, texcoord).rgb, 1.0);
}
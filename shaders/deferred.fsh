#version 120

#include "include.glsl"

uniform sampler2D colortex0; // Albedo
uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // Shadow map texture coordinates
uniform sampler2D colortex3; // Light map
uniform sampler2D colortex4; // Specular map
uniform sampler2D colortex5; // r = height map, g = ao, b = Hand
uniform sampler2D colortex6; // 
uniform sampler2D colortex7; // Deferred output
uniform sampler2D depthtex0;

varying vec2 texcoord;

void main() {
	float depth = texture2D(depthtex0, texcoord).r;
	vec3 color = texture2D(colortex0, texcoord).rgb;
	vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
	vec3 shadowPos = texture2D(colortex2, texcoord).xyz;
	vec4 lmcoord = texture2D(colortex3, texcoord);
	vec3 specularMap = texture2D(colortex4, texcoord).rgb;
	vec3 material = texture2D(colortex5, texcoord).rgb;

	if(lmcoord.a == 0.0) {
		gl_FragData[0] = vec4(color, 1.0);
		return;
	}

	float NdotL = dot(normal, normalize(shadowLightPosition));

	vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
	// vec3 specular = shadow * calcSpecular(normal, depth, specularMap, texcoord, 16.0);

	// color *= min(adjustLightMap(shadow, lmcoord.rg), vec3(material.g)) + specular;
	// color += specular;
	// color *= material.g;

	color = PBRLighting(texcoord, depth, color, normal, specularMap, material, 2.0 * lightmapSky(lmcoord.g) * shadow, lmcoord.rg);

	color = blendToFog(color, depth);

	// color = texture2D(shadowtex0, texcoord).rgb;
	// color = texture2D(shadowtex0, shadowPos.xy).rgb;
	// color = vec3(depth* 0.5);
	// color = vec3(shadowPos.z);
	// color = vec3(shadowPos.z - shadowDepth);
	// color = shadowPos.xyz;
	// color = vec3(shadowVal);
	// color = normal;
	// color = vec3(lmcoord.rg, 0.0);
	// color = lightmap(lmcoord);
	// color = vec3(0.0);
	// color = specularMap;
	// color = material;
	// color = vec3(material.g);
	// color = vec3(dot(getCameraVector(depth, texcoord), normalize(-shadowLightPosition)));
	// color = vec3(specularMap.g == 230.0/255.0);
	// color = vec3((specularMap.g - 229.0 / 255.0) * 255.0 / 8.0);

	// vec3 lightDir = normalize(shadowLightPosition);
    // vec3 viewDir = getCameraVector(depth, texcoord);
    // vec3 halfwayDir = normalize(viewDir + lightDir);
	// color = vec3(dot(normal, halfwayDir));
	// float mult = material.r * 1.0 + wetness * 0.2;
    // color = vec3(mult * pow(max(dot(normal, halfwayDir), 0.0), 64.0)) * shadow;

/* DRAWBUFFERS:7 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
#version 120

#include "include.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

varying vec2 texcoord;

void main() {
	vec3 deferredColor = texture2D(colortex7, texcoord).rgb;
	vec4 waterColor = texture2D(colortex0, texcoord);

	float depth = texture2D(depthtex0, texcoord).r;
	vec3 normal = texture2D(colortex1, texcoord).xyz * 2.0 - 1.0;
	vec3 shadowPos = texture2D(colortex2, texcoord).xyz;
	vec4 lmcoord = texture2D(colortex3, texcoord);
	vec3 material = texture2D(colortex4, texcoord).rgb;

	float NdotL = dot(normal, normalize(shadowLightPosition));

	vec3 shadow = calculateShadow(shadowPos, NdotL, texcoord);
	vec3 specular = shadow * calcSpecular(normal, depth, material, texcoord, 64.0);

	if(lmcoord.b != 0.0) {
		depth = lmcoord.b;
		shadow = vec3(1.0);
	}

	waterColor.rgb *= adjustLightMap(shadow, lmcoord.rg);
	waterColor.rgb += specular;

	waterColor.rgb = blendToFog(waterColor.rgb, depth);

	vec3 color = mix(deferredColor, waterColor.rgb, waterColor.a);
	// vec3 color = deferredColor;

	// color = lmcoord.rgb;
	// color = normal;
	// color = material;
	// color = shadowPos;
	// color = vec3(linearDepth(depth));
	// color = vec3(abs(depth - texture2D(depthtex1, texcoord).r));

/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
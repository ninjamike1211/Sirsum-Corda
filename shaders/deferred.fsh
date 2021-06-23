#version 120

#include "include.glsl"

uniform sampler2D colortex1; // Normal
uniform sampler2D colortex2; // view space position
uniform sampler2D colortex6; // SSAO output
uniform sampler2D colortex9; // SSAO noise texture
uniform sampler2D depthtex0; // depth

varying vec2 texcoord;

void main() {
	/* DRAWBUFFERS:6 */
	#ifdef SSAO
		float depth = texture2D(depthtex0, texcoord).r;
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);
		vec4 viewPos = texture2D(colortex2, texcoord);

		float occlusion = calcSSAO(viewPos.xyz, normal, texcoord, colortex2, colortex9);

		gl_FragData[0] = vec4(occlusion, 0.0, 0.0, 1.0); // SSAO output
	#endif
}
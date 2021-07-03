#version 120

#include "include.glsl"

uniform sampler2D colortex1; // Normal
uniform sampler2D colortex6; // SSAO output
uniform sampler2D colortex9; // SSAO noise texture
uniform sampler2D depthtex0; // depth

varying vec2 texcoord;

void main() {
	/* DRAWBUFFERS:6 */
	#if SSAO != 0
		float depth = texture2D(depthtex0, texcoord).r;
		vec3 normal = normalize(texture2D(colortex1, texcoord).xyz * 2.0 - 1.0);

		float occlusion = calcSSAO(normal, texcoord, depthtex0, colortex9);

		gl_FragData[0] = vec4(occlusion, 0.0, 0.0, 1.0); // SSAO output
	#endif
}
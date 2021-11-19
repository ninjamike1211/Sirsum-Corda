#version 120

#include "include.glsl"

uniform sampler2D colortex2; 	// Normal
// uniform sampler2D colortex6; // SSAO output
uniform sampler2D colortex9; 	// SSAO noise texture
uniform sampler2D depthtex0; 	// depth

varying vec3 viewVector;
varying vec2 texcoord;

void main() {
	/* DRAWBUFFERS:6 */
	#if SSAO == 1 || SSAO == 3
		float depth = texture2D(depthtex0, texcoord).r;

		#ifdef Combine_Normal_Buffers
			vec3 normal = normalize(decodeNormal(texture2D(colortex1, texcoord).ba));
		#else
			vec3 normal = normalize(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0);
		#endif

		// float occlusion = calcSSAO(normal, viewVector, texcoord, depthtex0, colortex9);
		float occlusion = (length(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0) > 0.9) ? calcSSAO(normal, viewVector, texcoord, depthtex0, colortex9) : 1.0;

		gl_FragData[0] = vec4(0.0, occlusion, 0.0, 1.0); // SSAO output

	#endif
}
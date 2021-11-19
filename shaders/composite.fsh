#version 120

#include "include.glsl"

uniform sampler2D colortex2; // Normal
uniform sampler2D colortex3; // b = weather
uniform sampler2D colortex6; // SSAO output
uniform sampler2D colortex9; // SSAO noise texture
uniform sampler2D depthtex0; // depth

varying vec3 viewVector;
varying vec2 texcoord;

void main() {
	/* DRAWBUFFERS:6 */

// ----------------------- SSAO --------------------------
	#if SSAO > 1
		float isWeather = texture2D(colortex3, texcoord).b;
		float depth = texture2D(depthtex0, texcoord).r;
		float occlusion = 1.0;
		
		if(isWeather < 0.1 && depth < 1.0) {
			#ifdef Combine_Normal_Buffers
				vec3 normal = normalize(decodeNormal(texture2D(colortex2, texcoord).rg));
			#else
				vec3 normal = normalize(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0);
			#endif

			// occlusion = (length(normal) > 0.1) ? 0.0 : 1.0;
			if(length(texture2D(colortex2, texcoord).xyz * 2.0 - 1.0) > 0.9)
				occlusion = calcSSAO(normal, viewVector, texcoord, depthtex0, colortex9);
		}

		gl_FragData[0] = vec4(texture2D(colortex6, texcoord).r, occlusion, 0.0, 1.0); // SSAO output
	#endif
}
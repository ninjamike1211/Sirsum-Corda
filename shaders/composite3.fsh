#version 120

#include "include.glsl"

#define Bloom_Amount 0.5 //Amount of bloom added. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

uniform sampler2D colortex0;
uniform sampler2D colortex8;

varying vec2 texcoord;
varying vec3 vectorPoints[30];

/* DRAWBUFFERS:0 */
void main() {

// ---------------------------Bloom---------------------------
	#ifdef bloom
		vec2 tex_offset = Bloom_Spread / vec2(viewWidth, viewHeight); // gets size of single texel
		vec3 color = texture2D(colortex8, texcoord).rgb * bloomWeight[0]; // current fragment's contribution

		for(int i = 1; i < bloomWeight.length(); ++i) {
			color += texture2D(colortex8, texcoord + vec2(0.0, tex_offset.y * i)).rgb * bloomWeight[i];
			color += texture2D(colortex8, texcoord - vec2(0.0, tex_offset.y * i)).rgb * bloomWeight[i];
		}

		float brightness = pow(dot(color, vec3(0.25, 0.4, 0.5)), 2.2);
		color = texture2D(colortex0, texcoord).rgb + pow(/* brightness * */ 0.1 * Bloom_Amount * color, vec3(1.0));

	#else
		vec3 color = texture2D(colortex0, texcoord).rgb;
	#endif

	gl_FragData[0] = vec4(color, 1.0);
}
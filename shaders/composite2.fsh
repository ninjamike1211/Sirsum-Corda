#version 120

//#define bloom
#define Bloom_Amount 0.5 //Amount of bloom added. [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

uniform sampler2D colortex0;
uniform sampler2D colortex8;
uniform float viewWidth;
uniform float viewHeight;

varying vec2 texcoord;

const float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

/* DRAWBUFFERS:0 */
void main() {
	#ifdef bloom
		vec2 tex_offset = 1.0 / vec2(viewWidth, viewHeight); // gets size of single texel
		vec3 color = texture2D(colortex8, texcoord).rgb * weight[0]; // current fragment's contribution

		for(int i = 1; i < 5; ++i) {
			color += texture2D(colortex8, texcoord + vec2(0.0, tex_offset.y * i)).rgb * weight[i];
			color += texture2D(colortex8, texcoord - vec2(0.0, tex_offset.y * i)).rgb * weight[i];
		}

		color = texture2D(colortex0, texcoord).rgb + Bloom_Amount * color;

		gl_FragData[0] = vec4(color, 1.0); //gcolor
	#else
		gl_FragData[0] = texture2D(colortex0, texcoord);
	#endif
}
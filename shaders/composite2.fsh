#version 120

//#define bloom

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

		color = texture2D(colortex0, texcoord).rgb + 0.5 * color;

		gl_FragData[0] = vec4(color, 1.0); //gcolor
	#else
		gl_FragData[0] = texture2D(colortex0, texcoord);
	#endif
}
#version 120

//#define bloom
#define dof_enable
#define blurSize 1.0 		//[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define hexagon_blur
#define hand_blur
#define near_blur
//#define distance_blur
#define distance_blur_distance 0.0 //[0.0 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define max_blur 0.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
// #define water_blur

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D colortex5;
uniform sampler2D colortex8;
uniform sampler2D depthtex0;
uniform float viewWidth;
uniform float viewHeight;
uniform float centerDepthSmooth;
uniform float near;
uniform float far;

varying vec2 texcoord;

const float centerDepthHalflife = 1.0;	//[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0]
const float weight[5] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);

float linearDepth(float depth) {
	depth = depth * 2.0 - 1.0;
	depth = (2.0 * near * far) / (far + near - depth * (far - near));
	return min(depth / far, 1.0);
}

/* DRAWBUFFERS:089 */
void main() {
	#ifdef bloom
		vec2 tex_offset = 1.0 / vec2(viewWidth, viewHeight); // gets size of single texel
		vec3 color = texture2D(colortex8, texcoord).rgb * weight[0]; // current fragment's contribution

		for(int i = 1; i < 5; ++i) {
			color += texture2D(colortex8, texcoord + vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
			color += texture2D(colortex8, texcoord - vec2(tex_offset.x * i, 0.0)).rgb * weight[i];
		}

		gl_FragData[1] = vec4(color, 1.0); //gcolor
	#endif

	#ifdef dof_enable
		float hand = texture2D(colortex5, texcoord).b;
		float depth = linearDepth(texture2D(depthtex0, texcoord).x);

		vec4 lmcoord = texture2D(colortex3, texcoord);
		if(lmcoord.b != 0.0)
			depth = linearDepth(lmcoord.b);

		#ifdef water_blur
			float centerDepth = linearDepth(texture2D(depthtex0, vec2(0.5, 0.5)).r);
		#else
			float centerDepth = linearDepth(centerDepthSmooth);
		#endif

		#ifdef distance_blur
			//float CoC = max((depth-1.0) / (1.0 - distance_blur_distance) + 1.0, 0.0);
			float CoC = max(blurSize * (depth - distance_blur_distance), 0.0);
		#else
			//float focalLength = 1.0 / (1.0 / centerDepth + 1.0 / blurPower);
			//float CoC = -blurSize * (focalLength * (centerDepth - depth)) / (depth * (centerDepth - focalLength));
			float CoC = blurSize * (depth - centerDepth) * (1.0 - centerDepth);
			//float CoC = blurSize * ((depth * depth - 1.0) / (1.0 - linearDepth(centerDepthSmooth)) + 1.0);
		#endif

		CoC = min(CoC, max_blur);

		#ifndef hand_blur
			if(hand == 1.0)
				CoC = 0.0;
		#endif

		#ifndef near_blur
			if(hand != 1.0)
				CoC = max(CoC, 0.0);
		#endif

		gl_FragData[2] = vec4(abs(CoC), 0.0, 0.0, 1.0);
	#endif
	
	gl_FragData[0] = texture2D(colortex0, texcoord);
}
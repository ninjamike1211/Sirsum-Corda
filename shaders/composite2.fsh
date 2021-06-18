#version 120

#define dof_enable
#define blurSize 1.0 		//[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]
//#define hexagon_blur
#define hand_blur
#define near_blur
//#define distance_blur
#define distance_blur_distance 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define water_blur

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex8;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform float centerDepthSmooth;
uniform float aspectRatio;
uniform float near;
uniform float far;

varying vec2 texcoord;

const float centerDepthHalflife = 1.0;	//[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0]

const vec2 kernel[] = vec2[](
	#ifndef hexagon_blur
		vec2(0.36363637,0),
		vec2(0.22672357,0.28430238),
		vec2(-0.08091671,0.35451925),
		vec2(-0.32762504,0.15777594),
		vec2(-0.32762504,-0.15777591),
		vec2(-0.08091656,-0.35451928),
		vec2(0.22672352,-0.2843024),
		vec2(0.6818182,0),
		vec2(0.614297,0.29582983),
		vec2(0.42510667,0.5330669),
		vec2(0.15171885,0.6647236),
		vec2(-0.15171883,0.6647236),
		vec2(-0.4251068,0.53306687),
		vec2(-0.614297,0.29582986),
		vec2(-0.6818182,0),
		vec2(-0.614297,-0.29582983),
		vec2(-0.42510656,-0.53306705),
		vec2(-0.15171856,-0.66472363),
		vec2(0.1517192,-0.6647235),
		vec2(0.4251066,-0.53306705),
		vec2(0.614297,-0.29582983),
		vec2(1.,0),
		vec2(0.9555728,0.2947552),
		vec2(0.82623875,0.5633201),
		vec2(0.6234898,0.7818315),
		vec2(0.36534098,0.93087375),
		vec2(0.07473,0.9972038),
		vec2(-0.22252095,0.9749279),
		vec2(-0.50000006,0.8660254),
		vec2(-0.73305196,0.6801727),
		vec2(-0.90096885,0.43388382),
		vec2(-0.98883086,0.14904208),
		vec2(-0.9888308,-0.14904249),
		vec2(-0.90096885,-0.43388376),
		vec2(-0.73305184,-0.6801728),
		vec2(-0.4999999,-0.86602545),
		vec2(-0.222521,-0.9749279),
		vec2(0.07473029,-0.99720377),
		vec2(0.36534148,-0.9308736),
		vec2(0.6234897,-0.7818316),
		vec2(0.8262388,-0.56332),
		vec2(0.9555729,-0.29475483)
	
	#else
		vec2(.666667, 0.),
		vec2(.5, .288675),
		vec2(.333333, .577350),
		vec2(0., .577350),
		vec2(-.333333, .577350),
		vec2(-.5, .288675),
		vec2(-.666667, 0.),
		vec2(-.5, -.288675),
		vec2(-.333333, -.577350),
		vec2(0., -.577350),
		vec2(.333333, -.577350),
		vec2(.5, -.288675),
		vec2(.333333, 0.),
		vec2(.166667, .288675),
		vec2(-.166667, .288675),
		vec2(-.333333, 0.),
		vec2(-.166667, -.288675),
		vec2(.166667, -.288675),
		vec2(1., 0.),
		vec2(.5, .866025),
		vec2(-.5, .866025),
		vec2(-1., 0.),
		vec2(-.5, -.866025),
		vec2(.5, -.866025),
		vec2(.833333, .288675),
		vec2(.666667, .577350),
		vec2(.166667, .866025),
		vec2(-.166667, .866025),
		vec2(-.833333, .288675),
		vec2(-.666667, .577350),
		vec2(.833333, -.288675),
		vec2(.666667, -.577350),
		vec2(.166667, -.866025),
		vec2(-.166667, -.866025),
		vec2(-.833333, -.288675),
		vec2(-.666667, -.577350)
	#endif
);

const vec2 shadowKernel[] = vec2[](
	vec2(0., 0.),
	vec2(1., 0.),
	vec2(-1., 0.),
	vec2(0.30901697, 0.95105654),
	vec2(-0.30901664, -0.9510566),
	vec2(0.54545456, 0),
	vec2(0.16855472, 0.5187581),
	vec2(-0.44128203, 0.3206101),
	vec2(-0.44128197, -0.3206102),
	vec2(0.1685548, -0.5187581),
	vec2(0.809017, 0.58778524),
	vec2(-0.30901703, 0.9510565),
	vec2(-0.80901706, 0.5877852),
	vec2(-0.80901694, -0.58778536),
	vec2(0.30901712, -0.9510565),
	vec2(0.80901694, -0.5877853)
);

float linearDepth(float depth) {
	depth = depth * 2.0 - 1.0;
	depth = (2.0 * near * far) / (far + near - depth * (far - near));
	return min(depth / far, 1.0);
}

void main() {
	vec3 color = texture2D(colortex0, texcoord).rgb;

	#ifdef dof_enable

		float depth = texture2D(depthtex0, texcoord).x;

		float CoC = 0.0;
		float CoCWeight = 0.0;
		
		for(int i = 0; i < shadowKernel.length(); i++) {
			vec2 pos = texcoord + vec2(0.003, 0.003 * aspectRatio) * shadowKernel[i];
			if(depth >= texture2D(depthtex0, pos).x) {
				CoC += texture2D(colortex8, pos).r;
				CoCWeight++;
			}
		}

		CoC /= CoCWeight;

		float weight = 1.0;

		for(int i = 0; i < kernel.length(); i++) {
			vec2 pos = texcoord + (kernel[i] * CoC * vec2(0.01, 0.01 * aspectRatio));
			color += texture2D(colortex0, pos).rgb;
		}

		color /= kernel.length();
	#endif


/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
	//gl_FragData[0] = vec4(CoC, 0.0, 0.0, 1.0);
	//gl_FragData[0] = vec4(texture2D(gaux3, texcoord).rgb, 1.0);
}
#version 120

varying vec2 texcoord;

void main() {

/* DRAWBUFFERS:01234 */
	gl_FragData[0] = vec4(0.0, 0.0, 0.0, 0.0);
	gl_FragData[1] = vec4(0.0, 0.0, 0.0, 0.0);
	gl_FragData[2] = vec4(0.0, 0.0, 0.0, 0.0);
	gl_FragData[3] = vec4(0.0, 0.0, 0.0, 0.0);
	gl_FragData[4] = vec4(0.0, 0.0, 0.0, 0.0);
}
#version 120

uniform mat4 gbufferProjectionInverse;

varying vec2 texcoord;
varying vec3 viewVector;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

	vec4 ray = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;
}
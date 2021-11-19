#version 120

uniform mat4 gbufferProjectionInverse;

varying vec3 viewVector;
varying vec2 TexCoords;

void main() {
	gl_Position = ftransform();
	TexCoords = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	vec4 ray = gbufferProjectionInverse * vec4(TexCoords * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;
}
#version 120

#include "include.glsl"

uniform vec3 cameraPosition;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 velocity;
varying mat3 tbn;

attribute vec4 at_tangent;
attribute vec4 mc_Entity;
attribute vec3 at_velocity;
attribute vec2 mc_midTexCoord;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	velocity = at_velocity;

	float blockType = getBlockType(mc_Entity.x);
	vec4 vertexPos = gl_Vertex + vec4(waveOffset(blockType, gl_Vertex.xyz + cameraPosition, texcoord, mc_midTexCoord, gl_Normal), 0.0);
	gl_Position = gl_ModelViewProjectionMatrix * vertexPos;
	
	vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
	tbn = mat3(tangent.x, binormal.x, normal.x,
					 tangent.y, binormal.y, normal.y,
					 tangent.z, binormal.z, normal.z);
}
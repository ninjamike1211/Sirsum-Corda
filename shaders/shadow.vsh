#version 120

#include "include.glsl"

uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float isWater;
varying mat3 tbn;
varying vec4 glVertex;
varying vec4 textureBounds;
// varying vec4 clipPos;
varying vec3 viewPos;
varying vec4 vertexPos;

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec4 at_tangent;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	glVertex = gl_Vertex;

	vertexPos = gl_Vertex + vec4(waveOffset(getBlockType(mc_Entity.x), gl_Vertex.xyz + cameraPosition, texcoord, mc_midTexCoord, gl_Normal), 0.0);

	isWater = float(mc_Entity.y == 1);
	gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + vec4(waveOffset(getBlockType(mc_Entity.x), gl_Vertex.xyz + cameraPosition, texcoord, mc_midTexCoord, gl_Normal), 0.0));
	gl_Position.xyz = distort(gl_Position.xyz);

	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	// clipPos = gl_ProjectionMatrix * vec4(viewPos, 1.0);

	// clipPos = gl_Position;

	vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
	tbn = mat3(	tangent.x, binormal.x, normal.x,
				tangent.y, binormal.y, normal.y,
				tangent.z, binormal.z, normal.z);

	vec2 halfSize = abs(texcoord - mc_midTexCoord);
	textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);
}
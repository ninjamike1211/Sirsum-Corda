#version 120

#include "include.glsl"

uniform vec3 cameraPosition;

varying mat3 tbn;
varying vec2 texcoord;
varying vec2 vineTexcoord;
varying float verticalOffset;
varying vec2 lmcoord;
varying vec3 velocity;
varying vec4 glcolor;
varying vec3 viewPos;
varying vec4 textureBounds;
varying float blockType;

attribute vec4 at_tangent;
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
attribute vec3 at_velocity;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
	velocity = at_velocity;

	vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
	tbn = mat3(	tangent.x, binormal.x, normal.x,
				tangent.y, binormal.y, normal.y,
				tangent.z, binormal.z, normal.z);

	blockType = getBlockType(mc_Entity.x);
	vec4 vertexPos = gl_Vertex + vec4(waveOffset(blockType, gl_Vertex.xyz + cameraPosition, texcoord, mc_midTexCoord, gl_Normal), 0.0);

	viewPos = (gl_ModelViewMatrix * vertexPos).xyz;

	// if(blockType > 1.9 && blockType < 2.1) {
	// 	viewPos += vec3(0.0, 0.0, 0.5) * tbn;
	// }

	// vec2 jitter = getJitter();
	// mat4 jitterProjection = gl_ProjectionMatrix;
	// jitterProjection[3][0] += jitter.x;
	// jitterProjection[3][1] += jitter.y;
	// gl_Position = (jitterProjection * gl_ModelViewMatrix * vertexPos);

	gl_Position = gl_ProjectionMatrix * vec4(viewPos, 1.0);
	

	// gl_Position = ftransform();
	// gl_Position.xy += getJitter();

	vec2 halfSize = abs(texcoord - mc_midTexCoord);
	textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);

	vineTexcoord = vec2(float(texcoord.x > mc_midTexCoord.x), float(texcoord.y > mc_midTexCoord.y));
	verticalOffset = gl_Vertex.y + cameraPosition.y;

}
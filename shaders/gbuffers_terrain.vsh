#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying mat3 tbn;
varying vec4 shadowPos;

attribute vec4 at_tangent;
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

#include "include.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	float blockType = getBlockType(mc_Entity.x);
	gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + vec4(waveOffset(blockType, gl_Vertex, texcoord, mc_midTexCoord, gl_Normal), 0.0));

	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	shadowPos = shadowProjection * (shadowModelView * playerPos); //convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos.xy);
	shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
	shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
	shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(lightDot); //apply shadow bias
		
	shadowPos.w = lightDot;

	vec3 normal = gl_NormalMatrix * gl_Normal;
    vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
	vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
	tbn = mat3(tangent.x, binormal.x, normal.x,
					 tangent.y, binormal.y, normal.y,
					 tangent.z, binormal.z, normal.z);
}
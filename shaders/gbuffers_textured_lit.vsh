#version 120

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 normal;
varying vec4 shadowPos;

attribute vec4 at_tangent;

#include "include.glsl"

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));

	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

	vec4 playerPos = gbufferModelViewInverse * viewPos;
	shadowPos = shadowProjection * (shadowModelView * playerPos); //convert to shadow screen space
	float distortFactor = getDistortFactor(shadowPos.xy);
	shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
	shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
	shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(lightDot); //apply shadow bias
		
	shadowPos.w = lightDot;
	gl_Position = gl_ProjectionMatrix * viewPos;

	normal = gl_NormalMatrix * gl_Normal;
}
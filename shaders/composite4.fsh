#version 120

#include "include.glsl"

uniform sampler2D colortex0;	// Current frame
uniform sampler2D colortex2;	// TAA velocity
uniform sampler2D colortex15;	// Previous frame
uniform sampler2D depthtex0;	// Depth
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 cameraPosition;
uniform vec3 previousCameraPosition;

const bool colortex15Clear = false;

varying vec2 texcoord;
varying vec3 viewVector;

void main() {
	vec3 current = texture2D(colortex0, texcoord).rgb;
	#ifdef NOPE
	vec3 velocity = texture2D(colortex2, texcoord).rgb;

	// float depth = linearDepth(texture2D(depthtex0, texcoord).r);
	// vec4 viewPos = gbufferProjectionInverse * vec4(texcoord * +2.0 - 1.0, -depth, 0.0);
	// vec4 worldPos = gbufferModelViewInverse * viewPos;
	// worldPos.xyz /= worldPos.w;

	vec4 viewPos = vec4(calcViewPos(viewVector, texture2D(depthtex0, texcoord).r), 1.0);
	vec4 worldPos = vec4(cameraPosition - previousCameraPosition, 0.0) + gbufferModelViewInverse * viewPos;

	vec4 prevViewPos = gbufferPreviousModelView * worldPos - vec4(velocity, 0.0);
	vec4 prevScreenPos = gbufferPreviousProjection * prevViewPos;
	prevScreenPos /= prevScreenPos.w;
	prevScreenPos = prevScreenPos * 0.5 + 0.5;

	vec3 previousFrag = texture2D(colortex0, prevScreenPos.xy).rgb;
	#endif

/* RENDERTARGETS: 0,2,15 */
	// gl_FragData[0] = vec4(velocity, 1.0);
	// gl_FragData[0] = texture2D(colortex0, prevScreenPos.xy);
	gl_FragData[0] = vec4(current, 1.0);
	gl_FragData[1] = vec4(current, 1.0);
}
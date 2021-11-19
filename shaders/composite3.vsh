#version 120

#include "include.glsl"

uniform sampler2D colortex1;
uniform sampler2D depthtex0;

varying vec2 texcoord;
varying vec3 vectorPoints[30];

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;


	// vectorPoints = new vec2[10];

	float maxDistance = 8.0;
    float resolution = 0.5;
    int steps = 10;
    float thickness = 0.05;

	float depth = texture2D(depthtex0, vec2(0.5)).r;
	vec3 startPos = calcViewPos(vec2(0.5), depth);
	vec3 normal = normalize(texture2D(colortex1, vec2(0.5)).rgb * 2.0 - 1.0);

    vec2 texSize = vec2(viewWidth, viewHeight);

    vec3 pivot = normalize(reflect(normalize(startPos), normal));

    vec3 viewPos = startPos;
    vec4 endPos = vec4(startPos + (pivot * maxDistance), 1.0);

    vec4 startFrag = gbufferProjection * vec4(startPos, 1.0);
    startFrag.xyz /= startFrag.w;
    startFrag.xy = startFrag.xy * 0.5 + 0.5;
    startFrag.xy *= texSize;

    vec4 endFrag = gbufferProjection * endPos;
    endFrag.xyz /= endFrag.w;
    endFrag.xy = endFrag.xy * 0.5 + 0.5;
    endFrag.xy *= texSize;

    vec2 frag = startFrag.xy;
    vec2 uv = frag / texSize;

    float deltaX = endFrag.x - startFrag.x;
    float deltaY = endFrag.y - startFrag.y;
    float useX = abs(deltaX) >= abs(deltaY) ? 1.0 : 0.0;
    // float delta = mix(abs(deltaY), abs(deltaX), useX) * clamp(resolution, 0.0, 1.0);
    // vec2 increment = vec2(deltaX, deltaY) / max(delta, 0.001);

	vec2 increment = vec2(deltaX, deltaY) / vectorPoints.length();

    float search0 = 0.0;
    float search1 = 0.0;

    // float hit0 = 0.0;
    // float hit1 = 0.0;

    float viewDistance = startPos.z;
    float depthDiff = 0.0;

    for(int i = 0; i < vectorPoints.length(); ++i) {
        frag += increment;
        uv = frag / texSize;
        vectorPoints[i].xy = uv;

        viewPos = calcViewPos(uv, texture2D(depthtex0, uv).r);
		search1 = mix((frag.y - startFrag.y) / deltaY, (frag.x - startFrag.x) / deltaX, useX);
        viewDistance = (startPos.z * endPos.z) / mix(endPos.z, startPos.z, search1);
        depthDiff = viewDistance - viewPos.z;
        vectorPoints[i].z = depthDiff;
    }
}
#version 420 compatibility

#include "functions.glsl"
#include "sky.glsl"

#define ExposureSpeed 10

out vec2 texcoord;
out vec3 viewVector;
flat out float exposure;

uniform mat4 gbufferProjectionInverse;
uniform sampler2D colortex0;
uniform sampler2D colortex15;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTime;

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    vec4 ray = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;

    vec3 avgColor = textureLod(colortex0, vec2(0.5), log2(max(viewWidth, viewHeight))).rgb;
    float exposureScreen = 0.1 / dot(avgColor, vec3(0.2125, 0.7154, 0.0721));

    float exposurePrev = texture2D(colortex15, vec2(0.5)).r;
    float diff = exposureScreen - exposurePrev;
    if(abs(diff) <= ExposureSpeed * frameTime)
        exposure = exposureScreen;
        // exposure = 0.5;
    else
        exposure = exposurePrev + sign(diff) * ExposureSpeed * frameTime;
        // exposure = 1.0;

    // exposure = fract(exposurePrev + frameTimeCounter);
    // exposure = exposureScreen;

    // imageStore(colorimg5, ivec2(viewWidth/2, viewHeight/2), vec4(exposure, vec3(0.0)));
}
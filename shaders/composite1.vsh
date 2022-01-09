#version 400 compatibility

#include "functions.glsl"

out vec2 texcoord;
out flat float centerDepthLinear;

uniform float centerDepthSmooth;

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    centerDepthLinear = linearizeDepthFast(centerDepthSmooth);
}
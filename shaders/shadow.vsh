#version 400 compatibility

#include "functions.glsl"

out vec2 texcoord;
out vec4 glColor;

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_Position.xyz = distort(gl_Position.xyz);

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;
}
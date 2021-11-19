#version 120

#define viewBuffer off //[off 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 -1 -2 -3]
#include "functions.glsl"

varying vec2 TexCoords;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
uniform sampler2D colortex9;
uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;
uniform sampler2D colortex13;
uniform sampler2D colortex14;
uniform sampler2D colortex15;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D shadowtex0;

void main() {
    #if viewBuffer == 0
        gl_FragData[0] = texture2D(colortex0, TexCoords);
    #elif viewBuffer == 1
        gl_FragData[0] = texture2D(colortex1, TexCoords);
    #elif viewBuffer == 2
        gl_FragData[0] = texture2D(colortex2, TexCoords);
    #elif viewBuffer == 3
        gl_FragData[0] = texture2D(colortex3, TexCoords);
    #elif viewBuffer == 4
        gl_FragData[0] = texture2D(colortex4, TexCoords);
    #elif viewBuffer == 5
        gl_FragData[0] = texture2D(colortex5, TexCoords);
    #elif viewBuffer == 6
        gl_FragData[0] = texture2D(colortex6, TexCoords);
    #elif viewBuffer == 7
        gl_FragData[0] = texture2D(colortex7, TexCoords);
    #elif viewBuffer == 8
        gl_FragData[0] = texture2D(colortex8, TexCoords);
    #elif viewBuffer == 9
        gl_FragData[0] = texture2D(colortex9, TexCoords);
    #elif viewBuffer == 10
        gl_FragData[0] = texture2D(colortex10, TexCoords);
    #elif viewBuffer == 11
        gl_FragData[0] = texture2D(colortex11, TexCoords);
    #elif viewBuffer == 12
        gl_FragData[0] = texture2D(colortex12, TexCoords);
    #elif viewBuffer == 13
        gl_FragData[0] = texture2D(colortex13, TexCoords);
    #elif viewBuffer == 14
        gl_FragData[0] = texture2D(colortex14, TexCoords);
    #elif viewBuffer == 15
        gl_FragData[0] = texture2D(colortex15, TexCoords);
    #elif viewBuffer == -1
        gl_FragData[0] = texture2D(depthtex0, TexCoords);
    #elif viewBuffer == -2
        gl_FragData[0] = texture2D(depthtex1, TexCoords);
    #elif viewBuffer == -3
        gl_FragData[0] = texture2D(shadowtex0, TexCoords);
    #endif

    // float emissiveness = texture2D(colortex4, TexCoords).a;
    // gl_FragData[0] = vec4(vec3(emissiveness * float(emissiveness != 1.0)), 1.0);
    // gl_FragData[0] = vec4(vec3(length(texture2D(colortex2, TexCoords).rgb * 2.0 - 1.0)), 1.0);
    // gl_FragData[0] = vec4(decodeNormal(texture2D(colortex1, TexCoords).zw), 1.0);
    // gl_FragData[0] = vec4(texture2D(colortex2, TexCoords).xyz * 2.0 - 1.0, 1.0);

    // gl_FragData[0] = vec4(vec3(texture2D(colortex0, TexCoords).a), 1.0);

    // gl_FragData[0] = vec4(vec3(1.0 - abs(snoise(TexCoords * 10))), 1.0);
}
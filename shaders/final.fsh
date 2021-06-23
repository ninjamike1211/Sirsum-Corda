#version 120

#define viewBuffer off //[off 1 2 3 4 5 6 7 8 9 -1]

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
    #elif viewBuffer == -1
        gl_FragData[0] = texture2D(shadowtex0, TexCoords);
    #endif
}
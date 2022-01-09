#version 420 compatibility

#include "functions.glsl"
#define DOF

in vec2 texcoord;
in flat float centerDepthLinear;

uniform sampler2D depthtex0;

/* RENDERTARGETS: 14 */
layout(location = 0) out float coc;

void main() {
    // #ifdef DOF_Disabled
    //     float depth = linearizeDepthFast(texture2D(depthtex0, texcoord).r);
        
    //     coc = abs(depth - centerDepthLinear) * 0.5 + 0.5;
    //     // coc = DOF_FocalLength / (centerDepthLinear - DOF_FocalLength) * (1.0 - (centerDepthLinear / depth));
    // #endif
}
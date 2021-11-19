#include "functions.glsl"

uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D colortex0;
uniform float alphaTestRef;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 albedo;
layout(location = 1) out vec4 normal;
layout(location = 2) out vec2 lightmapOutput;

in vec2 texcoord;
in vec4 glColor;
flat in vec3 glNormal;
in vec2 lmcoord;
#ifdef MC_NORMAL_MAP
    flat in mat3 tbn;
#endif

void main() {
    albedo = texture2D(texture, texcoord) * glColor;

    // #ifdef transparency
    //     albedo.rgb = mix(texture2D(colortex0, texcoord).rgb, albedo.rgb, albedo.a);
    // #endif

    if (albedo.a < alphaTestRef) discard;

    normal.zw = NormalEncode(glNormal);

    #ifdef MC_NORMAL_MAP
        vec3 bumpmap = normalize(extractNormalZ(texture2D(normals, texcoord).rg * 2.0 - 1.0));
        normal.xy = NormalEncode(bumpmap * tbn);
    #else
        normal.xy = normal.zw;
    #endif

    lightmapOutput = lmcoord;
}
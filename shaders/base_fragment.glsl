#include "functions.glsl"
#include "POM.glsl"

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
in vec3 viewPos;
flat in vec4 textureBounds;

void main() {
    vec2 texcoordFinal = texcoord;

    #ifdef MC_NORMAL_MAP
    #ifdef POM
    // if(texture2D(texture, texcoord).a > 0.01) {

        vec3 viewDirTBN = tbn * normalize(viewPos);
        vec3 POMResults = ParallaxMapping(texcoord, viewDirTBN, textureBounds.zw-textureBounds.xy, normals, textureBounds);
        texcoordFinal = POMResults.xy;

        #ifdef POM_PDO
            // vec3 tbnDiff = vec3((texcoordFinal - texcoord) / (textureBounds.zw - textureBounds.xy), POMResults.z);
            // vec3 tbnDiff = (gbufferModelView * vec4(vec3((texcoordFinal - texcoord) / (textureBounds.zw - textureBounds.xy), -POMResults.z) * tbn, 1.0)).xyz;
            vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * POMResults.z) * tbn;
            // vec3 tbnDiff = vec3(0.0);
            vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
            vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
            gl_FragDepth = screenPos.z;
        #endif
    // }
    #endif
    #endif

    albedo = /* sRGBToLinear( */texture2D(texture, texcoordFinal) * vec4(glColor.rgb, 1.0)/* ) */;

    // #ifdef transparency
    //     albedo.rgb = mix(texture2D(colortex0, texcoord).rgb, albedo.rgb, albedo.a);
    // #endif

    if (albedo.a < alphaTestRef) discard;

    normal.zw = NormalEncode(glNormal);

    #ifdef MC_NORMAL_MAP
        vec3 bumpmap = normalize(extractNormalZ(texture2D(normals, texcoordFinal).rg * 2.0 - 1.0));
        normal.xy = NormalEncode(bumpmap * tbn);
    #else
        normal.xy = normal.zw;
    #endif

    lightmapOutput = lmcoord;
}
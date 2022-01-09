#version 400 compatibility

#include "functions.glsl"
#include "POM.glsl"

in vec2 texcoord;
in vec4 glColor;
in vec3 viewPos;
flat in vec4 textureBounds;

#ifdef MC_NORMAL_MAP
    flat in mat3 tbn;
#endif

layout(location = 0) out vec4 shadowColor;

uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D colortex6;
uniform float alphaTestRef;
uniform vec3 cameraPosition;
uniform mat4 shadowModelViewInverse;
uniform float frameTimeCounter;

void main() {

    vec2 texcoordUse = texcoord;

    #ifdef MC_NORMAL_MAP
    #ifdef POM
    #ifdef POM_PDO
    // if(texture2D(texture, texcoord).a > 0.01) {

        vec3 viewDirTBN = tbn * normalize(viewPos);
        vec3 POMResults = ParallaxMapping(texcoord, viewDirTBN, textureBounds.zw-textureBounds.xy, normals, textureBounds);
        texcoordUse = POMResults.xy;

        #ifdef POM_PDO
            // vec3 tbnDiff = vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), POMResults.z);
            // vec3 tbnDiff = (gbufferModelView * vec4(vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), -POMResults.z) * tbn, 1.0)).xyz;
            vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * POMResults.z) * tbn;
            // vec3 tbnDiff = vec3(0.0);
            vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
            clipPos.xyz = distort(clipPos.xyz);
            vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
            gl_FragDepth = screenPos.z;
        #endif
    // }
    #endif
    #endif
    #endif


    shadowColor = texture2D(texture, texcoordUse) * glColor;
    if (shadowColor.a < alphaTestRef) discard;

    // vec3 worldPos = (shadowModelViewInverse * vec4(viewPos, 1.0)).xyz + cameraPosition;
    // shadowColor *= texture2D(colortex6, fract(worldPos.xz * 0.1 + frameTimeCounter * 0.01)).r * 1.0;
    // // shadowColor.rgb = vec3(1.0);
}
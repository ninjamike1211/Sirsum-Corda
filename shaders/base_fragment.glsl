#include "functions.glsl"
#include "kernels.glsl"
#include "sky.glsl"
#include "lighting.glsl"
#include "POM.glsl"
#include "Water.glsl"

uniform sampler2D texture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform mat4 gbufferModelViewInverse;
uniform float alphaTestRef;
uniform vec3 shadowLightPosition;
uniform float frameTimeCounter;
uniform int worldTime;
uniform float rainStrength;
uniform float wetness;
uniform int renderStage;
uniform vec3 cameraPosition;

/* RENDERTARGETS: 0,1,2,3 */
layout(location = 0) out vec4 albedo;
layout(location = 1) out vec4 normal;
layout(location = 2) out vec3 lightmapOutput;
layout(location = 3) out vec3 specMap;

in vec2 texcoord;
in vec4 glColor;
flat in vec3 glNormal;
in vec2 lmcoord;
#ifdef MC_NORMAL_MAP
    flat in mat3 tbn;
#endif
in vec3 viewPos;
flat in vec4 textureBounds;
flat in vec4 entity;

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

    #ifdef hand
        lightmapOutput = vec3(lmcoord, 1.0);
    #else
        lightmapOutput = vec3(lmcoord, 0.0);
    #endif

    specMap = texture2D(specular, texcoordFinal).rgb;

    if(renderStage == MC_RENDER_STAGE_TERRAIN_TRANSLUCENT
    || renderStage == MC_RENDER_STAGE_TRIPWIRE
    || renderStage == MC_RENDER_STAGE_PARTICLES
    || renderStage == MC_RENDER_STAGE_RAIN_SNOW
    || renderStage == MC_RENDER_STAGE_WORLD_BORDER
    || renderStage == MC_RENDER_STAGE_HAND_TRANSLUCENT) {
        vec3 normValue = bumpmap * tbn;
        if(entity.x == 9) {
            // vec3 worldPos = mat3(gbufferModelViewInverse) * viewPos + cameraPosition;
            // normValue = waterNormal(worldPos.xz, frameTimeCounter) * tbn;
            // normal.xy = NormalEncode(normValue);
            specMap = vec3(0.9, 0.0, 1.0);
            // albedo.rgb = vec3(0.15, 0.3, 0.75);
            // albedo.a = 0.4;
        }
        float NdotL = dot(normValue, normalize(shadowLightPosition));
        float NGdotL = dot(glNormal, normalize(shadowLightPosition));

        vec3 shadowResult = pcssShadows(viewPos, texcoord, frameTimeCounter, NGdotL, shadowtex0, shadowtex1, shadowcolor0, noisetex, gbufferModelViewInverse);

        vec3 SunMoonColor = skyLightColor(worldTime, rainStrength);
        albedo.rgb = sRGBToLinear(albedo).rgb;

        // diffuseLighting(albedo, shadowResult, lmcoord, worldTime, rainStrength);
        albedo.rgb = cookTorrancePBRLighting(albedo.rgb, normalize(-viewPos), normValue, specMap, lmcoord, SunMoonColor, normalize(shadowLightPosition), shadowResult);

        // albedo.rgb *= calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex);
        // albedo.rgb = vec3(calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex));

        #ifdef VolFog
            volumetricFog(albedo, viewPos, texcoord, worldTime, frameTimeCounter, rainStrength, wetness, shadowtex0, shadowtex1, shadowcolor0, noisetex, gbufferModelViewInverse);
        #endif
    }
}
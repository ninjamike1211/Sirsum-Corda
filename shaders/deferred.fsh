#version 400 compatibility

#include "kernels.glsl"
#include "functions.glsl"
#include "sky.glsl"
#include "lighting.glsl"

#define cloudsEnable
#define lowCloudHeight 600
#define highCloudHeight 1600
#define lowCloudNormalMult 0.08
#define highCloudNormalMult 0.01
// #define cloudDualLayer
#ifdef cloudDualLayer
    #define lowCloud2Height 650
#endif

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 shadowLightPosition;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float wetness;
uniform float eyeAltitude;
uniform int worldTime;

in vec2 texcoord;
in vec3 viewVector;
flat in vec3 SunMoonColor;

const int noiseTextureResolution = 512;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 albedo;

void main() {

    albedo = texture2D(colortex0, texcoord);
    albedo.rgb = sRGBToLinear(albedo).rgb;
    vec2 lmcoord = texture2D(colortex2, texcoord).rg;

    float depth = texture2D(depthtex0, texcoord).r;
    vec3 viewPos = calcViewPos(viewVector, depth);

    if(depth < 1.0) {
        // vec3 normal = Decode(texture2D(colortex1, texcoord).xy);
        // vec3 normal = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
        vec3 normal = NormalDecode(texture2D(colortex1, texcoord).xy);
        vec3 normalGeometry = NormalDecode(texture2D(colortex1, texcoord).zw);
        vec3 specMap = texture2D(colortex3, texcoord).rgb;
        // vec3 normalGeometry = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
        float NdotL = dot(normal, normalize(shadowLightPosition));
        float NGdotL = dot(normalGeometry, normalize(shadowLightPosition));

        vec3 shadowResult = pcssShadows(viewPos, texcoord, frameTimeCounter, NGdotL, shadowtex0, shadowtex1, shadowcolor0, noisetex, gbufferModelViewInverse);

        // diffuseLighting(albedo, shadowResult, lmcoord, worldTime, rainStrength);
        // PBRLighting(albedo.rgb, viewPos, normal, normalize(shadowLightPosition), lmcoord, specMap, shadowResult, SunMoonColor);
        albedo.rgb = cookTorrancePBRLighting(albedo.rgb, normalize(viewVector), normal, specMap, lmcoord, SunMoonColor, normalize(shadowLightPosition), shadowResult);

        // albedo.rgb *= calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex);
        // albedo.rgb = vec3(calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex));

        #ifdef VolFog
            volumetricFog(albedo, viewPos, texcoord, worldTime, frameTimeCounter, rainStrength, wetness, shadowtex0, shadowtex1, shadowcolor0, noisetex, gbufferModelViewInverse);
        #endif

    }

    // albedo = sRGBToLinear(albedo);

    else {
        vec3 sky = skyColor(normalize(viewPos), normalize(sunPosition), eyeAltitude, mat3(gbufferModelViewInverse));
        sky += skyMoonColor(normalize(viewPos), normalize(moonPosition), eyeAltitude, mat3(gbufferModelViewInverse));
        // sky += texture2D(noisetex, fract(texcoord * vec2(viewWidth, viewHeight) / 512.0)).r / 255.0;
        
        // albedo.rgb = mix(sky, albedo.rgb, albedo.a);
        albedo.rgb = sky;

        // vec3 eyeDir = mat3(gbufferModelViewInverse) * normalize(viewPos);
        // vec3 sunEyeDir = mat3(gbufferModelViewInverse) * normalize(sunPosition);
        // albedo.rgb = skyColor2(eyeDir, sunEyeDir, eyeAltitude);
    }

    #ifdef cloudsEnable
        vec3 playerRayDir = mat3(gbufferModelViewInverse) * normalize(viewPos); // playerspace ray direction
        vec3 cloudPos = playerRayDir.xyz / playerRayDir.y; // y-normalized playerspace ray direction
        
        vec3 cloudPosHigh = cloudPos * (highCloudHeight - cameraPosition.y);
        cloudPosHigh.xz += cameraPosition.xz;

        if((depth == 1.0 || length(cloudPosHigh - vec3(cameraPosition.x, 0.0, cameraPosition.z)) < length(viewPos)) /* && abs(cloudPos.x) < 1.0 && abs(cloudPos.z) < 1.0 */ && sign(highCloudHeight - cameraPosition.y) == sign(playerRayDir.y)) {
            vec3 noise = 0.61 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.0009 + 0.03 * frameTimeCounter);
            noise += 0.32 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.003 + 0.07 * vec2(1.0, -1.0) * frameTimeCounter);
            noise += 0.06 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.01 - 0.1 * frameTimeCounter);
            noise += 0.01 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.03 + 0.1 * vec2(-1.0, 1.0) * frameTimeCounter);

            float density = noise.x * 0.63 + 0.63;
            vec3 noiseNormal = extractNormalZ(highCloudNormalMult * -noise.yz).xzy;
            noiseNormal *= sign(highCloudHeight - cameraPosition.y);
            noiseNormal = mat3(gbufferModelView) * noiseNormal;
            float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));

            vec3 cloudColor = /* skyLightColor(worldTime, rainStrength) */ SunMoonColor * (abs(cloudDotL) * 0.5 + 0.5);
            float cloudAlpha = smoothstep(1.5 - wetness, 6.0 - 3.8*wetness, exp(density)) * smoothstep(far*100, far, length(cloudPosHigh.xz + cameraPosition.xz));

            albedo.rgb = mix(albedo.rgb, cloudColor, cloudAlpha);
        }


        vec3 cloudPosLow = cloudPos * (lowCloudHeight - cameraPosition.y);
        cloudPosLow.xz += cameraPosition.xz;

        if((depth == 1.0 || length(cloudPosLow - vec3(cameraPosition.x, 0.0, cameraPosition.z)) < length(viewPos)) /* && abs(cloudPos.x) < 1.0 && abs(cloudPos.z) < 1.0 */ && sign(lowCloudHeight - cameraPosition.y) == sign(playerRayDir.y)) {
            vec3 noise = 0.52 * SimplexPerlin2D_Deriv(cloudPosLow.xz * 0.0004 + 0.02 * frameTimeCounter);
            noise += 0.36 * SimplexPerlin2D_Deriv(cloudPosLow.xz * 0.0009 + 0.03 * frameTimeCounter);
            noise += 0.12 * SimplexPerlin2D_Deriv(cloudPosLow.xz * 0.003 + 0.07 * vec2(1.0, -1.0) * frameTimeCounter + 0.06);
            noise += 0.02 * SimplexPerlin2D_Deriv(cloudPosLow.xz * 0.01 - 0.1 * frameTimeCounter);

            float density = noise.x * .745 + .745;
            vec3 noiseNormal = extractNormalZ(lowCloudNormalMult * -noise.yz).xzy;
            noiseNormal *= sign(lowCloudHeight - cameraPosition.y);
            noiseNormal = mat3(gbufferModelView) * noiseNormal;
            float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));
            // cloudDotL = 1.0;

            vec3 cloudColor = /* skyLightColor(worldTime, rainStrength) */ SunMoonColor * (abs(cloudDotL) * 0.5 + 0.5);
            float cloudAlpha = smoothstep(2.1 - 2.1*wetness, 3.3 - 0.7*wetness, exp(density)) * smoothstep(far*60, far, length(cloudPosLow.xz + cameraPosition.xz));

            albedo.rgb = mix(albedo.rgb, cloudColor, cloudAlpha);
        }

        #ifdef cloudDualLayer
            vec3 cloudPosLow2 = cloudPos * (lowCloud2Height - cameraPosition.y);
            cloudPosLow2.xz += cameraPosition.xz;

            if((depth == 1.0 || length(cloudPosLow2 - vec3(cameraPosition.x, 0.0, cameraPosition.z)) < length(viewPos)) /* && abs(cloudPos.x) < 1.0 && abs(cloudPos.z) < 1.0 */ && sign(lowCloud2Height - cameraPosition.y) == sign(playerRayDir.y)) {
                vec3 noise = 0.52 * SimplexPerlin2D_Deriv(cloudPosLow2.xz * 0.0004 + 0.02 * frameTimeCounter);
                noise += 0.36 * SimplexPerlin2D_Deriv(cloudPosLow2.xz * 0.0009 + 0.03 * frameTimeCounter);
                noise += 0.12 * SimplexPerlin2D_Deriv(cloudPosLow2.xz * 0.003 + 0.07 * vec2(1.0, -1.0) * frameTimeCounter + 0.06);
                noise += 0.02 * SimplexPerlin2D_Deriv(cloudPosLow2.xz * 0.01 - 0.1 * frameTimeCounter);

                float density = noise.x * .745 + .745;
                vec3 noiseNormal = extractNormalZ(lowCloudNormalMult * -noise.yz).xzy;
                noiseNormal *= sign(lowCloud2Height - cameraPosition.y);
                noiseNormal = mat3(gbufferModelView) * noiseNormal;
                float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));

                vec3 cloudColor = /* skyLightColor(worldTime, rainStrength) */ SunMoonColor * (abs(cloudDotL) * 0.5 + 0.5);
                float cloudAlpha = smoothstep(2.1 - 2.1*wetness, 3.3 - 0.7*wetness, exp(density)) * smoothstep(far*35, far, length(cloudPosLow2.xz + cameraPosition.xz));

                albedo.rgb = mix(albedo.rgb, cloudColor, cloudAlpha);
            }
        #endif
    #endif

    // if(depth == 1.0) {
    //     albedo.rgb = mix(albedo.rgb, vec3(1.0), smoothstep(0.9, 0.999, texture2D(noisetex, texcoord).r));
    // }

    // albedo.rgb = normal * 0.5 + 0.5;
    // albedo.rgb = vec3(NdotL);

    // if(texcoord.x < 0.075 && texcoord.y > 0.9)
    //     albedo.rgb = vec3(dot(vec3(0.0, 0.0, -1.0), normalize(shadowLightPosition)) * 0.5 + 0.5);

    // albedo.rgb = vec3(albedo.a);
}
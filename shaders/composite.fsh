#version 400 compatibility

#include "functions.glsl"

#define Shadow_Filter 2
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
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform vec3 shadowLightPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float far;
uniform float rainStrength;
uniform float wetness;
uniform int worldTime;

in vec2 texcoord;
in vec3 viewVector;

const int noiseTextureResolution = 512;

const vec2 shadowKernel[] = vec2[](
    #if Shadow_Filter == 1
        vec2(0., 0.),
        vec2(1., 0.),
        vec2(-1., 0.),
        vec2(0.30901697, 0.95105654),
        vec2(-0.30901664, -0.9510566),
        vec2(0.54545456, 0),
        vec2(0.16855472, 0.5187581),
        vec2(-0.44128203, 0.3206101),
        vec2(-0.44128197, -0.3206102),
        vec2(0.1685548, -0.5187581),
        vec2(0.809017, 0.58778524),
        vec2(-0.30901703, 0.9510565),
        vec2(-0.80901706, 0.5877852),
        vec2(-0.80901694, -0.58778536),
        vec2(0.30901712, -0.9510565),
        vec2(0.80901694, -0.5877853)
    #elif Shadow_Filter == 2
        vec2(0,0),
        vec2(0.36363637,0),
        vec2(0.22672357,0.28430238),
        vec2(-0.08091671,0.35451925),
        vec2(-0.32762504,0.15777594),
        vec2(-0.32762504,-0.15777591),
        vec2(-0.08091656,-0.35451928),
        vec2(0.22672352,-0.2843024),
        vec2(0.6818182,0),
        vec2(0.614297,0.29582983),
        vec2(0.42510667,0.5330669),
        vec2(0.15171885,0.6647236),
        vec2(-0.15171883,0.6647236),
        vec2(-0.4251068,0.53306687),
        vec2(-0.614297,0.29582986),
        vec2(-0.6818182,0),
        vec2(-0.614297,-0.29582983),
        vec2(-0.42510656,-0.53306705),
        vec2(-0.15171856,-0.66472363),
        vec2(0.1517192,-0.6647235),
        vec2(0.4251066,-0.53306705),
        vec2(0.614297,-0.29582983),
        vec2(1.,0),
        vec2(0.9555728,0.2947552),
        vec2(0.82623875,0.5633201),
        vec2(0.6234898,0.7818315),
        vec2(0.36534098,0.93087375),
        vec2(0.07473,0.9972038),
        vec2(-0.22252095,0.9749279),
        vec2(-0.50000006,0.8660254),
        vec2(-0.73305196,0.6801727),
        vec2(-0.90096885,0.43388382),
        vec2(-0.98883086,0.14904208),
        vec2(-0.9888308,-0.14904249),
        vec2(-0.90096885,-0.43388376),
        vec2(-0.73305184,-0.6801728),
        vec2(-0.4999999,-0.86602545),
        vec2(-0.222521,-0.9749279),
        vec2(0.07473029,-0.99720377),
        vec2(0.36534148,-0.9308736),
        vec2(0.6234897,-0.7818316),
        vec2(0.8262388,-0.56332),
        vec2(0.9555729,-0.29475483)
    #endif
);

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 albedo;

vec3 shadowVisibility(vec3 shadowPos) {
    vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
    shadowColor.rgb = shadowColor.rgb * (1.0 - shadowColor.a);
    float visibility0 = step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy).r);
    float visibility1 = step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy).r);
    return mix(shadowColor.rgb * visibility1, vec3(1.0f), visibility0);
}

void main() {

    albedo = texture2D(colortex0, texcoord);
    vec2 lmcoord = texture2D(colortex2, texcoord).rg;

    float depth = texture2D(depthtex0, texcoord).r;
    vec3 viewPos = calcViewPos(viewVector, depth);

    // vec3 normal = Decode(texture2D(colortex1, texcoord).xy);
    // vec3 normal = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
    vec3 normal = NormalDecode(texture2D(colortex1, texcoord).xy);
    vec3 normalGeometry = NormalDecode(texture2D(colortex1, texcoord).zw);
    // vec3 normalGeometry = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
    float NdotL = dot(normal, normalize(shadowLightPosition));
    float NGdotL = dot(normalGeometry, normalize(shadowLightPosition));

    vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
    float distortFactor = getDistortFactor(shadowPos.xy);
    shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
    shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
    shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NGdotL); //apply shadow bias

    vec3 shadowVal = vec3(0.0);
    float randomAngle = texture2D(noisetex, texcoord * 20.0).r * 100.0;
    float cosTheta = cos(randomAngle);
    float sinTheta = sin(randomAngle);
    mat2 rotation =  0.001 * mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

    for(int i = 0; i < shadowKernel.length(); i++) {
        vec2 offset = rotation * shadowKernel[i];
        shadowVal += shadowVisibility(shadowPos + vec3(offset, 0.0));
    }

    shadowVal /= shadowKernel.length();
    vec3 shadowResult = min(vec3(max(NdotL, 0.0)), shadowVal);
    shadowResult *= float(abs(NGdotL) > 0.01);

    vec3 skyLight = skyLightColor(worldTime, rainStrength) * shadowResult;
    vec3 skyAmbient = skyLightColor(worldTime, rainStrength) * mix(vec3(0.0), vec3(0.4), lmcoord.y) * (1.0 - shadowResult);
    vec3 torchAmbient = mix(vec3(0.0), vec3(0.9, 0.7, 0.4), lmcoord.x) * (1.2 - skyLight);

    if(depth < 1.0) {
        // if(NGdotL) < 0.01)
        //     NdotL = 0.0;
        // albedo.rgb *= min(vec3(max(NdotL, 0.0)), shadowVal) * 0.5 + 0.5;
        albedo.rgb *= skyLight + skyAmbient + torchAmbient;
    }

    vec3 playerRayDir = mat3(gbufferModelViewInverse) * normalize(viewPos); // playerspace ray direction
    vec3 cloudPos = playerRayDir.xyz / playerRayDir.y; // y-normalized playerspace ray direction
    
    vec3 cloudPosHigh = cloudPos * (highCloudHeight - cameraPosition.y);
    cloudPosHigh.xz += cameraPosition.xz;

    if((depth == 1.0 || length(cloudPosHigh - vec3(cameraPosition.x, 0.0, cameraPosition.z)) < length(viewPos)) /* && abs(cloudPos.x) < 1.0 && abs(cloudPos.z) < 1.0 */ && sign(highCloudHeight - cameraPosition.y) == sign(playerRayDir.y)) {
        vec3 noise = 0.61 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.0009 + 0.03 * frameTimeCounter);
        noise += 0.26 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.003 + 0.07 * vec2(1.0, -1.0) * frameTimeCounter);
        noise += 0.08 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.01 - 0.1 * frameTimeCounter);
        noise += 0.05 * SimplexPerlin2D_Deriv(cloudPosHigh.xz * 0.03 + 0.1 * vec2(-1.0, 1.0) * frameTimeCounter);

        float density = noise.x * 0.63 + 0.63;
        vec3 noiseNormal = extractNormalZ(highCloudNormalMult * -noise.yz).xzy;
        noiseNormal *= sign(highCloudHeight - cameraPosition.y);
        noiseNormal = (gbufferModelView * vec4(noiseNormal, 1.0)).xyz;
        float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));

        vec3 cloudColor = skyLightColor(worldTime, rainStrength) * (abs(cloudDotL) * 0.5 + 0.5);
        float cloudAlpha = smoothstep(1.0 - wetness, 5.0 - 3.8*wetness, exp(density)) * smoothstep(far*70, far, length(cloudPosHigh.xz + cameraPosition.xz));

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
        noiseNormal = (gbufferModelView * vec4(noiseNormal, 1.0)).xyz;
        float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));

        vec3 cloudColor = skyLightColor(worldTime, rainStrength) * (abs(cloudDotL) * 0.5 + 0.5);
        float cloudAlpha = smoothstep(2.1 - 2.1*wetness, 3.3 - 0.7*wetness, exp(density)) * smoothstep(far*35, far, length(cloudPosLow.xz + cameraPosition.xz));

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
            noiseNormal = (gbufferModelView * vec4(noiseNormal, 1.0)).xyz;
            float cloudDotL = dot(noiseNormal, normalize(shadowLightPosition));

            vec3 cloudColor = skyLightColor(worldTime, rainStrength) * (abs(cloudDotL) * 0.5 + 0.5);
            float cloudAlpha = smoothstep(2.1 - 2.1*wetness, 3.3 - 0.7*wetness, exp(density)) * smoothstep(far*35, far, length(cloudPosLow2.xz + cameraPosition.xz));

            albedo.rgb = mix(albedo.rgb, cloudColor, cloudAlpha);
        }
    #endif

    // if(depth == 1.0) {
    //     albedo.rgb = mix(albedo.rgb, vec3(1.0), smoothstep(0.9, 0.999, texture2D(noisetex, texcoord).r));
    // }

    // albedo.rgb = normal * 0.5 + 0.5;
    // albedo.rgb = vec3(NdotL);

    // if(texcoord.x < 0.075 && texcoord.y > 0.9)
    //     albedo.rgb = vec3(dot(vec3(0.0, 0.0, -1.0), normalize(shadowLightPosition)) * 0.5 + 0.5);
}
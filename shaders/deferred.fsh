#version 400 compatibility

#include "kernels.glsl"
#include "functions.glsl"
#include "sky.glsl"

#define ShadowSamples 32 // Number of samples used calculating shadow blur [4 8 16 32 48 64]
#define ShadowBlockSamples 16 // Number of samples used for PCSS blocking [2 4 8 16 32 48 64]
#define ShadowBlurScale 0.20 // Scale of shadow blur [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75]
#define ShadowMinBlur 0.00020 // Maximum shadow blur with PCSS [0.00000 0.00002 0.00004 0.00006 0.00008 0.00010 0.00012 0.00014 0.00016 0.00018 0.00020 0.00025 0.00030 0.00040 0.00050]
#define ShadowMaxBlur 0.020 // Maximum shadow blur with PCSS [0.00 0.005 0.010 0.015 0.020 0.025 0.030 0.035 0.040 0.045 0.050]
#define ShadowNoiseAnimated // When enabled move noise with each frame, allowing for lower shadow samples at the cost of noise "moving"

#define SSAO_Radius 0.5 // Radius of SSAO. Higher values causes ao to be more spread out. Lower values will concentrate shadows more in corners. [0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0]
#define SSAO_Strength 0.6 // Strength of ambient shadows. 0 means no shadows. Higher numbers mean darker shadows. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

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
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 cameraPosition;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;
uniform float far;
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

vec3 shadowVisibility(vec3 shadowPos) {
    vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
    shadowColor.rgb = shadowColor.rgb * (1.0 - shadowColor.a);
    float visibility0 = step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy).r);
    float visibility1 = step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy).r);
    return mix(shadowColor.rgb * visibility1, vec3(1.0f), visibility0);
}

float calcSSAO(vec3 normal, vec3 viewPos, vec2 texcoord, sampler2D depthTex, sampler2D aoNoiseTex) {
    vec2 noiseCoord = vec2(mod(texcoord.x * viewWidth, 4.0) / 4.0, mod(texcoord.y * viewHeight, 4.0) / 4.0);
    vec3 rvec = vec3(texture2D(aoNoiseTex, noiseCoord).xy * 2.0 - 1.0, 0.0);
	// vec3 rvec = vec3(1.0);
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);

    vec3 fragPos = viewPos;

    float occlusion = 0.0;
	for (int i = 0; i < half_sphere_16.length(); ++i) {
		// get sample position:
		vec3 sampleVal = tbn * half_sphere_16[i];
		sampleVal = sampleVal * SSAO_Radius + fragPos;
		
		// project sample position:
		vec4 offset = vec4(sampleVal, 1.0);
		offset = gbufferProjection * offset;
		offset.xy /= offset.w;
		offset.xy = offset.xy * 0.5 + 0.5;
		
		// get sample depth:
		float sampleDepth = calcViewPos(offset.xy, texture2D(depthTex, offset.xy).r, gbufferProjectionInverse).z; // texture2D(viewTex, offset.xy).z;
		
		// range check & accumulate:
		float rangeCheck = smoothstep(0.0, 1.0, SSAO_Radius / abs(fragPos.z - sampleDepth));
        // float rangeCheck= abs(fragPos.z - sampleDepth) < SSAO_Radius ? 1.0 : 0.0;
		occlusion += (sampleDepth >= sampleVal.z ? 1.0 : 0.0) * rangeCheck;
	}

	return clamp(1.0 - (SSAO_Strength * occlusion / half_sphere_16.length()), 0.0, 1.0);
}

void main() {

    albedo = texture2D(colortex0, texcoord);
    vec2 lmcoord = texture2D(colortex2, texcoord).rg;

    float depth = texture2D(depthtex0, texcoord).r;
    vec3 viewPos = calcViewPos(viewVector, depth);

    if(depth == 1.0) {
        vec3 sky = skyColor(normalize(viewPos), normalize(sunPosition), eyeAltitude, mat3(gbufferModelViewInverse));
        sky += skyMoonColor(normalize(viewPos), normalize(moonPosition), eyeAltitude, mat3(gbufferModelViewInverse));
        sky += texture2D(noisetex, fract(texcoord * vec2(viewWidth, viewHeight) / 512.0)).r / 255.0;
        
        // albedo.rgb = mix(sky, albedo.rgb, albedo.a);
        albedo.rgb += sky;

        // vec3 eyeDir = mat3(gbufferModelViewInverse) * normalize(viewPos);
        // vec3 sunEyeDir = mat3(gbufferModelViewInverse) * normalize(sunPosition);
        // albedo.rgb = skyColor2(eyeDir, sunEyeDir, eyeAltitude);
    }

    // vec3 normal = Decode(texture2D(colortex1, texcoord).xy);
    // vec3 normal = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
    vec3 normal = NormalDecode(texture2D(colortex1, texcoord).xy);
    vec3 normalGeometry = NormalDecode(texture2D(colortex1, texcoord).zw);
    // vec3 normalGeometry = texture2D(colortex2, texcoord).xyz * 2.0 - 1.0;
    float NdotL = dot(normal, normalize(shadowLightPosition));
    float NGdotL = dot(normalGeometry, normalize(shadowLightPosition));

    vec4 playerPos = gbufferModelViewInverse * vec4(viewPos, 1.0);
    vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
    // float distortFactor = getDistortFactor(shadowPos.xy);
    // shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
    // shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
    // shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NGdotL); //apply shadow bias

    // if(shadowPos.x < -1.0 || shadowPos.x > 1.0 || shadowPos.y < -1.0 || shadowPos.y > 1.0)
    //     shadowPos.z = 0.0;

    vec3 shadowVal = vec3(0.0);
    #ifdef ShadowNoiseAnimated
        float randomAngle = texture2D(noisetex, texcoord * 20.0 + frameTimeCounter).r * 100.0;
    #else
        float randomAngle = texture2D(noisetex, texcoord * 20.0).r * 100.0;
    #endif
    float cosTheta = cos(randomAngle);
    float sinTheta = sin(randomAngle);
    mat2 rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

    float blockerDist = 0.0;
    float size = 0.0;
    for(int i = 0; i < ShadowBlockSamples; i++) {
        // dist = max(dist, abs(texture2D(shadowtex0, shadowPos.xy + rotation * 0.01 * shadowKernel[i]).r - shadowPos.z));
        vec3 shadowPosTemp = shadowPos;
        shadowPosTemp.xy += rotation * ShadowMaxBlur * 0.2 * blue_noise_disk[i];
        float distortFactor = getDistortFactor(shadowPosTemp.xy);
        shadowPosTemp.xyz = distort(shadowPosTemp.xyz, distortFactor); //apply shadow distortion
        shadowPosTemp.xyz = shadowPosTemp.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
        shadowPosTemp.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NGdotL); //apply shadow bias

        float a = texture2D(shadowtex0, shadowPosTemp.xy).r - shadowPosTemp.z;
        if(a < 0.01) {
            blockerDist += abs(a + shadowPosTemp.z);
            size += 1.0;
        }

        // float a = texture2D(shadowtex0, shadowPos.xy + rotation * 0.01 * shadowKernel[i]).r;
        // if(shadowPos.z - a < -0.01) {
        //     dist += a;
        //     size += 1.0;
        // }
    }
    float distortFactor = getDistortFactor(shadowPos.xy);
    shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
    shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
    shadowPos.z -= Shadow_Bias /* * (distortFactor * distortFactor) */ / abs(NGdotL); //apply shadow bias

    blockerDist /= size;
    // float penumbra = min(ShadowBlurScale * dist + ShadowMinBlur, ShadowMaxBlur);
    float penumbra = min(ShadowBlurScale * (shadowPos.z - blockerDist) / blockerDist + ShadowMinBlur, ShadowMaxBlur);
    // penumbra = 0.0004;
    // float penumbra = 0.0000001 * (shadowPos.z - dist) / dist;
    // float penumbra = 0.4 * dist + 0.0001;
    // penumbra *= float(penumbra < 0.03);
    // float penumbra = 1000.0 * abs(shadowPos.z - texture2D(shadowtex0, shadowPos.xy).r);
    // penumbra = 2.0;

    for(int i = 0; i < ShadowSamples; i++) {
        vec3 shadowPosTemp = shadowPos;
        shadowPosTemp.xy += rotation * penumbra * blue_noise_disk[i];
        // float distortFactor = getDistortFactor(shadowPosTemp.xy);
        // shadowPosTemp.xyz = distort(shadowPosTemp.xyz, distortFactor); //apply shadow distortion
        // shadowPosTemp.xyz = shadowPosTemp.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
        // shadowPosTemp.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NGdotL); //apply shadow bias
        shadowVal += shadowVisibility(shadowPosTemp);
    }

    shadowVal /= ShadowSamples;
    vec3 shadowResult = min(vec3(max(NdotL, 0.0)), shadowVal);
    shadowResult *= float(abs(NGdotL) > 0.01);

    vec3 skyLight = /* skyLightColor(worldTime, rainStrength) */ SunMoonColor * shadowResult;
    vec3 skyAmbient = /* skyLightColor(worldTime, rainStrength) */ SunMoonColor * mix(vec3(0.0), vec3(0.4), lmcoord.y) * (1.0 - shadowResult);
    // vec3 torchAmbient = mix(vec3(0.0), vec3(0.9, 0.7, 0.4), lmcoord.x) * (1.2 - skyLight);

    if(depth < 1.0) {
        // if(NGdotL) < 0.01)
        //     NdotL = 0.0;
        // albedo.rgb *= min(vec3(max(NdotL, 0.0)), shadowVal) * 0.5 + 0.5;

        // albedo = linearToSRGB(albedo);
        albedo.rgb *= skyLight + skyAmbient /* + torchAmbient */;
        // albedo = sRGBToLinear(albedo);
        // albedo.rgb *= 1.0;

        // albedo.rgb *= calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex);
        // albedo.rgb = vec3(calcSSAO(normal, viewPos, texcoord, depthtex0, noisetex));
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
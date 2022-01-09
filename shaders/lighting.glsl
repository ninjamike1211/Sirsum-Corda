#define ShadowSamples 32 // Number of samples used calculating shadow blur [4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 36 40 44 48 56 64 72 80 88 96 112 128]
#define ShadowBlockSamples 16 // Number of samples used for PCSS blocking [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 36 40 44 48 56 64]
#define ShadowBlurScale 0.20 // Scale of shadow blur [0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75]
#define ShadowMinBlur 0.00020 // Maximum shadow blur with PCSS [0.00000 0.00002 0.00004 0.00006 0.00008 0.00010 0.00012 0.00014 0.00016 0.00018 0.00020 0.00025 0.00030 0.00040 0.00050]
#define ShadowMaxBlur 0.020 // Maximum shadow blur with PCSS [0.00 0.005 0.010 0.015 0.020 0.025 0.030 0.035 0.040 0.045 0.050]
#define ShadowNoiseAnimated // When enabled move noise with each frame, allowing for lower shadow samples at the cost of noise "moving"

#define VolFog
#define VolFog_Steps 64 // Number of samples used for volumetric fog [8 12 16 20 24 32 48 64 96 128]
// #define VolFog_SmoothShadows
#define VolFog_SmoothShadowSamples 4 // Number of samples used for smooth shadows in volumetric fog [1 2 4 6 8 10 12 14 16 20 24 32]
#define VolFog_SmoothShadowBlur 0.007 // Amount of blur applied ot shadows in volumetric fog [0.000 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.015 0.020]

#define SSAO_Radius 0.5 // Radius of SSAO. Higher values causes ao to be more spread out. Lower values will concentrate shadows more in corners. [0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0]
#define SSAO_Strength 0.6 // Strength of ambient shadows. 0 means no shadows. Higher numbers mean darker shadows. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

vec3 softShadows(vec3 shadowPos, float penumbra, int samples, float angle, sampler2D shadowtex0, sampler2D shadowtex1, sampler2D shadowcolor0) {
    vec3 shadowVal = vec3(0.0);
    for(int i = 0; i < samples; i++) {
        vec3 shadowPosTemp = shadowPos;
        shadowPosTemp.xy += penumbra * GetVogelDiskSample(i, samples, angle);
        shadowVal += shadowVisibility(shadowPosTemp, shadowtex0, shadowtex1, shadowcolor0);
    }

    return shadowVal / samples;
}

vec3 pcssShadows(vec3 viewPos, vec2 texcoord, float frameTimeCounter, float NGdotL, sampler2D shadowtex0, sampler2D shadowtex1, sampler2D shadowcolor0, sampler2D noisetex, mat4 modelViewInverse) {
    vec4 playerPos = modelViewInverse * vec4(viewPos, 1.0);
    vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz; //convert to shadow screen space
    // float distortFactor = getDistortFactor(shadowPos.xy);
    // shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
    // shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
    // shadowPos.z -= Shadow_Bias * (distortFactor * distortFactor) / abs(NGdotL); //apply shadow bias

    // vec3 shadowPos = calcShadowPos(viewPos, gbufferModelViewInverse);

    // if(shadowPos.x < -1.0 || shadowPos.x > 1.0 || shadowPos.y < -1.0 || shadowPos.y > 1.0)
    //     shadowPos.z = 0.0;

    vec3 shadowVal = vec3(0.0);
    #ifdef ShadowNoiseAnimated
        float randomAngle = texture2D(noisetex, texcoord * 20.0 + frameTimeCounter).r * 2.0 * PI;
    #else
        float randomAngle = texture2D(noisetex, texcoord * 20.0).r * 2.0 * PI;
    #endif

    float blockerDist = 0.0;
    float size = 0.0;
    for(int i = 0; i < ShadowBlockSamples; i++) {
        // dist = max(dist, abs(texture2D(shadowtex0, shadowPos.xy + rotation * 0.01 * shadowKernel[i]).r - shadowPos.z));
        vec3 shadowPosTemp = shadowPos;
        shadowPosTemp.xy += ShadowMaxBlur * 0.2 * GetVogelDiskSample(i, ShadowBlockSamples, randomAngle);
        float distortFactor = getDistortFactor(shadowPosTemp.xy);
        shadowPosTemp.xyz = distort(shadowPosTemp.xyz, distortFactor); //apply shadow distortion
        shadowPosTemp.xyz = shadowPosTemp.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
        // shadowPosTemp.z -= Shadow_Bias /* * (distortFactor * distortFactor) */ / abs(NGdotL); //apply shadow bias

        float a = texture2D(shadowtex0, shadowPosTemp.xy).r - shadowPosTemp.z;
        if(a < 0.01) {
            blockerDist += abs(a + shadowPosTemp.z);
            size += 1.0;
        }
    }
    blockerDist /= size;

    float distortFactor = getDistortFactor(shadowPos.xy);
    shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
    shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1

    // shadowPos = calcShadowPos(viewPos, gbufferModelViewInverse);

    // float penumbra = min(ShadowBlurScale * dist + ShadowMinBlur, ShadowMaxBlur);
    float penumbra = min(ShadowBlurScale * (shadowPos.z - blockerDist) / blockerDist + ShadowMinBlur, ShadowMaxBlur);
    // penumbra = 0.0004;
    // float penumbra = 0.0000001 * (shadowPos.z - dist) / dist;
    // float penumbra = 0.4 * dist + 0.0001;
    // penumbra *= float(penumbra < 0.03);
    // float penumbra = 1000.0 * abs(shadowPos.z - texture2D(shadowtex0, shadowPos.xy).r);
    // penumbra = 2.0;

    // shadowPos.z -= Shadow_Bias /* * (distortFactor * distortFactor) */ / abs(NGdotL); //apply shadow bias
    applyShadowBias(shadowPos, NGdotL);

    return softShadows(shadowPos, penumbra, ShadowSamples, randomAngle, shadowtex0, shadowtex1, shadowcolor0);
}

void volumetricFog(inout vec4 albedo, vec3 viewPos, vec2 texcoord, int time, float frameTimeCounter, float rainStrength, float wetness, sampler2D shadowtex0, sampler2D shadowtex1, sampler2D shadowcolor0, sampler2D noisetex, mat4 modelViewInverse) {
    #ifdef ShadowNoiseAnimated
        float randomAngle = texture2D(noisetex, texcoord * 20.0 + frameTimeCounter).r * 2.0 * PI;
    #else
        float randomAngle = texture2D(noisetex, texcoord * 20.0).r * 2.0 * PI;
    #endif
    
    vec3 rayIncrement = viewPos / VolFog_Steps;
    // float startOffset = texture2D(noisetex, fract(texcoord * vec2(viewWidth, viewHeight) / 256 + sin(1000*frameTimeCounter))).r;
    // startOffset = fract(startOffset + mod(frameTimeCounter, 64.0) * goldenRatioConjugate);
    // vec3 currentViewPos = 0 * normalize(viewPos);
    vec3 currentViewPos = vec3(0.0);
    vec3 shadowAmount = vec3(0.0);
    for(int i = 0; i < VolFog_Steps; i++) {
        currentViewPos += rayIncrement;
        vec3 shadowPos = calcShadowPos(currentViewPos, modelViewInverse);
        // float shadowDepth = texture2D(shadowtex0, shadowPos.xy).r;
        // if(shadowPos.z < shadowDepth) {
        //     shadowAmount += 1.0;
        // }
        #ifdef VolFog_SmoothShadows
            shadowAmount += softShadows(shadowPos, VolFog_SmoothShadowBlur, VolFog_SmoothShadowSamples, randomAngle, shadowtex0, shadowtex1, shadowcolor0);
        #else
            shadowAmount += shadowVisibility(shadowPos, shadowtex0, shadowtex1, shadowcolor0);
        #endif
    }
    shadowAmount /= VolFog_Steps;

    // float density = clamp(-1.0 + exp(length(viewPos) * 0.003), 0.0, 1.0);
    // vec3 fogColor = mix(vec3(0.5, 0.6, 0.7), vec3(0.0), 1.0-shadowAmount);
    // albedo.rgb = mix(albedo.rgb, fogColor, density);

    vec3 coefs = mix(20.0, 1000.0, 1.0) * vec3(2.0, 1.5, 1.0)*vec3(0.0000038, 0.0000105, 0.0000331);

    vec3 SunMoonColor = skyLightColor(time, rainStrength);
    vec3 fogColor = mix(SunMoonColor*0.1, SunMoonColor, shadowAmount);
    float dist = length(viewPos);
    // vec3 extColor = vec3(exp(-dist*be.x), exp(-dist*be.y), exp(-dist*be.z));
    // vec3 insColor = vec3(exp(-dist*bi.x), exp(-dist*bi.y), exp(-dist*bi.z));
    vec3 fogFactor = vec3(exp(-dist*coefs.r), exp(-dist*coefs.g), exp(-dist*coefs.b));

    // albedo = sRGBToLinear(albedo);
    // albedo.rgb =  fogColor*(1.0-extColor) +  albedo.rgb*insColor;
    albedo.rgb = mix(fogColor, albedo.rgb, fogFactor);
    // albedo = linearToSRGB(albedo);

    // albedo.rgb = fogColor;

    // albedo.rgb += shadowAmount * 2*vec3(0.13, 0.1, 0.08);
}

vec3 adjustLightMap(vec2 lmcoord, vec3 SunMoonColor) {
    vec3 skyAmbient = SunMoonColor * mix(vec3(0.07), vec3(0.4), lmcoord.y);
    vec3 torchAmbient = mix(vec3(0.0), vec3(0.9, 0.7, 0.4), lmcoord.x) * (1.2 - skyAmbient);

    return skyAmbient + torchAmbient;
}

void diffuseLighting(inout vec4 albedo, vec3 shadowVal, vec2 lmcoord, int time, float rainStrength) {
    vec3 SunMoonColor = skyLightColor(time, rainStrength);
    vec3 skyLight = SunMoonColor * shadowVal;
    vec3 skyAmbient = SunMoonColor * mix(vec3(0.07), vec3(0.4), lmcoord.y) * (1.0 - shadowVal);
    vec3 torchAmbient = mix(vec3(0.0), vec3(0.9, 0.7, 0.4), lmcoord.x) * (1.2 - skyLight);

        // if(NGdotL) < 0.01)
    //     NdotL = 0.0;
    // albedo.rgb *= min(vec3(max(NdotL, 0.0)), shadowVal) * 0.5 + 0.5;

    // albedo = linearToSRGB(albedo);
    albedo.rgb *= skyLight + skyAmbient + torchAmbient;
    // albedo = sRGBToLinear(albedo);
    // albedo.rgb *= 1.0;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

float DistributionGGX(vec3 normal, vec3 halfwayDir, float roughness) {
    float a2 = roughness*roughness;
    float NdotH = max(dot(normal, halfwayDir), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return a2 / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    return NdotV / (NdotV * (1.0 - k) + k);
}

float GeometrySmith(vec3 normal, vec3 viewDir, vec3 lightDir, float roughness) {
    float NdotV = max(dot(normal, viewDir), 0.0);
    float NdotL = max(dot(normal, lightDir), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec4 calcF0(vec3 specMap, vec3 albedo) {
    vec3 F0 = vec3(min(specMap.g, 0.04));
    float metalness = 0.0;
    if(specMap.g == 230.0 / 255.0) { // Iron
        F0 = vec3(0.56, 0.57, 0.58);
        metalness = 1.0;
    }
    else if(specMap.g == 231.0 / 255.0) { // Gold
        F0 = vec3(1.00, 0.71, 0.29);
        metalness = 1.0;
    }
    else if(specMap.g == 232.0 / 255.0) { // Aluminum
        F0 = vec3(0.96, 0.96, 0.97);
        metalness = 1.0;
    }
    else if(specMap.g == 233.0 / 255.0) { // Chrome
        F0 = vec3(0.56, 0.57, 0.58);
        metalness = 1.0;
    }
    else if(specMap.g == 234.0 / 255.0) { // Copper
        F0 = vec3(0.98, 0.82, 0.76);
        metalness = 1.0;
    }
    else if(specMap.g == 235.0 / 255.0) { // Lead
        F0 = vec3(0.56, 0.57, 0.58);
        metalness = 1.0;
    }
    else if(specMap.g == 236.0 / 255.0) { // Platinum
        F0 = vec3(0.56, 0.57, 0.58);
        metalness = 1.0;
    }
    else if(specMap.g == 237.0 / 255.0) { // Silver
        F0 = vec3(0.98, 0.97, 0.95);
        metalness = 1.0;
    }
    else if(specMap.g > 229.5 / 255.0) { // Albedo based metal
        F0 = albedo;
        metalness = 0.5;
    }

    return vec4(F0, metalness);
}

void PBRLighting(inout vec3 albedo, vec3 viewPos, vec3 normal, vec3 lightDir, vec2 lmcoord, vec3 specMap, vec3 shadowVal, vec3 light) {
    // light *= mix(3.5, 1.0, rainStrength);
    
    // vec3 viewDir = getCameraVector(linearDepth, texcoord);
    vec3 viewDir = normalize(viewPos);
    vec3 halfwayDir = normalize(viewDir + lightDir);

    // albedo = pow(albedo, vec3(2.2));

    // light = pow(light, vec3(2.2));

    vec4 F0Results = calcF0(specMap, albedo);
    vec3 F0 = F0Results.rgb;
    float metalness = F0Results.w;

    float porosity = (specMap.b < 64.9 / 255.0) ? specMap.b * 2.0 : 0.0;

    float roughness = max(pow(1.0 - specMap.r, 2.0), 0.02);
    // roughness = mix(roughness, min(roughness, 0.03), wetness);

    // albedo = mix(albedo, (1.0 - porosity) * albedo, wetness);
    // albedo = pow(albedo, mix(vec3(1.0), vec3(1.0 + 10.0 * porosity), wetness));

    vec3 F = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), F0);
    float NDF = DistributionGGX(normal, halfwayDir, roughness);
    float G = GeometrySmith(normal, viewDir, lightDir, roughness);

    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(normal, viewDir), 0.0) * max(dot(normal, lightDir), 0.0);
    vec3 specular = numerator / max(denominator, 0.001);

    vec3 kS = F;
    vec3 kD = clamp(vec3(1.0) - kS, 0.0, 1.0);
    // kD = vec3(1.0);
    // kD *= 1.0 - metalness;
        
    // add to outgoing radiance Lo
    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 Lo = (kD * albedo / PI + specular) * NdotL * light * shadowVal;

    /*vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.9 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= 1.0 - Shadow_Darkness;*/
    // vec3 ambient = (length(skyAmbient) > length(torchAmbient) ? skyAmbient : torchAmbient) * albedo * material.g;
    // vec3 ambient = (skyAmbient + torchAmbient) * albedo * material.g;
    vec3 ambient = adjustLightMap(lmcoord.rg, light) * albedo /* * material.g */;
    vec3 color = ambient + Lo;

    // color = color / (color + vec3(1.0));
    // color = pow(color, vec3(1.0/2.2)); 

    // albedo = color;
    // albedo = G;
    albedo = vec3(F);
}

vec3 cookTorrancePBRLighting(vec3 albedo, vec3 viewDir, vec3 normal, vec3 specMap, vec2 lmcoord, vec3 light, vec3 lightDir, vec3 shadowVal) {
    vec3 halfwayDir = normalize(viewDir + lightDir);

    vec4 F0Results = calcF0(specMap, albedo);
    vec3 F0 = F0Results.rgb;
    float metalness = F0Results.w;
    float roughness = max(pow(1.0 - specMap.r, 2.0), 0.02);

    vec3 fresnel = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), F0);
    float geometry = GeometrySmith(normal, viewDir, lightDir, roughness);
    float distribution = DistributionGGX(normal, halfwayDir, roughness);

    vec3 diffuse = albedo / PI * (1.0 - fresnel) * (1.0 - metalness);
    vec3 specular = (fresnel * geometry * distribution) / max(4.0 * dot(viewDir, normal) * dot(lightDir, normal), 0.001);

    vec3 ambient = adjustLightMap(lmcoord, light) * albedo * 0.2;

    return (diffuse + specular) * light * shadowVal * max(dot(normal, lightDir), 0.0) + ambient;
    // return vec3(fresnel);
}

float calcSSAO(vec3 normal, vec3 viewPos, vec2 texcoord, float viewWidth, float viewHeight, sampler2D depthTex, sampler2D aoNoiseTex, mat4 projectionInverse) {
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
		float sampleDepth = screenToView(offset.xy, texture2D(depthTex, offset.xy).r, projectionInverse).z; // texture2D(viewTex, offset.xy).z;
		
		// range check & accumulate:
		float rangeCheck = smoothstep(0.0, 1.0, SSAO_Radius / abs(fragPos.z - sampleDepth));
        // float rangeCheck= abs(fragPos.z - sampleDepth) < SSAO_Radius ? 1.0 : 0.0;
		occlusion += (sampleDepth >= sampleVal.z ? 1.0 : 0.0) * rangeCheck;
	}

	return clamp(1.0 - (SSAO_Strength * occlusion / half_sphere_16.length()), 0.0, 1.0);
}

vec3 calcSSR(vec2 texcoord, float depth, vec3 viewPos, vec3 normal, vec3 sunPosition, float eyeAltitude, sampler2D depthtex, sampler2D colortex, mat4 projectionMatrix, mat4 modelViewInverse) {
    vec3 rayDir = -reflect(normalize(-viewPos), normal);
    vec3 rayScreenDir = normalize(viewToScreen(viewPos + rayDir, projectionMatrix) - vec3(texcoord, depth));

    int initialSteps = 64;
    int binarySteps = 5;
    float rayLength = 1.0;

    vec3 startPoint = vec3(-1.0);
    vec3 endPoint = vec3(texcoord, depth);
    vec3 reflection = vec3(0.0);
    float bufferDepth = 0.0;

    float depthToleranceFactor = 0.000;
    float depthThreshold = 0.1;

    vec3 raySubDir = rayScreenDir * rayLength / initialSteps;
    endPoint += raySubDir;
    for(int i = 0; i < initialSteps; i++) {
        endPoint += raySubDir;
        bufferDepth = texture2D(depthtex, endPoint.xy).r;

        if(clamp(endPoint.xy, 0.0, 1.0) != endPoint.xy) {
            return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));
        }

        if(endPoint.z - bufferDepth > -bufferDepth*depthToleranceFactor) {
            startPoint = endPoint - raySubDir;
            reflection = texture2D(colortex, endPoint.xy).rgb;
            break;
        }
    }

    if(startPoint.x < -0.9)
        return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));

    for(int i = 0; i < binarySteps; i++) {
        vec3 midPoint = (startPoint + endPoint) / 2.0;
        bufferDepth = texture2D(depthtex, midPoint.xy).r;

        if(midPoint.z - bufferDepth > -bufferDepth*depthToleranceFactor) {
            reflection = texture2D(colortex, midPoint.xy).rgb;
            endPoint = midPoint;
        }
        else {
            startPoint = midPoint;
        }
    }

    if(linearizeDepthNorm(endPoint.z - bufferDepth) > depthThreshold)
        return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));

    return reflection;
}

vec3 calcSSRNew(vec2 texcoord, float depth, vec3 viewPos, vec3 normal, vec3 sunPosition, float eyeAltitude, sampler2D depthtex, sampler2D colortex, mat4 projectionMatrix, mat4 modelViewInverse) {
    vec3 rayDir = -reflect(normalize(-viewPos), normal);
    vec3 rayScreenDir = normalize(viewToScreen(viewPos + rayDir, projectionMatrix) - vec3(texcoord, depth));

    float xDist = rayScreenDir.x > 0 ? 1.0-texcoord.x : texcoord.x;
    float yDist = rayScreenDir.y > 0 ? 1.0-texcoord.y : texcoord.y;

    float xSlope = sqrt(1 + pow(rayScreenDir.y / rayScreenDir.x, 2.0));
    float ySlope = sqrt(1 + pow(rayScreenDir.x / rayScreenDir.y, 2.0));

    float xLength = xDist * xSlope;
    float yLength = yDist * ySlope;

    float rayLength = min(xLength, yLength);

    int initialSteps = 64;
    int binarySteps = 5;

    vec3 startPoint = vec3(-1.0);
    vec3 endPoint = vec3(texcoord, depth);
    vec3 reflection = vec3(0.0);
    float bufferDepth = 0.0;

    float thickness = 0.15;
    float depthToleranceFactor = 0.000;
    float depthThreshold = 0.1;

    vec3 raySubDir = rayScreenDir * rayLength / initialSteps;
    // endPoint += raySubDir;
    for(int i = 0; i < initialSteps; i++) {
        endPoint += raySubDir;
        bufferDepth = texture2D(depthtex, endPoint.xy).r;
        float depthDiff = linearizeDepthNorm(endPoint.z) - linearizeDepthNorm(bufferDepth);

        // if(clamp(endPoint.xy, 0.0, 1.0) != endPoint.xy) {
        //     return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));
        // }

        if(depthDiff > 0 && depthDiff < thickness) {
            startPoint = endPoint - raySubDir;
            reflection = texture2D(colortex, endPoint.xy).rgb;
            break;
        }
    }

    if(startPoint.x < -0.9 || bufferDepth == 1.0)
        return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));
        // return vec3(1.0);

    for(int i = 0; i < binarySteps; i++) {
        vec3 midPoint = (startPoint + endPoint) / 2.0;
        bufferDepth = texture2D(depthtex, midPoint.xy).r;
        float depthDiff = linearizeDepthNorm(endPoint.z) - linearizeDepthNorm(bufferDepth);

        if(depthDiff > 0 && depthDiff < thickness) {
            reflection = texture2D(colortex, midPoint.xy).rgb;
            endPoint = midPoint;
        }
        else {
            startPoint = midPoint;
        }
    }

    // // float depthDiff = endPoint.z - bufferDepth;
    // float depthDiff = linearizeDepthNorm(endPoint.z) - linearizeDepthNorm(bufferDepth);
    // if(abs(depthDiff) > 0.005)
    //     return skyColor(rayDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));
    //     // return vec3(0.0);

    // return vec3(float(abs(depthDiff) > 0.01));
    return reflection;

}

vec3 calcSSRSues(vec3 viewSpacePos, vec3 normal, vec3 sunPosition, float eyeAltitude, sampler2D depthTex, sampler2D colortex, mat4 modelViewInverse, mat4 projectionMatrix, mat4 projectionInverse) {
    // #ifdef SSR_Rough
    //     normal = normalize(normal * (texture2D(noisetex, texcoord).rgb * 0.002 - 0.001));
    // #endif

    vec3 reflectDir = reflect(normalize(viewSpacePos), normal);
    
    // vec2 screenSpacePos = texcoord;
    // vec3 viewSpaceDir = normalize(viewSpacePos);

    // vec3 reflectDir = normalize(reflect(viewSpaceDir, normal));
    vec3 viewSpaceVector = .999 * reflectDir;
    vec3 viewSpaceVectorFar = far * reflectDir;
    vec3 viewSpaceVectorPos = viewSpacePos + viewSpaceVector;
    vec3 currentPosition = viewToScreen(viewSpaceVectorPos, projectionMatrix);

    const int maxRefinements = 5;
	int numRefinements = 0;
	vec3 finalSamplePos = vec3(0.0/* , 0.0, -1.0 */);

	int numSteps = 0;

	float finalSampleDiff = 0.0;


    for(int i = 0; i < 40; i++) {

        if(-viewSpaceVectorPos.z > far * 1.4f ||
           -viewSpaceVectorPos.z < 0.0f)
        {
		   break;
		}

        vec2 samplePos = currentPosition.xy;
        float sampleDepth = screenToView(samplePos, texture2D(depthTex, samplePos).r, projectionInverse).z;


        float currentDepth = viewSpaceVectorPos.z;
        float diff = sampleDepth - currentDepth;
        float error = length(viewSpaceVector / pow(2.0, numRefinements));

        if(diff >= 0 && diff <= error * 2.0 && numRefinements <= maxRefinements) {
            viewSpaceVectorPos -= viewSpaceVector / pow(2.0, numRefinements);
            numRefinements++;
        }
        else if(diff >= 0 && diff <= error * 4.0 && numRefinements > maxRefinements) {
            finalSamplePos = vec3(samplePos, 1.0);
            finalSampleDiff = diff;
            break;
        }
        // else if(numRefinements > maxRefinements) {
        //     finalSamplePos = vec3(samplePos, -1.0);
        //     finalSampleDiff = diff;
        //     break;
        // }

        viewSpaceVectorPos += viewSpaceVector / pow(2.0f, numRefinements);

        if(numSteps > 1)
            viewSpaceVector *= 1.375;

        currentPosition = viewToScreen(viewSpaceVectorPos, projectionMatrix);

        if (currentPosition.x < 0 || currentPosition.x > 1 ||
            currentPosition.y < 0 || currentPosition.y > 1 ||
            currentPosition.z < 0 || currentPosition.z > 1)
        {
            break;
        }
        // currentPosition = clamp(currentPosition, vec3(0.001), vec3(0.999));

        numSteps++;
    }

    // vec4 color = vec4(1.0);
    // color.rgb = texture2D(colorTex, finalSamplePos).rgb;

    /* if(finalSampleDiff < 0) {
        finalSamplePos.z = -1.0;
    }
    else  */if (finalSamplePos.x == 0.0 || finalSamplePos.y == 0.0) {
		finalSamplePos.z = 0.0;
        return skyColor(reflectDir, normalize(sunPosition), eyeAltitude, mat3(modelViewInverse));
	}

    // return color;
    return texture2D(colortex, finalSamplePos.xy).rgb;
}
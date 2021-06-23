#define PI 3.1415926538

#define Shadow_Distort_Factor 0.10 //Distortion factor for the shadow map. [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define Shadow_Bias 0.005 //Increase this if you get shadow acne. Decrease this if you get peter panning. [0.000 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.012 0.014 0.016 0.018 0.020 0.022 0.024 0.026 0.028 0.030 0.035 0.040 0.045 0.050]
#define Shadow_Blur_Amount 1.0 //Multiplier for the amount of blur at the edges of shadows. Lower values means less blur (harder edges). Higher values can help hide aliasing in shadows. [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define Shadow_Darkness 0.6 //The darkness of shadows in the world. 1.0 means shadows are completely pitch black. 0.0 means shadows have no effect on brightness (invisible). [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.9 0.95 1.0]
#define HQ_Shadow_Filter //Increases shadow sample count, improving quality at a slight performance cost.

#define water_wave //Causes water to displace and wave.
#define leaves_wave //Causes leaves to russle and wave in the wind.
#define vine_wave //Causes vines to swing slightly in the wind.
#define grass_wave //Causes grass and some flowers to russle in the wind.

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 shadowLightPosition;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float near;
uniform float far;
uniform float wetness;
uniform int worldTime;
uniform int isEyeInWater;

const int shadowMapResolution = 2048; //The resolution of shadow map. Higher values leads to higher quality shaders. Lower values leads to better performance. [512 1024 2048 4096]
const float shadowDistance = 120; //The distance over which shadows are rendered in blocks. Higher values will cause shadows to render farther in the distance but also decrease shadow quality. [80 120 160 200 240]
const float sunPathRotation = -40; //Rotation of the path of the sun and moon in the sky. Helps reduce shadow acne at perpendicular angles. 0 means directly above the player. 90 means horizontal to the ground. Negative values are the opposite side of the vertical. [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90]
const float wetnessHalflife = 200.0;
const float drynessHalflife = 25.0;
const int noiseTextureResolution = 1080;
const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994)); //Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
/*
const int colortex2Format = RGB32F;
*/
const vec2 shadowKernel[] = vec2[](
    #ifndef HQ_Shadow_Filter
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
    
    #else
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

//euclidian distance is defined as sqrt(a^2 + b^2 + ...)
//this length function instead does cbrt(a^3 + b^3 + ...)
//this results in smaller distances along the diagonal axes.
float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec2 v) {
	return cubeLength(v) + Shadow_Distort_Factor;
}

vec3 distort(vec3 v, float factor) {
	return vec3(v.xy / factor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v.xy));
}

float linearDepth(float depth) {
	depth = depth * 2.0 - 1.0;
	depth = (2.0 * near * far) / (far + near - depth * (far - near));
	return min(depth / far, 1.0);
}

vec3 fixedSunPosition() {
    //minecraft's native calculateCelestialAngle() function, ported to GLSL.
		float ang = fract(worldTime / 24000.0 - 0.25);
		ang = (ang + (cos(ang * 3.14159265358979) * -0.5 + 0.5 - ang) / 3.0) * 6.28318530717959; //0-2pi, rolls over from 2pi to 0 at noon.

		//this one tracks optifine's sunPosition uniform.
		return mat3(gbufferModelView) * vec3(-sin(ang), cos(ang) * sunRotationData);
		//this one tracks the center of the *actual* sun, which is ever-so-slightly different.
		//sunPosNorm = normalize((gbufferModelView * vec4(sin(ang) * -100.0, (cos(ang) * 100.0) * sunRotationData, 1.0)).xyz);
		//I choose to use the sunPosition one for 2 reasons:
		//1: it's simpler.
		//2: it's consistent with other programs which are sensitive to subtle differences.
}

vec3 fixedLightPosition() {
    if(worldTime < 23215 || worldTime > 12785)
        return 1.0 - fixedSunPosition();
    
    return fixedSunPosition();
}

float dayTimeFactor() {
    float adjustedTime = mod(worldTime + 785.0, 24000.0);

    if(adjustedTime > 13570.0)
        return sin((adjustedTime - 3140.0) * PI / 10430.0);

    return sin(adjustedTime * PI / 13570.0);
}

vec3 skyLightColor() {
    float timeFactor = dayTimeFactor();
	return mix(mix(vec3(0.25, 0.25, 0.4), vec3(0.2), rainStrength), mix(mix(vec3(1.0, 0.6, 0.4), vec3(1.1, 1.1, 0.9), clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0)), vec3(0.4), rainStrength), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
}

float adjustLightmapTorch(float torch) {
    const float K = 1.6f;
    const float P = 2.8f;
    return K * pow(torch, P);
    // return pow(4 * pow(torch - 0.5, 3.0) + 0.5, 3.0);
}

float adjustLightmapSky(float sky){
    float sky_2 = sky * sky;
    return sky_2 * sky_2;
}

vec3 lightmapSky(float amount) {
	return mix(vec3(0.1), skyLightColor(), adjustLightmapSky(amount));
}

vec3 lightmapTorch(float amount) {
	return mix(vec3(0.0), vec3(3.0, 1.7, 0.7), adjustLightmapTorch(amount));
}

vec3 calculateShadow(vec3 shadowPos, float NdotL, vec2 texcoord) {
    vec3 shadowVal = vec3(0.0);
	float randomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
    float cosTheta = cos(randomAngle);
    float sinTheta = sin(randomAngle);
    mat2 rotation =  0.0006 * mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
	if(shadowPos.s == -1.0 || texture2D(shadowtex1, shadowPos.xy).r == 1.0) {
		shadowVal = vec3(1.0);
	}
	else {
		for(int i = 0; i < shadowKernel.length(); i++) {
			vec2 offset = Shadow_Blur_Amount * rotation * shadowKernel[i];
			vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy + offset);
			shadowColor.rgb = shadowColor.rgb * (1.0 - shadowColor.a);
			float visibility0 = step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy + offset).r);
			float visibility1 = step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy + offset).r);
			shadowVal += mix(shadowColor.rgb * visibility1, vec3(1.0f), visibility0);
		}
		shadowVal /= shadowKernel.length();
	}

	return min(shadowVal, max(NdotL, 0.0));
}

vec3 adjustLightMap(vec3 shadowVal, vec2 lmcoord) {
    vec3 skyLight = lightmapSky(lmcoord.g) * (shadowVal * Shadow_Darkness + (1.0 - Shadow_Darkness));
	vec3 torchLight = lightmapTorch(lmcoord.r) * (1.1 - skyLight);

	return skyLight + torchLight;
}

vec3 getCameraVector(float depth, vec2 texcoord) {
    vec4 view = gbufferProjectionInverse * -vec4(texcoord * 2.0 - 1.0, linearDepth(depth), 1.0);
    return normalize(view.xyz);
}

vec3 reflectFromCamera(vec3 norm, float depth, vec2 texcoord) {
    vec3 viewDir = getCameraVector(depth, texcoord);
    return -reflect(viewDir, norm);
}

// float calcSpecular(vec3 norm, float depth, vec3 material, vec2 texcoord, float power) {
//     // vec3 reflectDir = reflectFromCamera(norm, depth, texcoord);
//     // float mult = material.r * 1.5 + wetness * 0.2;
//     // float spec = dot(normalize(shadowLightPosition), reflectDir);
//     // spec = pow(spec, power) * mult;
//     // return clamp(spec, 0.0, 1.0);

//     vec3 lightDir = normalize(shadowLightPosition);
//     vec3 viewDir = getCameraVector(depth, texcoord);
//     vec3 halfwayDir = normalize(viewDir + lightDir);
//     float mult = material.r * 1.5 + wetness * 0.2;
//     return mult * pow(max(dot(norm, halfwayDir), 0.0), power);
//     // return pow(PI, 0.0);
// }

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

float DistributionGGX(vec3 normal, vec3 halfwayDir, float roughness) {
    float a = roughness;
    float a2 = a*a;
    float NdotH = max(dot(normal, halfwayDir), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float num = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness) {
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}

float GeometrySmith(vec3 normal, vec3 viewDir, vec3 lightDir, float roughness) {
    float NdotV = max(dot(normal, viewDir), 0.0);
    float NdotL = max(dot(normal, lightDir), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec3 PBRLighting(vec2 texcoord, float depth, vec3 albedo, vec3 normal, vec3 specMap, vec3 material, vec3 light, vec2 lmcoord) {
    vec3 lightDir = normalize(shadowLightPosition);
    vec3 viewDir = getCameraVector(depth, texcoord);
    vec3 halfwayDir = normalize(viewDir + lightDir);

    albedo = pow(albedo, vec3(2.2));

    // light = pow(light, vec3(2.2));

    // vec3 F0 = mix(vec3(0.1), vec3(1.00, 0.71, 0.29), specMap.g);
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
        metalness = 1.0;
    }
    
    float roughness = pow(1.0 - specMap.r, 2.0) * 0.99 + 0.01;
    roughness = mix(roughness, min(roughness, 0.03), wetness);

    float porosity = (specMap.b < 64.9 / 255.0) ? specMap.b * 2.0 : 0.0;

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
    vec3 Lo = (kD * albedo / PI + specular) * NdotL * light;

    vec3 skyAmbient = lightmapSky(lmcoord.g) * (1.0 - Shadow_Darkness);
    vec3 torchAmbient = lightmapTorch(lmcoord.r);
    // vec3 ambient = (length(skyAmbient) > length(torchAmbient) ? skyAmbient : torchAmbient) * albedo * material.g;
    vec3 ambient = (skyAmbient + torchAmbient) * albedo /* material.g*/;
    vec3 color = ambient + Lo;

    color = color / (color + vec3(1.0));
    color = pow(color, vec3(1.0/2.2)); 

    return color;
}

vec3 blendToFog(vec3 color, float depth) {
    if(isEyeInWater == 0)
        return mix(color, fogColor, clamp((linearDepth(depth) + mix(-0.1, 0.05, rainStrength)) * mix(0.8, 2.5, rainStrength), 0.0, 1.0));
    else if(isEyeInWater == 1)
        return mix(color, fogColor, linearDepth(depth));
    else
        return mix(color, fogColor, linearDepth(depth));
}

vec3 waveOffset(float blockType, vec4 vertex, vec2 texcoord, vec2 mc_midTexCoord, vec3 normal) {

    if(blockType < 0.0)
        return vec3(0.0);

    // Water and lillypad wave
    if(blockType < 1.0) {
    #ifdef water_wave
        /*float offset = 0.04 * ((sin((vertex.x + frameTimeCounter) * PI * 0.375) + cos((vertex.z + frameTimeCounter) * PI * 0.25))
                    * cos((vertex.x + frameTimeCounter) * PI * 0.5) + sin((vertex.z + frameTimeCounter) * PI * -0.375)) - (blockType == 0.5 ? 0.08 : 0.0);

        float offsetRain = 0.04 * ((sin((vertex.x + frameTimeCounter) * PI * 0.75) + cos((vertex.z + frameTimeCounter) * PI * 0.5))
                    * cos((vertex.x + frameTimeCounter) * PI * 1.0) + sin((vertex.z + frameTimeCounter) * PI * -0.75)) - (blockType == 0.5 ? 0.08 : 0.0);*/

        float offset = 0.06 * cos(.25 * PI * vertex.x + .125 * PI * vertex.z + 2.0 * frameTimeCounter)
                        + 0.04 * sin(.75 * PI * vertex.x + .25 * PI * vertex.z + 3.0 * frameTimeCounter)
                        + 0.005 * cos(1.5 * PI * vertex.x + PI * vertex.z + 4.0 * frameTimeCounter)
                        - 0.0;
        
        float offsetRain = 0.06 * cos(.25 * PI * vertex.x + .125 * PI * vertex.z + 6.0 * frameTimeCounter)
                        + 0.04 * sin(.75 * PI * vertex.x + .25 * PI * vertex.z + 9.0 * frameTimeCounter)
                        + 0.005 * cos(1.5 * PI * vertex.x + PI * vertex.z + 12.0 * frameTimeCounter)
                        - 0.0;

        // Wave amplitudes
        /*float a0 = mix(0.0, 0.05, texture2D(noisetex, vec2(0.5 + 0.0001 * frameTimeCounter, 0.3 + 0.0002 * frameTimeCounter)).r);
        float a1 = mix(0.0, 0.05, texture2D(noisetex, vec2(0.6 + 0.0009 * frameTimeCounter, 0.4 + 0.0003 * frameTimeCounter)).r);
        float a2 = mix(0.0, 0.05, texture2D(noisetex, vec2(0.2 + 0.0006 * frameTimeCounter, 0.7 + 0.0008 * frameTimeCounter)).r);
        float a3 = mix(0.0, 0.05, texture2D(noisetex, vec2(0.9 + 0.0005 * frameTimeCounter, 0.8 + 0.0007 * frameTimeCounter)).r);

        // Wave frequencies
        float w0 = mix(2.0, 8.0, texture2D(noisetex, vec2(0.5 + 0.0001 * frameTimeCounter, 0.3 + 0.0002 * frameTimeCounter)).r);
        float w1 = mix(2.0, 8.0, texture2D(noisetex, vec2(0.6 + 0.0009 * frameTimeCounter, 0.4 + 0.0003 * frameTimeCounter)).r);
        float w2 = mix(2.0, 8.0, texture2D(noisetex, vec2(0.2 + 0.0006 * frameTimeCounter, 0.7 + 0.0008 * frameTimeCounter)).r);
        float w3 = mix(2.0, 8.0, texture2D(noisetex, vec2(0.9 + 0.0005 * frameTimeCounter, 0.8 + 0.0007 * frameTimeCounter)).r);
        

        // Wave speeds
        float s0 = w0 * mix(0.5, 1.5, texture2D(noisetex, vec2(0.5 + 0.0001 * frameTimeCounter, 0.3 + 0.0002 * frameTimeCounter)).r);
        float s1 = w1 * mix(0.5, 1.5, texture2D(noisetex, vec2(0.6 + 0.0009 * frameTimeCounter, 0.4 + 0.0003 * frameTimeCounter)).r);
        float s2 = w2 * mix(0.5, 1.5, texture2D(noisetex, vec2(0.2 + 0.0006 * frameTimeCounter, 0.7 + 0.0008 * frameTimeCounter)).r);
        float s3 = w3 * mix(0.5, 1.5, texture2D(noisetex, vec2(0.9 + 0.0005 * frameTimeCounter, 0.8 + 0.0007 * frameTimeCounter)).r);

        // Wave angles
        float d0 = mix(0.0, 6.28318, texture2D(noisetex, vec2(0.5 + 0.0001 * frameTimeCounter, 0.3 + 0.0002 * frameTimeCounter)).r);
        float d1 = mix(0.0, 6.28318, texture2D(noisetex, vec2(0.6 + 0.0009 * frameTimeCounter, 0.4 + 0.0003 * frameTimeCounter)).r);
        float d2 = mix(0.0, 6.28318, texture2D(noisetex, vec2(0.2 + 0.0006 * frameTimeCounter, 0.7 + 0.0008 * frameTimeCounter)).r);
        float d3 = mix(0.0, 6.28318, texture2D(noisetex, vec2(0.9 + 0.0005 * frameTimeCounter, 0.8 + 0.0007 * frameTimeCounter)).r);

        // Wave direction vectors
        vec2 D0 = vec2(cos(d0), sin(d0));
        vec2 D1 = vec2(cos(d1), sin(d1));
        vec2 D2 = vec2(cos(d2), sin(d2));
        vec2 D3 = vec2(cos(d3), sin(d3));


        float offset =    a0 * sin(dot(D0, vertex.xz) * w0 + frameTimeCounter * s0)
                        + a1 * sin(dot(D1, vertex.xz) * w1 + frameTimeCounter * s1)
                        + a2 * sin(dot(D2, vertex.xz) * w2 + frameTimeCounter * s2)
                        + a3 * sin(dot(D3, vertex.xz) * w3 + frameTimeCounter * s3);

        float offsetRain = offset;*/

        return vec3(0.0,
                    mix(offset, offsetRain, rainStrength),
                    0.0);
    #endif
    }

    // Lava
    else if(blockType < 2.0) {
    #ifdef water_wave
        float offset = 0.04 * ((sin((vertex.x + frameTimeCounter) * PI * 0.1875) + cos((vertex.z + frameTimeCounter) * PI * 0.125))
                    * cos((vertex.x + frameTimeCounter) * PI * 0.25) + sin((vertex.z + frameTimeCounter) * PI * -0.1875));

        return vec3(0.0,
                    offset,
                    0.0);
    #endif
    }

    // Vines wave
    else if(blockType < 3.0) {
    #ifdef vine_wave
        float offset = 0.05 * mix(sin(vertex.y + frameTimeCounter * PI * 0.5), sin(vertex.y + frameTimeCounter * PI * 2.0), rainStrength);

        if(normal.x != 0.0)
            return vec3(offset, 0.0, 0.0);
        else
            return vec3(0.0, 0.0, offset);
    #endif
    }

    // Grass and other plants wave
    else if(blockType < 4.0) {
    #ifdef grass_wave
        return float(texcoord.y < mc_midTexCoord.y) *
                    vec3(   0.1 * (pow(sin(vertex.x + frameTimeCounter * PI * 0.25), 2.0) * mix(1.0, cos(vertex.x + frameTimeCounter * PI * 2.0), rainStrength) - 0.5), 
                            0.0,
                            0.1 * (pow(cos(vertex.z + frameTimeCounter * PI * 0.3), 2.0) * mix(1.0, sin(vertex.z + frameTimeCounter * PI * 2.0), rainStrength) - 0.5));
    #endif
    }

    // Leaves wave
    else if(blockType < 5.0) {
    #ifdef leaves_wave
        return vec3(    mix(0.05, 0.08, rainStrength) * ((pow(sin((vertex.x + frameTimeCounter) * PI * 0.25), 2.0) - 0.5) * mix(1.0, cos(vertex.z + frameTimeCounter * PI * 2.0), rainStrength) - 0.0), 
                        mix(0.05, 0.08, rainStrength) * ((pow(cos((vertex.y + frameTimeCounter) * PI * 0.125), 2.0) - 0.5) * mix(1.0, sin(vertex.x + frameTimeCounter * PI * 2.0), rainStrength) - 0.0),
                        mix(0.05, 0.08, rainStrength) * ((pow(cos((vertex.z + frameTimeCounter) * PI * 0.25), 2.0) - 0.5) * mix(1.0, sin(vertex.y + frameTimeCounter * PI * 2.0), rainStrength) - 0.0));
    #endif
    }

    return vec3(0.0);
}

float getBlockType(in float entity) {
    //Water
    if(entity == 9.0)
        return 0.1;
    
    //Lillypad
    if(entity == 111.0)
        return 0.5;

    //Lava
    if(entity == 11.0)
        return 1.0;
    
    //Vines
    if(entity == 106.0)
        return 2.0;

    //Grass
    if(entity == 31.0 || entity == 37.0 || entity == 38.0 || entity == 59.0 || entity == 115.0 || entity == 141.0 || entity == 142.0)
        return 3.0;
    
    //Leaves
    if(entity == 161.0 || entity == 18.0)
        return 4.0;

    return -1.0;
}
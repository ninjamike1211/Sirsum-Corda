#define PI 3.1415926538

#define Shadow_Distort_Factor 0.10 //Distortion factor for the shadow map. [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define Shadow_Bias 0.005 //Increase this if you get shadow acne. Decrease this if you get peter panning. [0.000 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.012 0.014 0.016 0.018 0.020 0.022 0.024 0.026 0.028 0.030 0.035 0.040 0.045 0.050]
#define Shadow_Blur_Amount 1.0 //Multiplier for the amount of blur at the edges of shadows. Lower values means less blur (harder edges). Higher values can help hide aliasing in shadows. [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define Shadow_Darkness 0.8 //The darkness of shadows in the world. 1.0 means shadows are completely pitch black. 0.0 means shadows have no effect on brightness (invisible). [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.9 0.95 1.0]
#define Shadow_Filter 2 //Increases shadow sample count, improving quality at a slight performance cost. [0 1 2]
#define Shadow_Transparent 2 //Controls how semi-transparent objects cast shadows. off: transparent objects don't cast shadows. opaque: transparent objects cast solid shadows. colored: transparent objects cast colored shadows based on their color and opacity. [0 1 2]

#define water_wave //Causes water to displace and wave.
#define leaves_wave //Causes leaves to russle and wave in the wind.
#define vine_wave //Causes vines to swing slightly in the wind.
#define grass_wave //Causes grass and some flowers to russle in the wind.

#define SSAO 2 // Screen space ambient occlusion. Provides better shadows in corners and small spaces at performance cost. [0 1 2 3 4]
#define SSAO_Radius 3.0 // Radius of SSAO. Higher values causes ao to be more spread out. Lower values will concentrate shadows more in corners. [0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0]

#define Bloom_Threshold 1.0 //Threshold for bloom, lower values mean more bloom on darker objects. [0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define PBR_Lighting

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 shadowLightPosition;
uniform ivec2 eyeBrightnessSmooth;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float wetness;
uniform int worldTime;
uniform int isEyeInWater;

const int shadowMapResolution = 2048; //The resolution of shadow map. Higher values leads to higher quality shaders. Lower values leads to better performance. [512 1024 2048 4096]
const float shadowDistance = 120; //The distance over which shadows are rendered in blocks. Higher values will cause shadows to render farther in the distance but also decrease shadow quality. [80 120 160 200 240]
const float sunPathRotation = -40; //Rotation of the path of the sun and moon in the sky. Helps reduce shadow acne at perpendicular angles. 0 means directly above the player. 90 means horizontal to the ground. Negative values are the opposite side of the vertical. [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90]
const float wetnessHalflife = 200.0;
const float drynessHalflife = 25.0;
const int noiseTextureResolution = 512;
const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994)); //Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
/*
const int colortex2Format = RGB32F;
*/
#if SSAO != 0
const vec3 aoKernel[] = vec3[](
    #if SSAO == 1
        vec3(-0.040092375, -0.085082404, 0.033964507),
        vec3(0.07686139, -0.005956394, 0.08406606),
        vec3(-0.032883804, -0.1414308, 0.057706576),
        vec3(-0.15006906, -0.14658183, 0.085578114),
        vec3(0.03055816, -0.30500218, 0.10800393),
        vec3(0.12736452, -0.12108572, 0.41596302),
        vec3(-0.23230846, -0.52947176, 0.18229501),
        vec3(0.31171134, 0.6173404, 0.3799296)
    #elif SSAO == 2
        vec3(0.06750871, 0.055483162, 0.048622973),
        vec3(0.08817828, -0.0150950905, 0.052078906),
        vec3(-0.08528654, 0.07219002, 0.022914235),
        vec3(0.041928172, -0.08608985, 0.090331726),
        vec3(0.14918147, 0.033809237, 0.031872965),
        vec3(0.033643417, 0.034548324, 0.18159686),
        vec3(0.07491968, 0.2003771, 0.074609786),
        vec3(0.097285494, 0.19649309, 0.16141427),
        vec3(-0.004644283, 0.2610817, 0.19349362),
        vec3(-0.2724808, -0.27035496, 0.026589438),
        vec3(0.22743785, -0.3504202, 0.17142457),
        vec3(0.4234191, 0.28381643, 0.12727869),
        vec3(0.31245655, -0.5187174, 0.02902149),
        vec3(0.6513573, -0.21525997, 0.105962284),
        vec3(0.6569041, -0.3880737, 0.20123476),
        vec3(0.5024354, -0.29774883, 0.672914)
    #elif SSAO == 3
        vec3(0.069431655, 0.040512662, 0.059480842),
        vec3(0.05884631, 0.0035979126, 0.08185793),
        vec3(-0.074091464, -0.02866131, 0.06636617),
        vec3(0.06360852, 0.06554057, 0.057471674),
        vec3(0.04830485, -0.07395963, 0.072158635),
        vec3(-0.03682454, 0.104013614, 0.051985096),
        vec3(0.07220624, 0.06320196, 0.09011675),
        vec3(0.0478162, -0.13414294, 0.013685009),
        vec3(0.1267123, 0.08762908, 0.026061395),
        vec3(-0.011465177, -0.17073913, 0.004816053),
        vec3(0.123100154, 0.124983795, 0.06729256),
        vec3(-0.07089526, -0.15086177, 0.12163032),
        vec3(-0.13371174, -0.12891957, 0.12973621),
        vec3(0.23262544, -0.055290237, 0.06780944),
        vec3(0.022970699, 0.23253542, 0.13974331),
        vec3(0.22677298, 0.004900441, 0.19289218),
        vec3(-0.12767176, -0.27222365, 0.123366065),
        vec3(0.26587808, -0.20422705, 0.11366146),
        vec3(-0.12372873, -0.2571961, 0.2580425),
        vec3(0.28893417, 0.039911225, 0.2984142),
        vec3(-0.16237342, -0.3133139, 0.2817409),
        vec3(0.26509774, 0.38389802, 0.14176378),
        vec3(-0.41266912, -0.29397824, 0.13898318),
        vec3(0.25083584, -0.20719247, 0.46185657),
        vec3(-0.25281924, 0.50966007, 0.20944722),
        vec3(0.32518202, -0.33133268, 0.45396826),
        vec3(-0.5971795, -0.17293268, 0.30871043),
        vec3(0.51756454, 0.52648634, 0.06007654),
        vec3(-0.19645077, 0.45719165, 0.6123745),
        vec3(0.6529396, 0.4847204, 0.20713681),
        vec3(0.72675693, -0.131368, 0.49847344),
        vec3(0.59863853, -0.54075235, 0.4914699)
    #elif SSAO == 4
        vec3(-0.034980517, -0.07308654, 0.058606513),
        vec3(0.03756984, -0.072102696, 0.0585978),
        vec3(0.06918004, 0.034017343, 0.065065324),
        vec3(-0.005725489, -0.017689845, 0.10026818),
        vec3(-0.0024451462, -0.10229702, 0.015646892),
        vec3(-0.031925168, -0.02320752, 0.09783151),
        vec3(-0.06793229, 0.05529296, 0.063027725),
        vec3(-0.01209211, 0.043860555, 0.10099145),
        vec3(0.10555697, 0.008753485, 0.042324428),
        vec3(0.081875466, -0.048372656, 0.069518544),
        vec3(-0.02898162, -0.0020893984, 0.11846109),
        vec3(-0.10734179, -0.038997177, 0.054600425),
        vec3(0.001121658, 0.10839674, 0.07468697),
        vec3(0.0382355, -0.13062601, 0.016750216),
        vec3(-0.10653227, -0.024923487, 0.09218294),
        vec3(0.020593332, -0.10940843, 0.09968734),
        vec3(0.10870629, -0.05270174, 0.09909357),
        vec3(-0.101664364, 0.07077516, 0.10671365),
        vec3(-0.09397825, -0.13871153, 0.03512405),
        vec3(-0.07309548, -0.010214948, 0.16342837),
        vec3(-0.13357458, -0.060898818, 0.11726911),
        vec3(-0.1812479, 0.0051940037, 0.07675678),
        vec3(-0.13638212, 0.09606439, 0.12145328),
        vec3(0.081188925, 0.14238939, 0.14103664),
        vec3(0.14691381, 0.08068207, 0.15243787),
        vec3(0.12507543, 0.09452677, 0.17817385),
        vec3(-0.029932378, -0.15652287, 0.19072066),
        vec3(0.16865447, -0.18223238, 0.07772384),
        vec3(0.18051505, 0.13493875, 0.15275605),
        vec3(-0.02180126, 0.22166462, 0.17746793),
        vec3(0.138826, 0.2622502, 0.024689237),
        vec3(0.15371771, 0.11623063, 0.2442952),
        vec3(0.13526349, 0.2697097, 0.12077029),
        vec3(0.1313422, 0.31269744, 0.009053342),
        vec3(-0.0022185133, 0.31079093, 0.16947818),
        vec3(-0.273788, -0.19623113, 0.15105066),
        vec3(-0.16376108, 0.298388, 0.17941986),
        vec3(-0.197984, -0.21250074, 0.27620816),
        vec3(0.32193616, 0.15964846, 0.21212348),
        vec3(-0.029422954, -0.3082821, 0.30435112),
        vec3(-0.112089105, 0.019694295, 0.4369861),
        vec3(-0.27036008, -0.37540528, 0.07921735),
        vec3(-0.44118622, -0.17253464, 0.115490176),
        vec3(0.3170158, 0.014442723, 0.39446947),
        vec3(-0.3384772, 0.34697533, 0.20267364),
        vec3(0.45703468, 0.06094783, 0.29046714),
        vec3(-0.37736368, -0.24280304, 0.34322315),
        vec3(-0.21585187, -0.4170773, 0.3494561),
        vec3(0.008988276, 0.3492018, 0.49549612),
        vec3(0.26397067, 0.3077667, 0.47899377),
        vec3(0.15404774, -0.57045406, 0.26918998),
        vec3(0.48351988, 0.40117705, 0.23704346),
        vec3(0.10314443, -0.6246343, 0.2846478),
        vec3(-0.10114718, -0.5171652, 0.48652062),
        vec3(-0.5003709, -0.24524792, 0.48800862),
        vec3(-0.54776156, -0.43065378, 0.3149907),
        vec3(0.1332165, -0.53897214, 0.56069785),
        vec3(-0.15972456, 0.39317474, 0.69449353),
        vec3(-0.688053, 0.18012664, 0.44533956),
        vec3(0.7846323, 0.08730391, 0.3531672),
        vec3(-0.6566118, 0.50826424, 0.32316768),
        vec3(-0.32328036, 0.2777686, 0.8126062),
        vec3(0.56942135, -0.6181151, 0.43129668),
        vec3(-0.84336746, -0.41986006, 0.2396183)
    #endif
);
#endif

#if Shadow_Filter != 0
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
#endif

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

vec3 getTopSkyColor(float time) {
    vec3 color = mix(vec3(0.0, 0.01, 0.04), vec3(0.3, 0.5, 0.8), clamp(2.0 * (time + 0.4), 0.0, 1.0));
    return mix(color, mix(vec3(0.2), vec3(0.45), clamp(2.0 * (time + 0.4), 0.0, 1.0)), rainStrength);
}

vec3 getBottomSkyColor(float time) {
    vec3 color = mix(vec3(0.06, 0.07, 0.1), mix(vec3(0.75, 0.6, 0.5), vec3(0.6, 0.8, 1.0), clamp(5.0 * (time - 0.2), 0.0, 1.0)), clamp(2.0 * (time + 0.4), 0.0, 1.0));
    return mix(color, mix(vec3(.15), vec3(0.35), clamp(2.0 * (time + 0.4), 0.0, 1.0)), rainStrength);
}

vec3 getSunColor(float time) {
    vec3 color = mix(vec3(0.9, 0.4, 0.1), vec3(1.0, 0.6, 0.2), clamp(4.0 * (time + 0.05), 0.0, 1.0));
    return mix(color, vec3(0.5, 0.45, 0.35), rainStrength);
}

vec3 getSunBlurColor(float time) {
    vec3 color = mix(vec3(1.0, 1.0, 1.0), vec3(1.0, 1.0, 1.0), 1.0 - clamp(5.0 * (time - 0.2), 0.0, 1.0));
    return mix(color, vec3(0.5), rainStrength);
}

vec3 skyLightColor() {
    float timeFactor = dayTimeFactor();
	return mix(mix(vec3(0.06, 0.06, 0.14), vec3(0.08), rainStrength), mix(mix(vec3(1.0, 0.6, 0.4), vec3(1.5, 1.5, 1.2), clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0)), vec3(0.3), rainStrength), clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
}

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 getSkyColor(vec3 dir, vec3 topskycolor, vec3 bottomskycolor, vec3 suncolor, vec3 sunblurcolor, vec3 sunPos, vec3 upPos, float time) {
    float upDot = dot(dir, upPos);
    vec3 color = mix(topskycolor, bottomskycolor, fogify(max(upDot, 0.0), 0.1));

    float sunDotV = max(dot(sunPos, dir), 0.0);
    float sunBlur = smoothstep(0.996, 0.9975, sunDotV);
    #ifdef OLD_SUN
        sunBlur = 0.0;
    #endif
    float sunAmount = pow(sunDotV, 2.0);
    sunAmount -= sunBlur;
    sunAmount *= smoothstep(-0.3, -.16, time);
    sunAmount *= 1.0 - clamp(5.0 * (time - 0.2), 0.0, 1.0);
    sunAmount *= min(pow(1.0 - dot(dir, upPos), 3.0), 1.0);

    return sunAmount * suncolor + sunBlur * sunblurcolor + max(1.0 - sunAmount - sunBlur, 0.0) * color;
}

float adjustLightmapTorch(float torch) {
    const float K = 2.3f;
    const float P = 3.7f;
    return K * pow(torch, P);
    // return pow(4 * pow(torch - 0.5, 3.0) + 0.5, 3.0);
}

float adjustLightmapSky(float sky){
    float sky_2 = sky * sky;
    return sky_2 * sky_2;
}

vec3 lightmapSky(float amount) {
	return mix(vec3(0.03), skyLightColor(), adjustLightmapSky(amount));
}

vec3 lightmapTorch(float amount) {
	return mix(vec3(0.0), vec3(2.8, 1.1, 0.25), adjustLightmapTorch(amount));
}

vec3 shadowVisibility(vec3 shadowPos) {
    #if Shadow_Transparent == 0
        return vec3(step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy).r));
    #elif Shadow_Transparent == 1
        return vec3(step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy).r));
    #elif Shadow_Transparent == 2
        vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
        shadowColor.rgb = shadowColor.rgb * (1.0 - shadowColor.a);
        float visibility0 = step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy).r);
        float visibility1 = step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy).r);
        return mix(shadowColor.rgb * visibility1, vec3(1.0f), visibility0);
    #endif
}

vec3 calculateShadow(vec3 shadowPos, float NdotL, vec2 texcoord) {
    #if Shadow_Filter > 0
        vec3 shadowVal = vec3(0.0);
        float randomAngle = texture2D(noisetex, texcoord * 20.0f).r * 100.0f;
        float cosTheta = cos(randomAngle);
        float sinTheta = sin(randomAngle);
        mat2 rotation =  0.0006 * mat2(cosTheta, -sinTheta, sinTheta, cosTheta);
        if(shadowPos.s == -1.0 || texture2D(shadowtex1, shadowPos.xy).r == 1.0) {
            shadowVal = vec3(1.0);
        }
        else {
            for(int i = 0; i < shadowKernel.length(); ++i) {
                vec2 offset = Shadow_Blur_Amount * rotation * shadowKernel[i];
                shadowVal += shadowVisibility(shadowPos + vec3(offset, 0.0));
            }
            shadowVal /= shadowKernel.length();
        }

        return min(shadowVal, max(NdotL, 0.0));
    #else
        return shadowVisibility(shadowPos);
    #endif
}

vec3 adjustLightMap(vec2 lmcoord) {
    // vec3 skyLight = lightmapSky(lmcoord.g) * (shadowVal * Shadow_Darkness + (1.0 - Shadow_Darkness));
	// vec3 torchLight = lightmapTorch(lmcoord.r) * (1.1 - skyLight);

	// return skyLight + torchLight;

    vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.75 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= (1.0 - Shadow_Darkness);

    return skyAmbient + torchAmbient;
}

vec3 adjustLightMapShadow(vec3 shadow, vec2 lmcoord) {
    vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.9 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= shadow * Shadow_Darkness + (1.0 - Shadow_Darkness);

    return skyAmbient + torchAmbient;
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
    light *= mix(3.5, 1.0, rainStrength);
    
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

    float porosity = (specMap.b < 64.9 / 255.0) ? specMap.b * 2.0 : 0.0;

    float roughness = max(pow(1.0 - specMap.r, 2.0), 0.02);
    roughness = mix(roughness, min(roughness, 0.03), wetness);

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

    /*vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.9 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= 1.0 - Shadow_Darkness;*/
    // vec3 ambient = (length(skyAmbient) > length(torchAmbient) ? skyAmbient : torchAmbient) * albedo * material.g;
    // vec3 ambient = (skyAmbient + torchAmbient) * albedo * material.g;
    vec3 ambient = adjustLightMap(lmcoord.rg) * albedo * material.g;
    vec3 color = ambient + Lo;

    // color = color / (color + vec3(1.0));
    color = pow(color, vec3(1.0/2.2)); 

    return color;
}

#if SSAO != 0
float calcSSAO(vec3 fragPos, vec3 normal, vec2 texcoord, sampler2D viewTex, sampler2D aoNoiseTex) {
    vec2 noiseCoord = vec2(mod(texcoord.x * viewWidth, 4.0) / 4.0, mod(texcoord.y * viewHeight, 4.0) / 4.0);
    vec3 rvec = vec3(texture2D(aoNoiseTex, noiseCoord).xy * 2.0 - 1.0, 0.0);
	// vec3 rvec = vec3(1.0);
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);

    float occlusion = 0.0;
	for (int i = 0; i < aoKernel.length(); ++i) {
		// get sample position:
		vec3 sample = tbn * aoKernel[i];
		sample = sample * SSAO_Radius + fragPos;
		
		// project sample position:
		vec4 offset = vec4(sample, 1.0);
		offset = gbufferProjection * offset;
		offset.xy /= offset.w;
		offset.xy = offset.xy * 0.5 + 0.5;
		
		// get sample depth:
		float sampleDepth = texture2D(viewTex, offset.xy).z;
		
		// range check & accumulate:
		float rangeCheck = smoothstep(0.0, 1.0, SSAO_Radius / abs(fragPos.z - sampleDepth));
        // float rangeCheck= abs(fragPos.z - sampleDepth) < SSAO_Radius ? 1.0 : 0.0;
		occlusion += (sampleDepth >= sample.z ? 1.0 : 0.0) * rangeCheck;
	}

	return 1.0 - (occlusion / aoKernel.length());
}
#endif

vec3 blendToFog(vec3 color, float depth) {
    if(isEyeInWater == 0)
        return mix(color, mix(vec3(.15), vec3(0.35), clamp(2.0 * (dayTimeFactor() + 0.4), 0.0, 1.0)), eyeBrightnessSmooth.g / 240.0 * clamp((linearDepth(depth) + mix(-0.1, 0.05, rainStrength)) * mix(0.8, 2.5, rainStrength), 0.0, 1.0));
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
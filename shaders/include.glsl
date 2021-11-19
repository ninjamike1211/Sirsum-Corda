#define PI 3.1415926538

#define MC_TEXTURE_FORMAT_LAB_PBR_1_3

#define Combine_Normal_Buffers

#define Shadow_Enable // Enable shadows (very large performance impact when enabled).
#define Shadow_Distort_Factor 0.10 //Distortion factor for the shadow map. [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1.00]
#define Shadow_Bias 0.005 //Increase this if you get shadow acne. Decrease this if you get peter panning. [0.000 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010 0.012 0.014 0.016 0.018 0.020 0.022 0.024 0.026 0.028 0.030 0.035 0.040 0.045 0.050]
#define Shadow_Blur_Amount 1.0 //Multiplier for the amount of blur at the edges of shadows. Lower values means less blur (harder edges). Higher values can help hide aliasing in shadows. [0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0]
#define Shadow_Darkness 0.8 //The darkness of shadows in the world. 1.0 means shadows are completely pitch black. 0.0 means shadows have no effect on brightness (invisible). [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.9 0.95 1.0]
#define Shadow_Filter 2 //Increases shadow sample count, improving quality at a slight performance cost. [0 1 2]
#define Shadow_Transparent 2 //Controls how semi-transparent objects cast shadows. off: transparent objects don't cast shadows. opaque: transparent objects cast solid shadows. colored: transparent objects cast colored shadows based on their color and opacity. [0 1 2]

#define leaves_wave //Causes leaves to russle and wave in the wind.
#define vine_wave //Causes vines to swing slightly in the wind.
#define grass_wave //Causes grass and some flowers to russle in the wind.

#define SSAO 2 // Provides better shadows in corners and small spaces at performance cost. Opaque: SSAO only on opaque objects. Everything_front: SSAO on every object, but not through transparent objects. Everything: Dual pass SSAO on both opaque and transparent object, even through each other. [0 1 2 3]
#define SSAO_Quality 1 // Quality of SSAO. Higher values increase quality at performance cost. [0 1 2 3]
#define SSAO_Radius 3.0 // Radius of SSAO. Higher values causes ao to be more spread out. Lower values will concentrate shadows more in corners. [0.5 0.75 1.0 1.25 1.5 1.75 2.0 3.0 4.0 5.0]
#define SSAO_Strength 0.6 // Strength of ambient shadows. 0 means no shadows. Higher numbers mean darker shadows. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

#define SSR // Screen space reflections on water, metal, and other shiny surfaces.
#define SSR_Top 0.8 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define SSR_Bottom 0.45 // [0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define SSR_Rough
#define SSR_Max_Roughness 0.7 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SSR_Multi

//#define bloom
#define Bloom_Threshold 1.0 //Threshold for bloom, lower values mean more bloom on darker objects. [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define Bloom_Spread 1.0 // [0.25 0.5 0.75 1.0 1.5 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0]

#define PBR_Lighting

// #define Old_Sky
// #define Old_Sun

// #define TAA
#define TAA_Jitter_Scale 1000.0

#define POM
#define POM_Depth 1.0 // Depth of POM in blocks. Lower values decreases effect. Appealing values may depend on resource pack [0.2 0.4 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.6 1.8 2.0 3.0 4.0]
#define POM_Layers 50 // Quality of POM. Higher values are better quality with more performance cost [5 10 20 30 40 50 75 100 200]
// #define POM_Interpolate
#define POM_PDO

#define Water_POM
#define Water_POM_Resolution 16.0 // Match this with the resolution of the water texture (16.0 for default texture). [8.0 16.0 32.0 64.0 128.0 256.0 512.0 1024.0 2048.0]
#define Water_POM_Layers 50 // Quality of POM. Higher values are better quality with more performance cost [5 10 20 30 40 50 75 100 200]

#define Water_Depth 0.25 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5]
#define Water_Direction 1 // Direction that water waves travel. [0 1 2 3 4]
// #define Water_Noise
#define Water_Color 0 // [0 1 2]

#define DOF_BlurCoC

#define Fog_Factor 1.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.5 3.0 3.5 4.0 4.5 5.0]

uniform sampler2D noisetex;
// uniform sampler2D colortex14;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 shadowLightPosition;
uniform vec3 waterColor;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform float wetness;
uniform int worldTime;
uniform int frameCounter;
uniform int isEyeInWater;
uniform float timeFactor;
uniform ivec2 atlasSize;
uniform bool inEnd;
// uniform int waterColorIndex;

const float sunPathRotation = -40; //Rotation of the path of the sun and moon in the sky. Helps reduce shadow acne at perpendicular angles. 0 means directly above the player. 90 means horizontal to the ground. Negative values are the opposite side of the vertical. [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90]
const float wetnessHalflife = 200.0;
const float drynessHalflife = 25.0;
const int noiseTextureResolution = 512;
const vec2 sunRotationData = vec2(cos(sunPathRotation * 0.01745329251994), -sin(sunPathRotation * 0.01745329251994)); //Used for manually calculating the sun's position, since the sunPosition uniform is inaccurate in the skybasic stage.
/*
const int colortex1Format = RGB16;
const int colortex8Format = RGB8;
const int colortex12Format = RGB8;
*/

const vec3 waterColors[] = vec3[] (
    vec3(0.05, 0.1, 0.25),
    vec3(0.24, 0.25, 0.12),
    vec3(0.015, 0.086, 0.2),
    vec3(0.015, 0.121, 0.2),
    vec3(0.05, 0.07, 0.25)
);

#ifdef Shadow_Enable
    uniform sampler2D shadowtex0;
    uniform sampler2D shadowtex1;
    uniform sampler2D shadowcolor0;
    const int shadowMapResolution = 2048; //The resolution of shadow map. Higher values leads to higher quality shaders. Lower values leads to better performance. [512 1024 2048 4096]
    const float shadowDistance = 120; //The distance over which shadows are rendered in blocks. Higher values will cause shadows to render farther in the distance but also decrease shadow quality. [80 120 160 200 240]
#endif

#ifdef bloom
// const float bloomWeight[] = float[] (0.227027, 0.1945946, 0.1216216, 0.054054, 0.016216);
// const float bloomWeight[] = float[] (0.111111, 0.111111, 0.111111, 0.111111, 0.111111);
// const float bloomWeight[] = float[] (0.190662, 0.180493, 0.152487, 0.113383, 0.072096, 0.037009, 0.013487, 0.0023815);
const float bloomWeight[] = float[] (0.09972, 0.09923, 0.097743, 0.09529, 0.09189, 0.087577, 0.08239, 0.07639, 0.06963, 0.062175, 0.054103, 0.04549, 0.036432, 0.027009, 0.017319, 0.0074708);
#endif

#if SSAO != 0
const vec3 aoKernel[] = vec3[](
    #if SSAO_Quality == 0
        vec3(-0.040092375, -0.085082404, 0.033964507),
        vec3(0.07686139, -0.005956394, 0.08406606),
        vec3(-0.032883804, -0.1414308, 0.057706576),
        vec3(-0.15006906, -0.14658183, 0.085578114),
        vec3(0.03055816, -0.30500218, 0.10800393),
        vec3(0.12736452, -0.12108572, 0.41596302),
        vec3(-0.23230846, -0.52947176, 0.18229501),
        vec3(0.31171134, 0.6173404, 0.3799296)
    #elif SSAO_Quality == 1
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
    #elif SSAO_Quality == 2
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
    #elif SSAO_Quality == 3
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

const vec2 reflectionKernel[] = vec2[](
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
);

const vec2 jitterSequence[] = vec2[](
    vec2(0.5,0.33333334),
    vec2(0.25,0.6666667),
    vec2(0.75,0.11111111),
    vec2(0.125,0.44444445),
    vec2(0.625,0.7777778),
    vec2(0.375,0.22222222),
    vec2(0.875,0.5555556),
    vec2(0.0625,0.8888889),
    vec2(0.5625,0.037037037),
    vec2(0.3125,0.3703704),
    vec2(0.8125,0.7037037),
    vec2(0.1875,0.14814815),
    vec2(0.6875,0.4814815),
    vec2(0.4375,0.8148148),
    vec2(0.9375,0.25925925),
    vec2(0.03125,0.5925926),
    vec2(0.53125,0.9259259),
    vec2(0.28125,0.074074075),
    vec2(0.78125,0.4074074),
    vec2(0.15625,0.7407408),
    vec2(0.65625,0.1851852),
    vec2(0.40625,0.5185185),
    vec2(0.90625,0.8518519),
    vec2(0.09375,0.2962963),
    vec2(0.59375,0.6296297),
    vec2(0.34375,0.962963),
    vec2(0.84375,0.012345679),
    vec2(0.21875,0.34567901),
    vec2(0.71875,0.67901236),
    vec2(0.46875,0.12345679),
    vec2(0.96875,0.45679012),
    vec2(0.015625,0.79012346),
    vec2(0.515625,0.23456791),
    vec2(0.265625,0.56790125),
    vec2(0.765625,0.90123457),
    vec2(0.140625,0.049382716),
    vec2(0.640625,0.38271606),
    vec2(0.390625,0.7160494),
    vec2(0.890625,0.16049382),
    vec2(0.078125,0.49382716),
    vec2(0.578125,0.8271605),
    vec2(0.328125,0.27160493),
    vec2(0.828125,0.60493827),
    vec2(0.203125,0.9382716),
    vec2(0.703125,0.086419754),
    vec2(0.453125,0.41975307),
    vec2(0.953125,0.75308645),
    vec2(0.046875,0.19753087),
    vec2(0.546875,0.5308642),
    vec2(0.296875,0.86419755),
    vec2(0.796875,0.30864197),
    vec2(0.171875,0.64197534),
    vec2(0.671875,0.97530866),
    vec2(0.421875,0.024691358),
    vec2(0.921875,0.35802472),
    vec2(0.109375,0.69135803),
    vec2(0.609375,0.13580248),
    vec2(0.359375,0.46913582),
    vec2(0.859375,0.80246913),
    vec2(0.234375,0.24691358),
    vec2(0.734375,0.5802469),
    vec2(0.484375,0.91358024),
    vec2(0.984375,0.061728396),
    vec2(0.0078125,0.39506173),
    vec2(0.5078125,0.72839504),
    vec2(0.2578125,0.17283951),
    vec2(0.7578125,0.50617284),
    vec2(0.1328125,0.83950615),
    vec2(0.6328125,0.28395063),
    vec2(0.3828125,0.61728394),
    vec2(0.8828125,0.95061725),
    vec2(0.0703125,0.09876543),
    vec2(0.5703125,0.43209875),
    vec2(0.3203125,0.7654321),
    vec2(0.8203125,0.20987655),
    vec2(0.1953125,0.54320985),
    vec2(0.6953125,0.8765432),
    vec2(0.4453125,0.32098764),
    vec2(0.9453125,0.654321),
    vec2(0.0390625,0.9876543),
    vec2(0.5390625,0.004115226),
    vec2(0.2890625,0.33744857),
    vec2(0.7890625,0.6707819),
    vec2(0.1640625,0.115226336),
    vec2(0.6640625,0.44855967),
    vec2(0.4140625,0.781893),
    vec2(0.9140625,0.22633745),
    vec2(0.1015625,0.5596708),
    vec2(0.6015625,0.8930041),
    vec2(0.3515625,0.041152265),
    vec2(0.8515625,0.3744856),
    vec2(0.2265625,0.7078189),
    vec2(0.7265625,0.15226337),
    vec2(0.4765625,0.48559672),
    vec2(0.9765625,0.81893003),
    vec2(0.0234375,0.26337448),
    vec2(0.5234375,0.5967078),
    vec2(0.2734375,0.93004113),
    vec2(0.7734375,0.0781893),
    vec2(0.1484375,0.41152263),
    vec2(0.6484375,0.744856),
    vec2(0.3984375,0.18930042),
    vec2(0.8984375,0.52263373),
    vec2(0.0859375,0.8559671),
    vec2(0.5859375,0.30041152),
    vec2(0.3359375,0.6337449),
    vec2(0.8359375,0.9670782),
    vec2(0.2109375,0.016460905),
    vec2(0.7109375,0.34979424),
    vec2(0.4609375,0.6831276),
    vec2(0.9609375,0.12757201),
    vec2(0.0546875,0.46090534),
    vec2(0.5546875,0.7942387),
    vec2(0.3046875,0.23868313),
    vec2(0.8046875,0.5720165),
    vec2(0.1796875,0.9053498),
    vec2(0.6796875,0.053497944),
    vec2(0.4296875,0.38683128),
    vec2(0.9296875,0.7201646),
    vec2(0.1171875,0.16460904),
    vec2(0.6171875,0.4979424),
    vec2(0.3671875,0.8312757),
    vec2(0.8671875,0.27572015),
    vec2(0.2421875,0.6090535),
    vec2(0.7421875,0.9423868),
    vec2(0.4921875,0.09053498),
    vec2(0.9921875,0.4238683),
    vec2(0.00390625,0.7572017)
);

const vec2 waveDirs[] = vec2[] (
#if Water_Direction == 0
    vec2(-0.65364, -0.75680),
    vec2(0.26749, 0.96355),
    vec2(-0.84810, -0.52983),
    vec2(0.90044, 0.43496),
    vec2(0.92747, -0.37387)
#elif Water_Direction == 1
    vec2(-0.65364, -0.75680),
    vec2(-0.26749, -0.96355),
    vec2(-0.84810, -0.52983),
    vec2(-0.90044, -0.43496),
    vec2(-0.92747, -0.37387)
#elif Water_Direction == 2
    vec2(-0.65364, 0.75680),
    vec2(-0.26749, 0.96355),
    vec2(-0.84810, 0.52983),
    vec2(-0.90044, 0.43496),
    vec2(-0.92747, 0.37387)
#elif Water_Direction == 3
    vec2(0.65364, -0.75680),
    vec2(0.26749, -0.96355),
    vec2(0.84810, -0.52983),
    vec2(0.90044, -0.43496),
    vec2(0.92747, -0.37387)
#elif Water_Direction == 4
    vec2(0.65364, 0.75680),
    vec2(0.26749, 0.96355),
    vec2(0.84810, 0.52983),
    vec2(0.90044, 0.43496),
    vec2(0.92747, 0.37387)
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

vec3 decodeNormal(vec2 normal) {
    return vec3(normal, sqrt(1.0 - dot(normal.xy, normal.xy)));
}

vec3 viewSpaceToScreenSpace(vec3 viewPos) {
    vec4 screenSpace = gbufferProjection * vec4(viewPos, 1.0);
    screenSpace.xyz /= screenSpace.w;
    screenSpace.xy = screenSpace.xy * 0.5 + 0.5;
    return screenSpace.xyz;
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
    vec3 color = mix(vec3(0.0, 0.01, 0.04), vec3(0.25, 0.4, 0.8), clamp(2.0 * (time + 0.4), 0.0, 1.0));
    return mix(color, mix(vec3(0.2), vec3(0.45), clamp(2.0 * (time + 0.4), 0.0, 1.0)), rainStrength);
}

vec3 getBottomSkyColor(float time) {
    vec3 color = mix(vec3(0.06, 0.07, 0.1), mix(vec3(0.75, 0.6, 0.5), vec3(0.53, 0.7, 1.0), clamp(5.0 * (time - 0.2), 0.0, 1.0)), clamp(2.0 * (time + 0.4), 0.0, 1.0));
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
    vec3 night = mix(0.3 * vec3(0.06, 0.06, 0.14), vec3(0.08), rainStrength);
    vec3 day = mix(mix(vec3(1.0, 0.6, 0.4), vec3(0.85, 0.8, 0.7), clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0)), vec3(0.3), rainStrength);
	return mix(night, day, clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
}

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 getSkyColor(vec3 dir, vec3 topskycolor, vec3 bottomskycolor, vec3 suncolor, vec3 sunblurcolor, vec3 sunPos, vec3 upPos, float time, bool showSun) {
    // #ifdef Old_Sky
    //     float upDot = dot(dir, upPos); //not much, what's up with you?
	//     return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
    // #else
        float upDot = dot(dir, upPos);
        vec3 color = mix(topskycolor, bottomskycolor, fogify(max(upDot, 0.0), 0.1));

        float sunDotV = max(dot(sunPos, dir), 0.0);
        float sunBlur = float(showSun) * smoothstep(0.996, 0.9975, sunDotV);
        #ifdef Old_Sun
            sunBlur = 0.0;
        #endif
        float sunAmount = pow(sunDotV, 2.0);
        sunAmount -= sunBlur;
        sunAmount *= smoothstep(-0.3, -.16, time);
        sunAmount *= 1.0 - clamp(5.0 * (time - 0.2), 0.0, 1.0);
        sunAmount *= min(pow(1.0 - dot(dir, upPos), 3.0), 1.0);

        return sunAmount * suncolor + sunBlur * sunblurcolor * 3.0 + max(1.0 - sunAmount - sunBlur, 0.0) * color;
    // #endif

    // float upDot = max(dot(dir, upPos), 0.0);
    // float lightDot = max(dot(dir, normalize(shadowLightPosition)), 0.0);
    // return texture2D(colortex14, vec2(upDot, lightDot)).rgb;
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

vec3 ambient() {
    return mix(vec3(0.2), vec3(0.5), timeFactor * 0.5 + 0.5);
}

vec3 calcViewPos(vec2 texcoord, float depth) {
    vec4 clipPos = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
	vec4 viewPos = gbufferProjectionInverse * clipPos;
	return viewPos.xyz / viewPos.w;
}

vec3 calcViewPos(vec3 viewVector, float depth) {
	float viewZ = -gbufferProjection[3][2] / ((depth * 2.0 - 1.0) + gbufferProjection[2][2]);
	return viewVector * viewZ;
}

vec2 getJitter() {
    #ifdef TAA
        int index = int(mod(float(frameCounter), jitterSequence.length()));
        return jitterSequence[index] / vec2(viewWidth, viewHeight) * TAA_Jitter_Scale;
    #else
        return vec2(0.0);
    #endif
}

float interpolateHeight(sampler2D normalTex, vec2 texcoord, vec4 texcoordRange) {
    vec2 singleTexSize = texcoordRange.zw-texcoordRange.xy;

    vec2 pixelCoord = texcoord * atlasSize;
    // float topLeft = texture2D(normalTex, mod(floor(pixelCoord) / atlasSize, singleTexSize) + texcoordRange.xy).a;
    // float topRight = texture2D(normalTex, mod(vec2(ceil(pixelCoord.x), floor(pixelCoord.y)) / atlasSize, singleTexSize) + texcoordRange.xy).a;
    // float bottomLeft = texture2D(normalTex, mod(vec2(floor(pixelCoord.x), ceil(pixelCoord.y)) / atlasSize, singleTexSize) + texcoordRange.xy).a;
    // float bottomRight = texture2D(normalTex, mod(ceil(pixelCoord) / atlasSize, singleTexSize) + texcoordRange.xy).a;
    float topLeft = texture2D(normalTex, fract((floor(pixelCoord) / atlasSize - texcoordRange.xy) / singleTexSize) * singleTexSize + texcoordRange.xy).a;
    float topRight = texture2D(normalTex, fract((vec2(ceil(pixelCoord.x), floor(pixelCoord.y)) / atlasSize - texcoordRange.xy) / singleTexSize) * singleTexSize + texcoordRange.xy).a;
    float bottomLeft = texture2D(normalTex, fract((vec2(floor(pixelCoord.x), ceil(pixelCoord.y)) / atlasSize - texcoordRange.xy) / singleTexSize) * singleTexSize + texcoordRange.xy).a;
    float bottomRight = texture2D(normalTex, fract((ceil(pixelCoord) / atlasSize - texcoordRange.xy) / singleTexSize) * singleTexSize + texcoordRange.xy).a;

    return mix(mix(topLeft, topRight, fract(pixelCoord.x)), mix(bottomLeft, bottomRight, fract(pixelCoord.x)), fract(pixelCoord.y));
}

vec3 ParallaxMapping(vec2 texcoord, vec3 viewDir, vec2 singleTexSize, sampler2D normalTex, vec4 texcoordRange) {
    // float layerCount = mix(256, 20, clamp(dot(normal, viewDir), 0.0, 1.0));
    // float layerCount = mix(256, 20, dot(viewDir, vec3(0.0, 0.0, -1.0)));
    float layerCount = POM_Layers;

	float layerDepth = 1.0 / layerCount;
	float currentLayerDepth = 0.0;
    vec2 p = (-viewDir.xy / viewDir.z) * 0.25 * POM_Depth * singleTexSize;
    vec2 deltaTexCoords = p / layerCount;

	vec2  currentTexcoord = texcoord;

    #ifdef POM_Interpolate
	    float currentDepthMapValue = 1.0 - interpolateHeight(normalTex, currentTexcoord, texcoordRange);
    #else
        float currentDepthMapValue = 1.0 - texture2D(normalTex, currentTexcoord).a;
    #endif
	
	while(currentLayerDepth < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		currentTexcoord += deltaTexCoords;

        // wrap texture coordinates if they extend out of range
        currentTexcoord.x -= floor((currentTexcoord.x - texcoordRange.x) / singleTexSize.x) * singleTexSize.x;
        currentTexcoord.y -= floor((currentTexcoord.y - texcoordRange.y) / singleTexSize.y) * singleTexSize.y;

		// get depthmap value at current texture coordinates
		// currentDepthMapValue = 1.0 - texture2D(normalTex, currentTexcoord).a;
        #ifdef POM_Interpolate
            currentDepthMapValue = 1.0 - interpolateHeight(normalTex, currentTexcoord, texcoordRange);
        #else
            currentDepthMapValue = 1.0 - texture2D(normalTex, currentTexcoord).a;
        #endif
		// get depth of next layer
		currentLayerDepth += layerDepth;
	}

    // #ifdef shadowFSH
    //     return vec3(currentTexcoord, -(currentLayerDepth) * 0.25 * POM_Depth);
    // #else
	    return vec3(currentTexcoord, -(currentLayerDepth - layerDepth) * 0.25 * POM_Depth);
    // #endif
}

#ifdef Shadow_Enable
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
#endif

vec3 calculateShadow(vec3 shadowPos, vec2 texcoord) {
    #ifdef Shadow_Enable
        #if Shadow_Filter > 0
            vec3 shadowVal = vec3(0.0);
            float randomAngle = texture2D(noisetex, texcoord * 20.0f).a * 100.0f;
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

            return shadowVal;
        #else
            return shadowVisibility(shadowPos);
        #endif
    #else
        return vec3(1.0);
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

vec3 adjustLightMapWater(vec2 lmcoord) {
    // vec3 skyLight = lightmapSky(lmcoord.g) * (shadowVal * Shadow_Darkness + (1.0 - Shadow_Darkness));
	// vec3 torchLight = lightmapTorch(lmcoord.r) * (1.1 - skyLight);

	// return skyLight + torchLight;

    vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.75 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= (1.0 - Shadow_Darkness);

    return torchAmbient;
}

vec3 adjustLightMapShadow(vec3 shadow, vec2 lmcoord) {
    vec3 skyAmbient = lightmapSky(lmcoord.g);
    vec3 torchAmbient = lightmapTorch(lmcoord.r) * clamp(1.9 - skyAmbient.r, 0.0, 1.0);
    skyAmbient *= shadow * Shadow_Darkness + (1.0 - Shadow_Darkness);

    return skyAmbient + torchAmbient;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0) {
    return F0 + (1.0 - F0) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

float fresnel(float cosTheta) {
    return 0.04 + (1.0 - 0.04) * pow(max(1.0 - cosTheta, 0.0), 5.0);
}

float DistributionGGX(vec3 normal, vec3 halfwayDir, float roughness) {
    float a = roughness;
    float a2 = a*a;
    float NdotH = clamp(dot(normal, halfwayDir) + 0.0, 0.0, 1.0);
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
        metalness = 1.0;
    }

    return vec4(F0, metalness);
}

vec3 PBRLighting(vec3 viewDir, vec3 albedo, vec3 normal, vec3 lightDir, vec3 specMap, vec3 material, vec3 light, vec2 lmcoord) {
    light *= mix(3.5, 1.0, rainStrength);
    
    // vec3 viewDir = getCameraVector(linearDepth, texcoord);
    vec3 halfwayDir = normalize(viewDir + lightDir);

    albedo = pow(albedo, vec3(2.2));

    // light = pow(light, vec3(2.2));

    vec4 F0Results = calcF0(specMap, albedo);
    vec3 F0 = F0Results.rgb;
    float metalness = F0Results.w;

    float porosity = (specMap.b < 64.9 / 255.0) ? specMap.b * 2.0 : 0.0;

    float roughness = max(pow(1.0 - specMap.r, 2.0), 0.02);
    roughness = mix(roughness, min(roughness, 0.03), wetness);

    albedo = mix(albedo, (1.0 - porosity) * albedo, wetness);
    albedo = pow(albedo, mix(vec3(1.0), vec3(1.0 + 10.0 * porosity), wetness));

    vec3 F = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), F0);
    float NDF = DistributionGGX(normal, halfwayDir, roughness);
    float G = GeometrySmith(normal, viewDir, lightDir, roughness);

    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(normal, viewDir), 0.0) * max(dot(normal, lightDir), 0.0);
    vec3 specular = numerator / max(denominator, 0.001);

    vec3 kS = F;
    vec3 kD = clamp(vec3(1.0) - kS, 0.0, 1.0);
    // kD = vec3(1.0);
    kD *= 1.0 - metalness;
        
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

vec3 pbrDiffuse(vec3 viewDir, vec3 albedo, vec3 normal, vec3 lightDir, vec3 specMap, vec3 material, vec3 light, vec2 lmcoord) {
    light *= mix(3.5, 1.0, rainStrength);
    albedo = pow(albedo, vec3(2.2));

    vec4 F0Results = calcF0(specMap, albedo);
    vec3 F0 = F0Results.rgb;
    float metalness = F0Results.w;

    vec3 halfwayDir = normalize(viewDir + lightDir);
    vec3 F = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), F0);

    vec3 kS = F;
    vec3 kD = clamp(vec3(1.0) - kS, 0.0, 1.0);
    kD *= 1.0 - metalness;

    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 Lo = (kD * albedo / PI) * NdotL * light;

    vec3 ambient = adjustLightMap(lmcoord.rg) * albedo * material.g;
    vec3 color = ambient + Lo;

    color = pow(color, vec3(1.0/2.2)); 
    return color;
}

vec3 pbrSpecular(vec3 viewDir, vec3 albedo, vec3 normal, vec3 lightDir, vec3 specMap, vec3 light) {
    light *= mix(3.5, 1.0, rainStrength);
    albedo = pow(albedo, vec3(2.2));

    vec3 F0 = calcF0(specMap, albedo).rgb;

    float roughness = max(pow(1.0 - specMap.r, 2.0), 0.02);
    roughness = mix(roughness, min(roughness, 0.03), wetness);

    vec3 halfwayDir = normalize(viewDir + lightDir);

    vec3 F = fresnelSchlick(max(dot(halfwayDir, viewDir), 0.0), F0);
    float NDF = DistributionGGX(normal, halfwayDir, roughness);
    float G = GeometrySmith(normal, viewDir, lightDir, roughness);

    vec3 numerator = NDF * G * F;
    float denominator = 4.0 * max(dot(normal, viewDir), 0.0) * max(dot(normal, lightDir), 0.0);
    vec3 specular = numerator / max(denominator, 0.001);

    float NdotL = max(dot(normal, lightDir), 0.0);
    vec3 Lo = specular * NdotL * light;

    vec3 color = pow(Lo, vec3(1.0/2.2)); 
    return color;
}

float D_GGX(float NoH, float a) {
    float a2 = a * a;
    float f = (NoH * a2 - NoH) * NoH + 1.0;
    return a2 / (PI * f * f);
}

vec3 F_Schlick(float u, vec3 f0) {
    return f0 + (vec3(1.0) - f0) * pow(1.0 - u, 5.0);
}

float V_SmithGGXCorrelated(float NoV, float NoL, float a) {
    float a2 = a * a;
    float GGXL = NoV * sqrt((-NoL * a2 + NoL) * NoL + a2);
    float GGXV = NoL * sqrt((-NoV * a2 + NoV) * NoV + a2);
    return 0.5 / (GGXV + GGXL);
}

float Fd_Lambert() {
    return 1.0 / PI;
}

vec3 BRDF(vec3 albedo, vec3 viewDir, vec3 normal, vec3 specMap, vec3 lightDir, vec3 lightAmount) {
    vec3 halfwayDir = normalize(viewDir + lightDir);

    float NoV = abs(dot(normal, viewDir)) + 1e-5;
    float NoL = clamp(dot(normal, lightDir), 0.0, 1.0);
    float NoH = clamp(dot(normal, halfwayDir), 0.0, 1.0);
    float LoH = clamp(dot(lightDir, halfwayDir), 0.0, 1.0);

    // perceptually linear roughness to roughness (see parameterization)
    float roughness = pow(1.0 - specMap.r, 2.0);

    vec4 f0 = calcF0(specMap, albedo);

    float D = D_GGX(NoH, roughness);
    vec3  F = F_Schlick(LoH, f0.rgb);
    float V = V_SmithGGXCorrelated(NoV, NoL, roughness);

    // specular BRDF
    vec3 Fr = (D * V) * F;

    // diffuse BRDF
    vec3 Fd = albedo * Fd_Lambert();

    // apply lighting...
    return (Fr + Fd) * lightAmount;
}

// vec3 pbrDiffuse(vec3 viewDir, vec3 albedo, vec3 normal, vec3 lightDir, vec3 specMap, vec3 material, vec3 light, vec2 lmcoord) {
//     return (light + adjustLightMap(lmcoord.rg) + ambient()) * albedo * Fd_Lambert();
// }

// vec3 pbrSpecular(vec3 viewDir, vec3 albedo, vec3 normal, vec3 lightDir, vec3 specMap, vec3 light) {
//     vec3 halfwayDir = normalize(viewDir + lightDir);

//     float NoV = abs(dot(normal, viewDir)) + 1e-5;
//     float NoL = clamp(dot(normal, lightDir), 0.0, 1.0);
//     float NoH = clamp(dot(normal, halfwayDir), 0.0, 1.0);
//     float LoH = clamp(dot(lightDir, halfwayDir), 0.0, 1.0);

//     // perceptually linear roughness to roughness (see parameterization)
//     float roughness = pow(1.0 - specMap.r, 2.0);

//     vec4 f0 = calcF0(specMap, albedo);

//     float D = D_GGX(NoH, roughness);
//     vec3  F = F_Schlick(LoH, f0.rgb);
//     float V = V_SmithGGXCorrelated(NoV, NoL, roughness);

//     // specular BRDF
//     return (D * V) * F * light;
// }

#if SSAO != 0
float calcSSAO(vec3 normal, vec3 viewVector, vec2 texcoord, sampler2D depthTex, sampler2D aoNoiseTex) {
    vec2 noiseCoord = vec2(mod(texcoord.x * viewWidth, 4.0) / 4.0, mod(texcoord.y * viewHeight, 4.0) / 4.0);
    vec3 rvec = vec3(texture2D(aoNoiseTex, noiseCoord).xy * 2.0 - 1.0, 0.0);
	// vec3 rvec = vec3(1.0);
	vec3 tangent = normalize(rvec - normal * dot(rvec, normal));
	vec3 bitangent = cross(normal, tangent);
	mat3 tbn = mat3(tangent, bitangent, normal);

    vec3 fragPos = calcViewPos(viewVector, texture2D(depthTex, texcoord).r);

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
		float sampleDepth = calcViewPos(offset.xy, texture2D(depthTex, offset.xy).r).z; // texture2D(viewTex, offset.xy).z;
		
		// range check & accumulate:
		float rangeCheck = smoothstep(0.0, 1.0, SSAO_Radius / abs(fragPos.z - sampleDepth));
        // float rangeCheck= abs(fragPos.z - sampleDepth) < SSAO_Radius ? 1.0 : 0.0;
		occlusion += (sampleDepth >= sample.z ? 1.0 : 0.0) * rangeCheck;
	}

	return clamp(1.0 - (SSAO_Strength * occlusion / aoKernel.length()), 0.0, 1.0);
}
#endif

// vec3 calcReflection(vec3 startPos, vec3 normal, sampler2D depthTex) {
//     float maxDistance = 15.0;
//     float resolution = 0.5;
//     int steps = 10;
//     float thickness = 0.05;

//     vec2 texSize = vec2(viewWidth, viewHeight);

//     vec3 pivot = normalize(reflect(normalize(startPos), normal));

//     vec3 viewPos = startPos;
//     vec4 endPos = vec4(startPos + (pivot * maxDistance), 1.0);

//     vec4 startFrag = gbufferProjection * vec4(startPos, 1.0);
//     startFrag.xyz /= startFrag.w;
//     startFrag.xy = startFrag.xy * 0.5 + 0.5;
//     startFrag.xy *= texSize;

//     vec4 endFrag = gbufferProjection * endPos;
//     endFrag.xyz /= endFrag.w;
//     endFrag.xy = endFrag.xy * 0.5 + 0.5;
//     endFrag.xy *= texSize;

//     vec2 frag = startFrag.xy;
//     vec2 uv = frag / texSize;

//     float deltaX = endFrag.x - startFrag.x;
//     float deltaY = endFrag.y - startFrag.y;
//     float useX = abs(deltaX) >= abs(deltaY) ? 1.0 : 0.0;
//     float delta = mix(abs(deltaY), abs(deltaX), useX) * clamp(resolution, 0.0, 1.0);
//     vec2 increment = vec2(deltaX, deltaY) / max(delta, 0.001);

//     float search0 = 0.0;
//     float search1 = 0.0;

//     float hit0 = 0.0;
//     float hit1 = 0.0;

//     float viewDistance = startPos.z;
//     float depth = thickness;


//     for(int i = 10; i < 100; ++i) {
//         frag += increment;
//         uv = frag / texSize;
//         viewPos = calcViewPos(uv, texture2D(depthTex, uv).r);

//         search1 = mix((frag.y - startFrag.y) / deltaY, (frag.x - startFrag.x) / deltaX, useX);

//         viewDistance = (startPos.z * endPos.z) / mix(endPos.z, startPos.z, search1);
//         depth = viewDistance - viewPos.z;

//         if(depth > 0 && depth < thickness) {
//             hit0 = 1;
//             break;
//         }
//         else {
//             search0 = search1;
//         }
//     }

//     search1 = search0 + ((search1 - search0) / 2.0);
//     steps = int(steps * hit0);

//     for(int i = 0; i < steps; ++i) {
//         frag = mix(startFrag.xy, endFrag.xy, search1);
//         uv = frag / texSize;
//         viewPos = calcViewPos(uv, texture2D(depthTex, uv).r);

//         viewDistance = (startPos.z * endPos.z) / mix(endPos.z, startPos.z, search1);
//         depth = viewDistance - viewPos.z;

//         if(depth > 0 && depth < thickness) {
//             hit1 = 1;
//             search1 = search0 + ((search1 - search0) / 2);
//         }
//         else {
//             float temp = search1;
//             search1 += ((search1 - search0) / 2);
//             search0 = temp;
//         }
//     }

//     float visibility = hit1;
//                     // * (1.0 - max(dot(-normalize(startPos), pivot), 0.0))
//                     // * (1.0 - clamp(depth / thickness, 0.0, 1.0))
//                     // * (1.0 - clamp(length(endPos.xyz - startPos) / maxDistance, 0.0, 1.0))
//                     // * (uv.x < 0 || uv.x > 1 ? 0 : 1)
//                     // * (uv.y < 0 || uv.y > 1 ? 0 : 1);
//     visibility = clamp(visibility, 0.0, 1.0);

//     return vec3(uv, visibility);

//     // return vec3(1.0, 0.0, 0.0);
// }

float reflectionFactor(vec3 specMap) {
    return max(max(smoothstep(SSR_Bottom, SSR_Top, specMap.r), wetness), isEyeInWater*0.8);
}

vec3 calcSSR(vec3 viewSpacePos, vec3 reflectDir, sampler2D depthTex, sampler2D waterTex, bool isNotWater) {
    // #ifdef SSR_Rough
    //     normal = normalize(normal * (texture2D(noisetex, texcoord).rgb * 0.002 - 0.001));
    // #endif

    // vec3 reflectDir = reflect(normalize(viewSpacePos), normal);
    
    // vec2 screenSpacePos = texcoord;
    // vec3 viewSpaceDir = normalize(viewSpacePos);

    // vec3 reflectDir = normalize(reflect(viewSpaceDir, normal));
    vec3 viewSpaceVector = .999 * reflectDir;
    vec3 viewSpaceVectorFar = far * reflectDir;
    vec3 viewSpaceVectorPos = viewSpacePos + viewSpaceVector;
    vec3 currentPosition = viewSpaceToScreenSpace(viewSpaceVectorPos);

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
        float sampleDepth = calcViewPos(samplePos, texture2D(depthTex, samplePos).r).z;


        float currentDepth = viewSpaceVectorPos.z;
        float diff = sampleDepth - currentDepth;
        float error = length(viewSpaceVector / pow(2.0, numRefinements));

        if((isNotWater || texture2D(waterTex, samplePos).r != 1.0) && diff >= 0 && diff <= error * 2.0 && numRefinements <= maxRefinements) {
            viewSpaceVectorPos -= viewSpaceVector / pow(2.0, numRefinements);
            numRefinements++;
        }
        else if((isNotWater || texture2D(waterTex, samplePos).r != 1.0) && diff >= 0 && diff <= error * 4.0 && numRefinements > maxRefinements) {
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

        currentPosition = viewSpaceToScreenSpace(viewSpaceVectorPos);

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
	}

    // return color;
    return finalSamplePos;
}

vec3 calcReflection(vec2 texcoord, vec3 viewSpacePos, vec3 normal, vec3 specMap, sampler2D depthTex, sampler2D waterTex, bool isNotWater) {
    #ifdef SSR_Rough
        float factor = mix(SSR_Max_Roughness, 0.0, smoothstep(SSR_Bottom, SSR_Top, specMap.r));
        vec3 reflectDir = reflect(normalize(viewSpacePos), normalize(normal + vec3(texture2D(noisetex, 10.0 * texcoord).rg * factor - 0.5 * factor, 0.0)));
    #else
        vec3 reflectDir = reflect(normalize(viewSpacePos), normal);
    #endif

    return calcSSR(viewSpacePos, reflectDir, depthTex, waterTex, isNotWater);
}

vec3 calcRefraction(vec3 viewSpacePos, vec3 normal, vec3 geometryNorm, float refractionIndex, sampler2D depthTex, sampler2D waterTex) {
    vec3 refractDir = normalize(refract(normalize(viewSpacePos), geometryNorm - normal, refractionIndex));

    return calcSSR(viewSpacePos, refractDir, depthTex, waterTex, true);
}

vec3 waterRefraction(vec2 texcoord, vec3 viewPosWater, vec3 viewPosOpaque, vec3 normal) {
    vec3 refractDir = normalize(refract(normalize(viewPosWater), /*viewSpaceToScreenSpace(*/normal/*)*/, 1.5));
    float diff = length(viewPosWater - viewPosOpaque);

    vec3 finalScreenPos = vec3(viewSpaceToScreenSpace(viewPosWater + refractDir));
    // vec3 finalScreenPos = vec3(viewSpaceToScreenSpace(viewPosWater + 0.1 * diff * vec3(normal.xy, 0.0)));
    // finalScreenPos.z = float(finalScreenPos.x >= 0.0 && finalScreenPos.x <= 1.0 && finalScreenPos.y >= 0.0 && finalScreenPos.y <= 1.0);

    // finalScreenPos.xy = texcoord + 0.1 * normal.xy;

    return vec3(finalScreenPos);
}

vec3 refractFixed(vec3 viewDir, vec3 normal, float rior) {
    // float NdotI = dot(normal, viewDir);
    // return (rior*NdotI - sqrt(1.0 - rior*rior * (1.0 - NdotI*NdotI))) * normal - rior * viewDir;

    float k = 1.0 - rior * rior * (1.0 - dot(normal, viewDir) * dot(normal, viewDir));
    if (k < 0.0)
        return vec3(0.0);       // or genDType(0.0)
    else
        return rior * viewDir - (rior * dot(normal, viewDir) + sqrt(k)) * normal;
}

vec3 calcSSRRefraction(vec2 texcoord, vec3 viewSpacePos, vec3 normal, sampler2D depthTex) {
    vec2 screenSpacePos = texcoord;
    vec3 viewSpaceDir = normalize(viewSpacePos);
    // vec3 viewSpaceDir = vec3(0.0, 0.0, 1.0);

    vec3 reflectDir = normalize(refract(viewSpaceDir, normal, 1.2));
    // vec3 reflectDir = normalize(viewSpaceDir + normal);
    vec3 viewSpaceVector = .999 * reflectDir;
    vec3 viewSpaceVectorFar = far * reflectDir;
    vec3 viewSpaceVectorPos = viewSpacePos + viewSpaceVector;
    vec3 currentPosition = viewSpaceToScreenSpace(viewSpaceVectorPos);

    const int maxRefinements = 5;
	int numRefinements = 0;
    int count = 0;
	vec3 finalSamplePos = vec3(0.0);

	int numSteps = 0;

	float finalSampleDepth = 0.0;


    for(int i = 0; i < 40; i++) {

        if(
           -viewSpaceVectorPos.z > far * 1.4f ||
           -viewSpaceVectorPos.z < 0.0f)
        {
		   break;
		}

        vec2 samplePos = currentPosition.xy;
        float sampleDepth = calcViewPos(samplePos, texture2D(depthTex, samplePos).r).z;

        float currentDepth = viewSpaceVectorPos.z;
        float diff = sampleDepth - currentDepth;
        float error = length(viewSpaceVector / pow(2.0, numRefinements));

        if(diff >= 0 && diff <= error * 2.0 && numRefinements <= maxRefinements) {
            viewSpaceVectorPos -= viewSpaceVector / pow(2.0, numRefinements);
            numRefinements++;
        }
        else if(diff >= 0 && diff <= error * 4.0 && numRefinements > maxRefinements) {
            finalSamplePos = vec3(samplePos, 1.0);
            finalSampleDepth = sampleDepth;
            break;
        }

        viewSpaceVectorPos += viewSpaceVector / pow(2.0f, numRefinements);

        if(numSteps > 1)
            viewSpaceVector *= 1.375;

        currentPosition = viewSpaceToScreenSpace(viewSpaceVectorPos);

        if (currentPosition.x < 0 || currentPosition.x > 1 ||
            currentPosition.y < 0 || currentPosition.y > 1 ||
            currentPosition.z < 0 || currentPosition.z > 1)
        {
            break;
        }
        // currentPosition = clamp(currentPosition, vec3(0.001), vec3(0.999));

        count++;
        numSteps++;
    }

    // vec4 color = vec4(1.0);
    // color.rgb = texture2D(colorTex, finalSamplePos).rgb;

    if (finalSamplePos.x == 0.0 || finalSamplePos.y == 0.0) {
		finalSamplePos.z = 0.0;
	}

    // return color;
    return finalSamplePos;
}

vec3 waterFogColor() {
    // return vec3(0.0, 0.1, 0.25);
    // return fogColor;
    // return waterColor;
    // return waterColors[waterColorIndex];

    #if Water_Color == 0
        return vec3(0.0, 0.1, 0.25);
    #elif Water_Color == 1
        return vec3(0.0, 0.1, 0.25);
    #else
        return vec3(0.07, 0.13, 0.3) / 0.7;
    #endif
}

vec3 underWaterFogColor() {
    #if Water_Color == 2
        return vec3(0.07, 0.13, 0.3);
    #else
        return waterColor;
    #endif
}

float blendTo(vec3 viewPos, int eyeInWater) {
    // float distance = (length(viewPos) - near) / (far - near);
    float distance = clamp(length(viewPos), near, far);
    if(eyeInWater == 0) {
        // return eyeBrightnessSmooth.g / 240.0 * clamp((distance / far + mix(-0.1, 0.05, rainStrength)) * mix(0.8, 2.5, rainStrength), 0.0, 1.0);
        float fogExponent = mix(1.0 / (far * Fog_Factor), 0.025, rainStrength);
        return clamp(1.0 - exp(-pow(distance * fogExponent, 2.0)), 0.0, 1.0);
        // return distance;
    }
    else if(eyeInWater == 1)
        // return clamp(0.4 + 0.02 * distance, 0.0, 1.0);
        return clamp(1.0 - exp(-0.08 * distance), 0.0, 1.0);
        // return mix(color, lightmapSky(eyeBrightnessSmooth.y / 240.0 * 0.4 + 0.6) * vec3(0.0, 0.1, 0.25), clamp(0.4 + 0.02 * distance, 0.0, 1.0));
    else
        return clamp(0.5 + 0.08 * distance, 0.0, 1.0);
}

vec3 blendToFog(vec3 color, vec3 viewPos, int eyeInWater, vec3 skyFogColor, vec2 lmcoord) {
    float fogAmount = blendTo(viewPos, eyeInWater);
    if(eyeInWater == 0)
        return mix(color, skyFogColor, fogAmount);
        // return mix(color, skyFogColor, eyeBrightnessSmooth.g / 240.0 * clamp(distance, 0.0, 1.0));
    else if(eyeInWater == 1)
        return mix(color, underWaterFogColor() * lightmapSky(eyeBrightnessSmooth.y / 240.0 * 0.4 + 0.6) /* (eyeBrightness.y / 240.0 * 0.6 + 0.8) */, fogAmount);
        // return mix(color, lightmapSky(eyeBrightnessSmooth.y / 240.0 * 0.4 + 0.6) * vec3(0.0, 0.1, 0.25), clamp(0.4 + 0.02 * distance, 0.0, 1.0));
    else
        return mix(color, vec3(0.85, 0.2, 0.0), fogAmount);
}

vec3 advancedFog(vec3 fragColor, vec3 viewPos, int eyeInWater) {
    float distance = clamp(length(viewPos), near, far);
    // float distance = 1.0 - ((length(viewPos) - near) / (far - near));

    vec3 be;
    vec3 bi;

    if(eyeInWater == 0) {
        be = vec3(0.005);
        bi = vec3(0.005);
    }
    else if(eyeInWater == 1) {
        be = vec3(0.1, 0.2, 0.5);
        bi = vec3(0.1, 0.2, 0.5);
    }
    else {
        be = vec3(1.0, 0.5, 0.0);
        bi = vec3(1.0, 0.5, 0.0);
    }

    vec3 extColor = vec3( exp(-distance*be.x), exp(-distance*be.y), exp(-distance*be.z) );
    vec3 insColor = vec3( exp(-distance*bi.x), exp(-distance*bi.y), exp(-distance*bi.z) );

    vec3 sunDir = normalize(shadowLightPosition);
    float sunAmount = max( dot( normalize(viewPos), sunDir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,0.7), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,8.0) );

    return fragColor*(extColor) + fogColor*(1.0-insColor);
}

vec3 waterFog(vec3 color, float lightMapSky, vec3 viewPos, vec3 waterViewPos, float upDot) {
    float distance = length(viewPos - waterViewPos);
    // float fogAmount = clamp(0.4 + 0.02 * distance, 0.0, 1.0);
    float fogAmount = clamp(1.0 - exp(-0.08 * distance), 0.0, 1.0);
    return mix(color, lightmapSky(lightMapSky) * waterFogColor(), fogAmount);
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

float waveFunction(vec2 pos, float time, float amplitude, float frequency, float speed, vec2 direction) {
    // return amplitude * pow((sin(dot(pos, direction) * frequency + time * speed) + 1.0) / 2.0, k);
    return amplitude * (sin(dot(pos, direction) * frequency + time * speed) + 1.0) / 2.0;
}

vec2 waveFunctionDeriv(vec2 pos, float time, float amplitude, float frequency, float speed, vec2 direction) {
    // float partialX = k * direction.x * frequency * amplitude * pow((sin(dot(pos, direction) * frequency + time * speed) + 1.0) / 2.0, k-1) * cos(dot(pos, direction) * frequency + time * speed);
    // float partialZ = k * direction.y * frequency * amplitude * pow((sin(dot(pos, direction) * frequency + time * speed) + 1.0) / 2.0, k-1) * cos(dot(pos, direction) * frequency + time * speed);
    
    float partialX = direction.x * frequency * amplitude * cos(dot(pos, direction) * frequency + time * speed);
    float partialZ = direction.y * frequency * amplitude * cos(dot(pos, direction) * frequency + time * speed);

    return 0.5 * Water_Depth * vec2(partialX, partialZ);
}

vec3 waveOffset(float blockType, vec3 vertex, vec2 texcoord, vec2 mc_midTexCoord, vec3 normal) {

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

float vineWaveHeight(float verticalPos) {
    return 0.5 * mix(sin(verticalPos + frameTimeCounter * PI * 0.5), sin(verticalPos + frameTimeCounter * PI * 2.0), rainStrength) + 0.5;
}

float waterWaveOffset(vec2 horizontalPos) {
    // float offset = 0.6 * cos(.25 * PI * horizontalPos.x + .125 * PI * horizontalPos.y + 2.0 * frameTimeCounter)
    //                     + 0.35 * sin(.75 * PI * horizontalPos.x + .25 * PI * horizontalPos.y + 3.0 * frameTimeCounter)
    //                     + 0.05 * cos(1.5 * PI * horizontalPos.x + PI * horizontalPos.y + 4.0 * frameTimeCounter);

    // float offset =        0.5*abs(cos(.25*PI*horizontalPos.x + .125*PI*horizontalPos.y + 2.0*frameTimeCounter))
    //                     + 0.3*abs(sin(.75*PI*horizontalPos.x + .25*PI*horizontalPos.y + 3.0*frameTimeCounter))
    //                     + 0.2*abs(cos(1.5*PI*horizontalPos.x + PI*horizontalPos.y + 4.0*frameTimeCounter));

    // float offset =    waveFunction(horizontalPos, frameTimeCounter, 0.4, 1, PI / 2.0, vec2(0.26749, 0.96355), Water_K)
    //                 + waveFunction(horizontalPos, frameTimeCounter, 0.3, 2, PI / 2.0, vec2(-0.84810, -0.52983), Water_K)
    //                 + waveFunction(horizontalPos, frameTimeCounter, 0.2, 4, PI, vec2(0.90044, 0.43496), Water_K)
    //                 + waveFunction(horizontalPos, frameTimeCounter, 0.1, 6, PI, vec2(0.92747, -0.37387), Water_K);

    float offset =  + waveFunction(horizontalPos, frameTimeCounter, 0.6, 1, PI / 3.0, waveDirs[0])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 1, PI / 1.25, waveDirs[1])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 2, PI, waveDirs[2])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 4, PI / 0.75, waveDirs[3])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 6, PI / 0.5, waveDirs[4]);

    // float offset =  waveFunction(horizontalPos, frameTimeCounter, 1.0, 1.0, PI / 4.0, vec2(-0.65364, -0.75680), 1.0);

    // float offset = abs(sin(horizontalPos.x + horizontalPos.y + frameTimeCounter));
        
    // float offsetRain = 0.6 * cos(.25 * PI * horizontalPos.x + .125 * PI * horizontalPos.y + 6.0 * frameTimeCounter)
    //                 + 0.35 * sin(.75 * PI * horizontalPos.x + .25 * PI * horizontalPos.y + 9.0 * frameTimeCounter)
    //                 + 0.05 * cos(1.5 * PI * horizontalPos.x + PI * horizontalPos.y + 12.0 * frameTimeCounter);
    
    #ifdef Water_Noise
        return mix(offset, 0.5, texture2D(noisetex, 0.05 * horizontalPos + vec2(0.01 * frameTimeCounter)).a * 0.2);
    #else
        return offset;
    #endif
    // return 1.0 - texture2D(noisetex, 0.02 * horizontalPos + vec2(0.01 * frameTimeCounter)).a;
}

vec3 waterNormal(vec2 horizontalPos) {
    // vec2 partials = waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.4, 1, PI / 2.0, vec2(0.26749, 0.96355), Water_K);
    // partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.3, 2, PI / 2.0, vec2(-0.84810, -0.52983), Water_K);
    // partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.2, 4, PI, vec2(0.90044, 0.43496), Water_K);
    // partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 6, PI, vec2(0.92747, -0.37387), Water_K);

    vec2 partials = waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.6, 1, PI / 3.0, waveDirs[0]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 1, PI / 1.25, waveDirs[1]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 2, PI, waveDirs[2]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 4, PI / 0.75, waveDirs[3]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 6, PI / 0.5, waveDirs[4]);

    // vec2 partials = waveFunctionDeriv(horizontalPos, frameTimeCounter, 1.0, 1.0, PI / 4.0, vec2(-0.65364, -0.75680), 1.0);
    
    #ifdef Water_Noise
        vec4 noiseVal = texture2D(noisetex, 0.05 * horizontalPos + vec2(0.01 * frameTimeCounter));
        return normalize(mix(vec3(0.2 * partials, 1.0), vec3(-Water_Depth, -Water_Depth, 1.0) * (noiseVal.rgb * 2.0 - 1.0), noiseVal.a * 0.2));
    #else
        return vec3(Water_Depth * partials, 1.0);
    #endif
    
    // return normalize(vec3(0.5*Water_Depth, 0.5*Water_Depth, 1.0) * (texture2D(noisetex, 0.02 * horizontalPos + vec2(0.01 * frameTimeCounter)).rgb * 2.0 - 1.0));
}

vec3 getNormal(in vec2 position, in float blockType/*, in vec2 mc_midTexCoord*/) {

    //return vec3(mod(frameTimeCounter, 1.0));

    if(blockType < 0.0)
        return vec3(0.0, 0.0, 1.0);

    //return vec3(int(blockType+0.1) == 2);

    // Water and lillypad wave
    //#ifdef water_wave
    if(blockType < 1.0) {
        /*float offset = 0.04 * ((sin((position.x + frameTimeCounter) * PI * 0.375) + cos((position.y + frameTimeCounter) * PI * 0.25))
                    * cos((position.x + frameTimeCounter) * PI * 0.5) + sin((position.y + frameTimeCounter) * PI * -0.375)) - (mc_Entity.x == 111.0f ? 0.08 : 0.0);

        float offsetRain = 0.04 * ((sin((position.x + frameTimeCounter) * PI * 0.75) + cos((position.y + frameTimeCounter) * PI * 0.5))
                    * cos((position.x + frameTimeCounter) * PI * 1.0) + sin((position.y + frameTimeCounter) * PI * -0.75)) - (mc_Entity.x == 111.0f ? 0.08 : 0.0);*/
        
        /*float partialX = 0.04 * (0.375 * PI * cos((position.x + frameTimeCounter) * 0.375 * PI) * cos((position.x + frameTimeCounter) * 0.5 * PI)
                            + (sin((position.x + frameTimeCounter) * 0.375 * PI) + cos((position.y + frameTimeCounter) * 0.25 * PI))
                            * -0.5 * PI * sin((position.x + frameTimeCounter) * 0.5 * PI));
        
        float partialZ = 0.04 * (-0.25 * PI * sin((position.y + frameTimeCounter) * 0.25 * PI) * cos((position.x + frameTimeCounter) * 0.5 * PI)
                            - 0.375 * PI * cos((position.y + frameTimeCounter) * -0.375 * PI));
        
        float partialXRain = 0.04 * (0.75 * PI * cos((position.x + frameTimeCounter) * 0.75 * PI) * cos((position.x + frameTimeCounter) * PI)
                            + (sin((position.x + frameTimeCounter) * 0.75 * PI) + cos((position.y + frameTimeCounter) * 0.5 * PI))
                            * -1.0 * PI * sin((position.x + frameTimeCounter) * PI));
        
        float partialZRain = 0.04 * (-0.5 * PI * sin((position.y + frameTimeCounter) * 0.5 * PI) * cos((position.x + frameTimeCounter) * PI)
                            - 0.75 * PI * cos((position.y + frameTimeCounter) * -0.75 * PI));*/
        
        float partialX = (-.015 * PI * sin(.25 * PI * position.x + .125 * PI * position.y + 2.0 * frameTimeCounter)
                        + .03 * PI * cos(.75 * PI * position.x + .25 * PI * position.y + 3.0 * frameTimeCounter)
                        - .0075 * PI * sin(1.5 * PI * position.x + PI * position.y + 4.0 * frameTimeCounter)
                        + .003 * PI * cos(6.0 * PI * position.x + 2.0 * PI * position.y + 3.5 * frameTimeCounter))
                        //* (0.5 + 0.5 * texture2D(noisetex, vec2(0.02 * PI * position.x + 0.1 * frameTimeCounter, 0.02 * PI * position.y + 0.05 * frameTimeCounter)).r)
                        //+ .001 * PI * sin(-1.0 * PI * position.x - 2.8 * PI * position.y + 2.5 * frameTimeCounter)
                        /*+ .05 * texture2D(noisetex, vec2(0.1 * PI * position.x + 0.05 * frameTimeCounter, 0.1 * PI * position.y + 0.12 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.13 * frameTimeCounter, 0.1 * PI * position.y - 0.10 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.17 * frameTimeCounter, 0.1 * PI * position.y + 0.06 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x + 0.08 * frameTimeCounter, 0.1 * PI * position.y - 0.15 * frameTimeCounter)).r*/;

        float partialZ = (-.0075 * PI * sin(.25 * PI * position.x + .125 * PI * position.y + 2.0 * frameTimeCounter)
                        + .01 * PI * cos(.75 * PI * position.x + .25 * PI * position.y + 3.0 * frameTimeCounter)
                        - .02 * PI * sin(1.5 * PI * position.x + PI * position.y + 4.0 *  frameTimeCounter)
                        + .001 * PI * cos(6.0 * PI * position.x + 2.0 * PI * position.y + 3.5 * frameTimeCounter))
                        //* (0.5 + 0.5 * texture2D(noisetex, vec2(0.02 * PI * position.x + 0.1 * frameTimeCounter, 0.02 * PI * position.y + 0.05 * frameTimeCounter)).r)
                        //- .0028 * PI * sin(-1.0 * PI * position.x - 2.8 * PI * position.y + 2.5 * frameTimeCounter)
                        /*+ .05 * texture2D(noisetex, vec2(0.1 * PI * position.x + 0.05 * frameTimeCounter, 0.1 * PI * position.y + 0.12 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.13 * frameTimeCounter, 0.1 * PI * position.y - 0.10 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.17 * frameTimeCounter, 0.1 * PI * position.y + 0.06 * frameTimeCounter)).r
                        + .05 * texture2D(noisetex, vec2(0.1 * PI * position.x + 0.08 * frameTimeCounter, 0.1 * PI * position.y - 0.15 * frameTimeCounter)).r*/;

        // float offset =        0.5*abs(cos(.25*PI*horizontalPos.x + .125*PI*horizontalPos.y + 2.0*frameTimeCounter))
        //                 + 0.3*abs(sin(.75*PI*horizontalPos.x + .25*PI*horizontalPos.y + 3.0*frameTimeCounter))
        //                 + 0.2*abs(cos(1.5*PI*horizontalPos.x + PI*horizontalPos.y + 4.0*frameTimeCounter));

        // float partialX =    - 0.125*PI * sign(cos(.25*PI*position.x + .125*PI*position.y + 2.0*frameTimeCounter)) * sin(.25*PI*position.x + .125*PI*position.y + 2.0*frameTimeCounter)
        //                     + 0.225*PI * sign(sin(.75*PI*position.x + .25*PI*position.y + 3.0*frameTimeCounter)) * cos(.75*PI*position.x + .25*PI*position.y + 3.0*frameTimeCounter)
        //                     - 0.3*PI * sign(cos(1.5*PI*position.x + PI*position.y + 4.0*frameTimeCounter)) * sin(1.5*PI*position.x + PI*position.y + 4.0*frameTimeCounter);

        // float partialZ =    - 0.0625*PI * sign(cos(.25*PI*position.x + .125*PI*position.y + 2.0*frameTimeCounter)) * sin(.25*PI*position.x + .125*PI*position.y + 2.0*frameTimeCounter)
        //                     + 0.075*PI * sign(sin(.75*PI*position.x + .25*PI*position.y + 3.0*frameTimeCounter)) * cos(.75*PI*position.x + .25*PI*position.y + 3.0*frameTimeCounter)
        //                     - 0.2*PI * sign(cos(1.5*PI*position.x + PI*position.y + 4.0*frameTimeCounter)) * sin(1.5*PI*position.x + PI*position.y + 4.0*frameTimeCounter);
        
        float partialXRain = -.015 * PI * sin(.25 * PI * position.x + .125 * PI * position.y + 6.0 * frameTimeCounter)
                            + .03 * PI * cos(.75 * PI * position.x + .25 * PI * position.y + 9.0 * frameTimeCounter)
                            - .0075 * PI * sin(1.5 * PI * position.x + PI * position.y + 12.0 * frameTimeCounter)
                            + .003 * PI * cos(6.0 * PI * position.x + 2.0 * PI * position.y + 10.5 * frameTimeCounter); //+ .001 * PI * sin(-10.0 * PI * position.x + 28.0 * PI * position.y + 108.0 * frameTimeCounter)
                            //+ 0.05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.3 * frameTimeCounter, 0.1 * PI * position.y - 0.3 * frameTimeCounter)).r;

        float partialZRain = -.0075 * PI * sin(.25 * PI * position.x + .125 * PI * position.y + 6.0 * frameTimeCounter)
                            + .01 * PI * cos(.75 * PI * position.x + .25 * PI * position.y + 9.0 * frameTimeCounter)
                            - .02 * PI * sin(1.5 * PI * position.x + PI * position.y + 12.0 *  frameTimeCounter)
                            + .001 * PI * cos(6.0 * PI * position.x + 2.0 * PI * position.y + 10.5 * frameTimeCounter); //+ .0028 * PI * sin(-10.0 * PI * position.x + 28.0 * PI * position.y + 108.0 * frameTimeCounter)
                            //+ 0.05 * texture2D(noisetex, vec2(0.1 * PI * position.x - 0.3 * frameTimeCounter, 0.1 * PI * position.y - 0.3 * frameTimeCounter)).r;

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

        float partialX =  a0 * D0.x * w0 * cos(dot(D0, position.xz) * w0 + frameTimeCounter * s0)
                        + a1 * D1.x * w1 * cos(dot(D1, position.xz) * w1 + frameTimeCounter * s1)
                        + a2 * D2.x * w2 * cos(dot(D2, position.xz) * w2 + frameTimeCounter * s2)
                        + a3 * D3.x * w3 * cos(dot(D3, position.xz) * w3 + frameTimeCounter * s3);

        float partialZ =  a0 * D0.y * w0 * cos(dot(D0, position.xz) * w0 + frameTimeCounter * s0)
                        + a1 * D1.y * w1 * cos(dot(D1, position.xz) * w1 + frameTimeCounter * s1)
                        + a2 * D2.y * w2 * cos(dot(D2, position.xz) * w2 + frameTimeCounter * s2)
                        + a3 * D3.y * w3 * cos(dot(D3, position.xz) * w3 + frameTimeCounter * s3);
        
        float partialXRain = partialX;

        float partialZRain = partialZ;*/


        return normalize(mix(vec3(partialX, partialZ, 1.0), vec3(partialXRain, partialZRain, 1.0), rainStrength));
    }

    if(blockType < 2.0) {
        /*float offset = 0.04 * ((sin((position.x + frameTimeCounter) * PI * 0.1875) + cos((position.y + frameTimeCounter) * PI * 0.125))
                    * cos((position.x + frameTimeCounter) * PI * 0.25) + sin((position.y + frameTimeCounter) * PI * -0.1875));*/
        
        float partialX = 0.04 * (0.1875 * PI * cos((position.x + frameTimeCounter) * 0.1875 * PI) * cos((position.x + frameTimeCounter) * 0.25 * PI)
                            + (sin((position.x + frameTimeCounter) * 0.1875 * PI) + cos((position.y + frameTimeCounter) * 0.125 * PI))
                            * -0.25 * PI * sin((position.x + frameTimeCounter) * 0.25 * PI));
        
        float partialZ = 0.04 * (-0.25 * PI * sin((position.y + frameTimeCounter) * 0.125 * PI) * cos((position.x + frameTimeCounter) * 0.25 * PI)
                            - 0.1875 * PI * cos((position.y + frameTimeCounter) * -0.1875 * PI));

        return normalize(vec3(partialX, partialZ, 1.0));
    }
    //#endif

    // Vines wave
    //#ifdef vine_wave
    if(blockType < 3.0) {
        float tangent = 0.05 * mix(cos(position.y + frameTimeCounter * PI * 0.5), cos(position.y + frameTimeCounter * PI * 2.0), rainStrength);
        float norm = -1.0 / tangent;
        float theta = atan(abs(norm), normalize(norm));

        //return vec3(1.0);

        return vec3(0.0, sin(theta), cos(theta));
    }
    //#endif

    // Grass and other plants wave
    /*#ifdef grass_wave
    if(mc_Entity.x == 31.0 || mc_Entity.x == 37.0f || mc_Entity.x == 38.0f || mc_Entity.x == 59.0f || mc_Entity.x == 115.0f || mc_Entity.x == 141.0f || mc_Entity.x == 142.0f) {
        return float(texcoord.y < mc_midTexCoord.y) *
                    vec3(   0.1 * (pow(sin(position.x + frameTimeCounter * PI * 0.25), 2.0) * mix(1.0, cos(position.x + frameTimeCounter * PI * 2.0), rainStrength) - 0.5), 
                            0.0,
                            0.1 * (pow(cos(position.y + frameTimeCounter * PI * 0.3), 2.0) * mix(1.0, sin(position.y + frameTimeCounter * PI * 2.0), rainStrength) - 0.5));
    }
    #endif*/

    // Leaves wave
    /*#ifdef leaves_wave
    if(mc_Entity.x == 161.0f || mc_Entity.x == 18.0) {
        return vec3(    mix(0.05, 0.08, rainStrength) * clamp((pow(sin((position.x + frameTimeCounter) * PI * 0.25), 2.0) - 0.5) * mix(1.0, cos(position.y + frameTimeCounter * PI * 2.0), rainStrength) - 0.5, -0.7, 0.7), 
                        mix(0.05, 0.08, rainStrength) * clamp((pow(cos((position.y + frameTimeCounter) * PI * 0.125), 2.0) - 0.5) * mix(1.0, sin(position.x + frameTimeCounter * PI * 2.0), rainStrength) - 0.5, -0.7, 0.7),
                        mix(0.05, 0.08, rainStrength) * clamp((pow(cos((position.y + frameTimeCounter) * PI * 0.25), 2.0) - 0.5) * mix(1.0, sin(position.y + frameTimeCounter * PI * 2.0), rainStrength) - 0.5, -0.7, 0.7));
    }
    #endif*/
}

vec3 ParallaxMappingWater(vec2 vertexPos, vec3 viewDir) {
	float layerDepth = 1.0 / Water_POM_Layers;
	float currentLayerDepth = 0.0;
    vec2 p = (viewDir.xy / viewDir.z) * Water_Depth;
    vec2 deltaTexCoords = p / Water_POM_Layers;

	vec2  currentTexcoord = vertexPos;
	float currentDepthMapValue = waterWaveOffset(currentTexcoord);
	
	while(currentLayerDepth < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		currentTexcoord -= deltaTexCoords;
		// get depthmap value at current texture coordinates
		currentDepthMapValue = waterWaveOffset(currentTexcoord);
		// get depth of next layer
		currentLayerDepth += layerDepth;
	}

	return vec3(currentTexcoord, -(currentLayerDepth - layerDepth) * Water_Depth);
}
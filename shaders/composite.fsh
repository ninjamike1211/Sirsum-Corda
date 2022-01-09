#version 420 compatibility

#include "functions.glsl"
#include "kernels.glsl"
#include "sky.glsl"
#include "lighting.glsl"

in vec2 texcoord;
in vec3 viewVector;
flat in float exposure;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex3;
uniform sampler2D colortex15;
uniform sampler2D depthtex0;
uniform sampler2D noisetex;
uniform vec3 sunPosition;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform float eyeAltitude;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0,15 */
layout(location = 0) out vec4 albedo;
layout(location = 1) out vec4 exposureOutput;

float luminance(vec3 v) {
    return dot(v, vec3(0.2126f, 0.7152f, 0.0722f));
}

vec3 change_luminance(vec3 c_in, float l_out) {
    float l_in = luminance(c_in);
    return c_in * (l_out / l_in);
}

vec3 reinhard_extended_luminance(vec3 v, float max_white_l) {
    float l_old = luminance(v);
    float numerator = l_old * (1.0f + (l_old / (max_white_l * max_white_l)));
    float l_new = numerator / (1.0f + l_old);
    return change_luminance(v, l_new);
}

vec3 reinhard_jodie(vec3 v) {
    float l = luminance(v);
    vec3 tv = v / (1.0f + v);
    return mix(v / (1.0f + l), tv, tv);
}

vec3 uncharted2_tonemap_partial(vec3 x) {
    float A = 0.15f;
    float B = 0.50f;
    float C = 0.10f;
    float D = 0.20f;
    float E = 0.02f;
    float F = 0.30f;
    return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

vec3 uncharted2_filmic(vec3 v) {
    float exposure_bias = 2.0f;
    vec3 curr = uncharted2_tonemap_partial(v * exposure_bias);

    vec3 W = vec3(11.2f);
    vec3 white_scale = vec3(1.0f) / uncharted2_tonemap_partial(W);
    return curr * white_scale;
}

void main() {
    albedo = texture2D(colortex0, texcoord);
    float depth = texture2D(depthtex0, texcoord).r;
    vec3 viewPos = calcViewPos(viewVector, depth);

    // albedo = linearToSRGB(albedo);

    // if(depth != 1.0)
        // albedo.rgb = mix(albedo.rgb, SunMoonColor /* * vec3(0.7, 0.75, 0.9) */, clamp(-1.0 + exp(length(viewPos) * 0.0007), 0.0, 1.0));

    vec3 normal = NormalDecode(texture2D(colortex1, texcoord).xy);
    vec3 specMap = texture2D(colortex3, texcoord).rgb;
    if(specMap.b > 0.1) {
        // albedo.rgb = calcSSRNew(texcoord, depth, viewPos, normal, sunPosition, eyeAltitude, depthtex0, colortex0, gbufferProjection, gbufferModelViewInverse);
        // albedo.rgb = calcSSRSues(viewPos, normal, sunPosition, eyeAltitude, depthtex0, colortex0, gbufferModelViewInverse, gbufferProjection, gbufferProjectionInverse);
    }


    // reinhard tone mapping
    // albedo.rgb = vec3(1.0) - exp(-albedo.rgb * exposure);
    // albedo.rgb /= albedo.rgb + vec3(1.0);
    // albedo.rgb = reinhard_extended_luminance(albedo.rgb, exposure);
    albedo.rgb = reinhard_jodie(albedo.rgb);
    // albedo.rgb = uncharted2_filmic(albedo.rgb);
    // gamma correction 
    // if(depth == 1.0)
        albedo = linearToSRGB(albedo);

    albedo.rgb += texture2D(noisetex, fract(texcoord * vec2(viewWidth, viewHeight) / 512.0)).r / 255.0;

    exposureOutput = vec4(exposure);
}
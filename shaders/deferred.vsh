#version 400 compatibility

#include "functions.glsl"
#include "sky.glsl"

out vec2 texcoord;
out vec3 viewVector;
flat out vec3 SunMoonColor;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
uniform float eyeAltitude;

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    vec4 ray = gbufferProjectionInverse * vec4(texcoord * 2.0 - 1.0, 0.0, 1.0);
	viewVector = (ray.xyz / ray.w);
	viewVector /= viewVector.z;

    vec3 sunColor = skyColor(normalize(sunPosition), normalize(sunPosition), eyeAltitude, mat3(gbufferModelViewInverse));
    vec3 moonColor = skyMoonColor(normalize(moonPosition), normalize(moonPosition), eyeAltitude, mat3(gbufferModelViewInverse));
    SunMoonColor = vec3(mix(0.0, 1.0, smoothstep(0.0, 1.0, sunColor.r)) + mix(0.0, 0.4, smoothstep(0.0, 0.01, moonColor.r)));
    // SunMoonColor = lightColor(normalize(sunPosition), normalize(moonPosition), eyeAltitude, mat3(gbufferModelViewInverse));
}
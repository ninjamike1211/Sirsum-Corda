#version 400 compatibility

#include "functions.glsl"

in vec4 at_tangent;
in vec2 mc_midTexCoord;

out vec2 texcoord;
out vec4 glColor;
out vec3 viewPos;
flat out vec4 textureBounds;

#ifdef MC_NORMAL_MAP
    flat out mat3 tbn;
#endif

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
    gl_Position.xyz = distort(gl_Position.xyz);

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glColor = gl_Color;

    viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    #ifdef MC_NORMAL_MAP
        vec3 glNormal = normalize(gl_NormalMatrix * gl_Normal);
        vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
        vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
        tbn = mat3(	tangent.x, binormal.x, glNormal.x,
                    tangent.y, binormal.y, glNormal.y,
                    tangent.z, binormal.z, glNormal.z);
    #endif

    vec2 halfSize = abs(texcoord - mc_midTexCoord);
	textureBounds = vec4(mc_midTexCoord.xy - halfSize, mc_midTexCoord.xy + halfSize);
}
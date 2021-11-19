in vec4 at_tangent;

out vec2 texcoord;
out vec4 glColor;
flat out vec3 glNormal;
out vec2 lmcoord;

#ifdef MC_NORMAL_MAP
    flat out mat3 tbn;
#endif

void main() {
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glColor = gl_Color;
    glNormal = (gl_ModelViewMatrix * vec4(gl_Normal, 0.0)).xyz;

    #ifdef MC_NORMAL_MAP
        glNormal = normalize(gl_NormalMatrix * gl_Normal);
        vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
        vec3 binormal = normalize(gl_NormalMatrix * cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
	
        tbn = mat3(	tangent.x, binormal.x, glNormal.x,
                    tangent.y, binormal.y, glNormal.y,
                    tangent.z, binormal.z, glNormal.z);
    #endif
}
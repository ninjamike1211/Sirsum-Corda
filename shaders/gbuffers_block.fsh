#version 120

#include "include.glsl"

uniform sampler2D lightmap;
uniform sampler2D texture;
#ifdef MC_NORMAL_MAP
uniform sampler2D normals;
#endif
#ifdef MC_SPECULAR_MAP
uniform sampler2D specular;
#endif

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 velocity;
varying mat3 tbn;

void main() {
	/* DRAWBUFFERS:012345 */

	vec4 color = texture2D(texture, texcoord);
	color.rgb *= glcolor.rgb;

	gl_FragData[0] = color; //gcolor
	#ifdef MC_NORMAL_MAP
		vec4 normalTexVal = texture2D(normals, texcoord);
        vec3 bumpmap = decodeNormal(normalTexVal.xy * 2.0 - 1.0);
		float ao = normalTexVal.b;
	#else
		vec3 bumpmap = vec3(0.0, 0.0, 1.0);
		float ao = 1.0;
	#endif

	#if SSAO == 0
		ao = min(ao, glcolor.a);
	#endif

	vec3 normal = (normalize(bumpmap) * tbn) * 0.5f + 0.5f;
	#ifdef Combine_Normal_Buffers
		gl_FragData[1] = vec4(normal.xy, tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5);
	#else
		gl_FragData[1] = vec4(normal, 1.0);
		gl_FragData[2] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[2][2] * 0.5 + 0.5, 1.0);
	#endif
	
	// gl_FragData[2] = vec4(velocity, 1.0);
	gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
	#ifdef MC_SPECULAR_MAP
        gl_FragData[4] = vec4(texture2D(specular, texcoord).rgb, 1.0);
    #endif
	gl_FragData[5] = vec4(0.0, ao, 0.0, 1.0);
}
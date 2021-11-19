#version 120

#define Combine_Normal_Buffers

uniform sampler2D lightmap;
uniform sampler2D texture;
#ifdef MC_NORMAL_MAP
uniform sampler2D normals;
#endif
#ifdef MC_SPECULAR_MAP
uniform sampler2D specular;
#endif

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying mat3 tbn;

void main() {
	/* DRAWBUFFERS:01234 */
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	// gl_FragData[0] = vec4(color.rgb, float(color.a > 0.1));
	gl_FragData[0] = color;

	#ifdef Combine_Normal_Buffers
		gl_FragData[1] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5);
	#else
		gl_FragData[1] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[2][2] * 0.5 + 0.5, 1.0);
		gl_FragData[2] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[2][2] * 0.5 + 0.5, 1.0);
	#endif
	
	// gl_FragData[2] = vec4(viewPos);
	gl_FragData[3] = vec4(lmcoord, gl_FragCoord.z, 1.0);
	gl_FragData[4] = vec4(0.0, 0.0, 0.0, 1.0);
	gl_FragData[5] = vec4(0.0, 0.0, 0.0, 1.0);
}
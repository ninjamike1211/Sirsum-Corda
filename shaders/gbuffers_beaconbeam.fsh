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
varying vec3 normal;

void main() {
	/* DRAWBUFFERS:012345 */
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	if(color.a < 0.4)
		discard;

	gl_FragData[0] = color; //gcolor
	#ifdef Combine_Normal_Buffers
		gl_FragData[1] = vec4(normal.xy * 0.5f + 0.5f, normal.xy * 0.5f + 0.5f);
	#else
		gl_FragData[1] = vec4(normal * 0.5f + 0.5f, 1.0);
		gl_FragData[2] = vec4(normal * 0.5f + 0.5f, 1.0);
	#endif

	// gl_FragData[2] = vec4(viewPos);
	gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
	#ifdef MC_SPECULAR_MAP
        gl_FragData[4] = vec4(texture2D(specular, texcoord).rgb, 1.0);
    #endif
	gl_FragData[5] = vec4(1.0, 1.0, 0.0, 1.0);
}
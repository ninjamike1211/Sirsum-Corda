#version 120

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
varying mat3 tbn;

void main() {
	/* DRAWBUFFERS:0123456 */
	vec4 color = texture2D(texture, texcoord);
	color.rgb *= glcolor.rgb;

	gl_FragData[0] = color; //gcolor
	#ifdef MC_NORMAL_MAP
        vec2 premap = texture2D(normals, texcoord).xy * 2.0 - 1.0;
        vec3 bumpmap = vec3(premap, sqrt(1.0 - premap.x * premap.x - premap.y * premap.y));
		// float ao = texture2D(normals, texcoord).b;
		float ao = glcolor.a;
		float height = texture2D(normals, texcoord).a;
	#else
		vec3 bumpmap = vec3(0.0, 0.0, 1.0);
		float ao = glcolor.a;
		float height = 1.0;
	#endif
	gl_FragData[1] = vec4((bumpmap * tbn) * 0.5f + 0.5f, 1.0);
	// gl_FragData[2] = vec4(viewPos);
	gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
	#ifdef MC_SPECULAR_MAP
        gl_FragData[4] = vec4(texture2D(specular, texcoord).rgb, 1.0);
    #endif
	gl_FragData[5] = vec4(height, ao, 1.0, 1.0);
	gl_FragData[6] = vec4(0.0, 0.0, 0.0, 1.0);
}
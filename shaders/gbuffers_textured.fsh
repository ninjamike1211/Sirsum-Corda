#version 120

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
varying vec4 shadowPos;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	// float shadowDepth = texture2D(shadowtex0, shadowPos.xy).r;

	// float shadowVal = smoothstep(0.0, 0.2, shadowPos.w) * 0.5 + 0.5;
	// if(shadowDepth < shadowPos.z)
	// 	shadowVal = min(shadowVal, 0.5);

	//color *= texture2D(lightmap, lmcoord * vec2(1.0, shadowVal));

/* DRAWBUFFERS:01234 */
	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4(normal * 0.5f + 0.5f, 1.0);
	gl_FragData[2] = vec4(shadowPos.xyz, 1.0);
	gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
	#ifdef MC_SPECULAR_MAP
        gl_FragData[4] = texture2D(specular, texcoord);
    #endif
}
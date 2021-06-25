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
varying mat3 tbn;
varying vec4 viewPos;

void main() {
	/* DRAWBUFFERS:012345 */
	vec4 color = texture2D(texture, texcoord) * glcolor;
	// color *= texture2D(lightmap, lmcoord);

	gl_FragData[0] = color; //gcolor
	gl_FragData[1] = vec4((vec3(0.0, 0.0, 1.0) * tbn) * 0.5f + 0.5f, 1.0);
	gl_FragData[2] = vec4(viewPos);
	gl_FragData[3] = vec4(lmcoord, gl_FragCoord.z, 1.0);
}
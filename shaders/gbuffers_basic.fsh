#version 120

// uniform sampler2D lightmap;
uniform vec3 sunPosition;

varying vec2 lmcoord;
varying vec4 glcolor;
varying vec3 normal;

void main() {
	vec4 color = glcolor;
	// color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:012345 */
	gl_FragData[0] = vec4(color.rgb, 1.0); //gcolor
	gl_FragData[1] = vec4(normalize(sunPosition), 1.0);
	gl_FragData[2] = vec4(normalize(sunPosition), 1.0);
	gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
	gl_FragData[4] = vec4(0.0, 0.0, 0.0, 1.0);
	gl_FragData[5] = vec4(0.0, 1.0, 0.0, 1.0);
	// gl_FragData[1] = vec4(1.0);
}
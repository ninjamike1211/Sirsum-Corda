#version 120

#define shadowFSH

#include "include.glsl"

uniform sampler2D texture;
#ifdef MC_NORMAL_MAP
uniform sampler2D normals;
#endif
uniform vec3 cameraPosition;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying float isWater;
varying mat3 tbn;
varying vec4 glVertex;
varying vec4 textureBounds;
// varying vec4 clipPos;
varying vec3 viewPos;
varying vec4 vertexPos;

void main() {
	#ifdef MC_NORMAL_MAP
	#ifdef POM_PDO
		vec3 viewDirTBN = tbn * normalize(viewPos);
		vec3 POMResults;
		vec2 texcoordUse;
		if(isWater > 0.9) {
			POMResults = ParallaxMappingWater(vertexPos.xz + cameraPosition.xz, viewDirTBN);
			vec2 singleTexSize = vec2(textureBounds.z - textureBounds.x, textureBounds.w - textureBounds.y);
			texcoordUse = texcoord + (POMResults.xy - (vertexPos.xz + cameraPosition.xz)) * singleTexSize;

			texcoordUse.x -= floor((texcoordUse.x - textureBounds.x) / singleTexSize.x) * singleTexSize.x;
			texcoordUse.y -= floor((texcoordUse.y - textureBounds.y) / singleTexSize.y) * singleTexSize.y;
		}
		else {
			POMResults = ParallaxMapping(texcoord, viewDirTBN, textureBounds.zw-textureBounds.xy, normals, textureBounds);
			texcoordUse = POMResults.xy;
		// vec3 tbnDiff = vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), POMResults.z);
		}
		vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * POMResults.z) * tbn;

		// vec3 viewDir = tbn * normalize(viewPos);
		// // vec3 tbnDiff = vec3((-viewDir.xy / viewDir.z) * 0.3 * POM_Depth, -0.3 * POM_Depth);
		// vec3 tbnDiff = vec3(0.0);
		// vec2 texcoordUse = texcoord;

		vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff * 1.0, 1.0);
		clipPos.xyz = distort(clipPos.xyz);
		vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;

		// gl_FragDepth = (gl_ModelViewProjectionMatrix * glVertex).z;
		// gl_FragDepth = getDistortFactor(screenPos.xy);
		gl_FragDepth = screenPos.z;
		// gl_FragDepth = distort(screenPos, getDistortFactor(screenPos.xy)).z * 2.0;
		// gl_FragDepth = clipPos.z;
	#else
		vec2 texcoordUse = texcoord;
	#endif
	#else
		vec2 texcoordUse = texcoord;
	#endif

	vec4 color = texture2D(texture, texcoordUse) * glcolor;

	if(isWater > 0.9)
		color.a = 0.4;

	gl_FragData[0] = color;
}
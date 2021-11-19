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
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex9;
uniform vec3 cameraPosition;

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 glcolor;
varying mat3 tbn;
varying vec4 vertexPos;
varying float blockType;
varying vec4 textureBounds;
varying vec3 viewPos;

void main() {
	/* DRAWBUFFERS:0123456 */

	if(blockType > 0.0 && blockType < 0.2) {
		#ifdef Water_POM
			vec3 viewDirTBN = tbn * normalize(viewPos);
			vec3 horizontalPosPOM = ParallaxMappingWater(vertexPos.xz + cameraPosition.xz, viewDirTBN);
			// vec2 horizontalPosPOM = vertexPos.xz + cameraPosition.xz;

			vec2 singleTexSize = vec2(textureBounds.z - textureBounds.x, textureBounds.w - textureBounds.y);
			vec2 texcoordUse = texcoord + (horizontalPosPOM.xy - (vertexPos.xz + cameraPosition.xz)) * singleTexSize;

			texcoordUse.x -= floor((texcoordUse.x - textureBounds.x) / singleTexSize.x) * singleTexSize.x;
			texcoordUse.y -= floor((texcoordUse.y - textureBounds.y) / singleTexSize.y) * singleTexSize.y;

			#ifdef POM_PDO
				vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * horizontalPosPOM.z) * tbn;
				vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
				vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
				gl_FragDepth = screenPos.z;
			#endif
		#else
			vec2 horizontalPosPOM = vertexPos.xz + cameraPosition.xz;
			vec2 texcoordUse = texcoord;
		#endif


		#if Water_Color == 0
			vec4 color = texture2D(texture, texcoordUse);
			color.rgb *= glcolor.rgb;
			color.a = isEyeInWater == 1.0 ? 0.7 : 0.4;
		#elif Water_Color == 1
			vec4 color = vec4(glcolor.rgb, isEyeInWater == 1.0 ? 0.7 : 0.4);
		#else
			vec4 color = vec4(0.0, 0.0, 0.0, 0.4);
		#endif

		gl_FragData[0] = vec4(color); //gcolor

		// vec3 bumpmap = 0.5 * waterNormal(horizontalPosPOM);
		// #ifndef Smooth_Water
		// 	bumpmap += texture2D(colortex7, 0.0625 * (horizontalPosPOM + vec2(-0.25, -0.55) * frameTimeCounter)).rgb * 0.2 - 0.1;
		// 	bumpmap += texture2D(colortex9, 0.0625 * (horizontalPosPOM + vec2(0.3, -0.4) * frameTimeCounter)).rgb * 0.2 - 0.1;
		// #endif
		// bumpmap += vec3(0.0, 0.0, Water_Smoothness);
		vec3 bumpmap = waterNormal(horizontalPosPOM.xy);
		vec3 normal = (normalize(bumpmap) * tbn) * 0.5f + 0.5f;
		#ifdef Combine_Normal_Buffers
			gl_FragData[1] = vec4(normal.xy, tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5);
		#else
			gl_FragData[1] = vec4(normal, 1.0);
			gl_FragData[2] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[2][2] * 0.5 + 0.5, 1.0);
		#endif

		// gl_FragData[2] = vec4(viewPos);
		gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
		gl_FragData[4] = vec4(1.0, 0.89, 1.0, 1.0);
		gl_FragData[5] = vec4(1.0, 1.0, 0.0, 1.0);
		gl_FragData[6] = vec4(1.0, 0.0, 0.0, 1.0);

		// gl_FragData[0] = vec4(float(texcoordUse.x < texcoordRange.x), float(texcoordUse.x > texcoordRange.z), 0.0, 1.0);
	}
	else {
		#ifdef MC_NORMAL_MAP
		#ifdef POM
			vec3 viewDirTBN = tbn * normalize(viewPos);

			vec3 POMResults = ParallaxMapping(texcoord, viewDirTBN, textureBounds.zw-textureBounds.xy, normals, textureBounds);
			vec2 texcoordUse = POMResults.xy;

			#ifdef POM_PDO
				vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * POMResults.z) * tbn;
				vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
				vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
				gl_FragDepth = screenPos.z;
			#endif
		#else
			vec2 texcoordUse = texcoord;
		#endif
		#else
		vec2 texcoordUse = texcoord;
		#endif

		vec4 color = texture2D(texture, texcoordUse);
		color.rgb *= glcolor.rgb;
		gl_FragData[0] = color; //gcolor
		#ifdef MC_NORMAL_MAP
			vec2 premap = texture2D(normals, texcoordUse).xy * 2.0 - 1.0;
			vec3 bumpmap = vec3(premap, sqrt(1.0 - premap.x * premap.x - premap.y * premap.y));
			float ao = texture2D(normals, texcoordUse).b;
		#else
			vec3 bumpmap = vec3(0.0, 0.0, 1.0);
			float ao = 1.0;
		#endif
		vec3 normal = (normalize(bumpmap) * tbn) * 0.5f + 0.5f;
		#ifdef Combine_Normal_Buffers
			gl_FragData[1] = vec4(normal.xy, tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5);
		#else
			gl_FragData[1] = vec4(normal, 1.0);
			gl_FragData[2] = vec4(tbn[0][2] * 0.5 + 0.5, tbn[1][2] * 0.5 + 0.5, tbn[2][2] * 0.5 + 0.5, 1.0);
		#endif
		// gl_FragData[2] = vec4(viewPos);
		gl_FragData[3] = vec4(lmcoord, 0.0, 1.0);
		#ifdef MC_SPECULAR_MAP
			gl_FragData[4] = vec4(texture2D(specular, texcoordUse).rgb, 1.0);
		#endif
		gl_FragData[5] = vec4(0.0, ao, 0.0, 1.0);
		gl_FragData[6] = vec4(0.0, 0.0, 0.0, 1.0);
	}
}
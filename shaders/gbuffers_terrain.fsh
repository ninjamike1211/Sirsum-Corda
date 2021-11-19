#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
#ifdef MC_NORMAL_MAP
uniform sampler2D normals;
#endif
#ifdef MC_SPECULAR_MAP
uniform sampler2D specular;
#endif
uniform vec3 cameraPosition;

#include "include.glsl"

varying vec2 texcoord;
varying vec2 vineTexcoord;
varying float verticalOffset;
varying vec2 lmcoord;
varying vec3 velocity;
varying vec4 glcolor;
varying mat3 tbn;
varying vec3 viewPos;
varying vec4 textureBounds;
varying float blockType;

vec3 POMVines(vec2 texcoord, float offset, vec3 viewDir) {
	float layerDepth = 1.0 / POM_Layers;
	float currentLayerDepth = 0.0;
    vec2 p = (-viewDir.xy / viewDir.z) * 0.15;
    vec2 deltaTexCoords = p / POM_Layers;

	vec2  currentTexcoord = texcoord;
	float blockOffset = offset - texcoord.y;
	float currentDepthMapValue = 1.0 - vineWaveHeight(texcoord.y + blockOffset);
	
	while(currentLayerDepth < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		currentTexcoord += deltaTexCoords;
		// get depthmap value at current texture coordinates
		currentDepthMapValue = 1.0 - vineWaveHeight(texcoord.y + blockOffset);
		// get depth of next layer
		currentLayerDepth += layerDepth;
	}

	return vec3(currentTexcoord, 0.0 - (currentLayerDepth + layerDepth) * 0.04);
}

void main() {
	/* RENDERTARGETS: 0,1,2,3,4,5,14 */

	vec2 texcoordUse = texcoord;

	if(blockType > 1.9 && blockType < 2.2) {  // Vines
		#ifdef MC_NORMAL_MAP
		#ifdef POM
			vec2 singleTexSize = textureBounds.zw-textureBounds.xy;
			vec3 POMResults = POMVines(vineTexcoord, verticalOffset, tbn * normalize(viewPos));
			texcoordUse = POMResults.xy;

			// texcoordUse.x -= floor(texcoordUse.x);
        	texcoordUse.y -= floor(texcoordUse.y);
			if(floor(texcoordUse.x) != 0.0 /* || floor(texcoordUse.y) != 0.0 */)
				discard;
			texcoordUse = texcoordUse.xy * singleTexSize + textureBounds.xy;

			// texcoordUse = vec2(0.0);

			gl_FragData[6] = vec4(vec3(cameraPosition.y - verticalOffset), 1.0);

			#ifdef POM_PDO
				vec3 tbnDiff = vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), POMResults.z);
				vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
				vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
				gl_FragDepth = screenPos.z;
			#endif
		#endif
		#endif
	}
	else {
		#ifdef MC_NORMAL_MAP
		#ifdef POM
		// if(texture2D(texture, texcoord).a > 0.01) {

			vec3 viewDirTBN = tbn * normalize(viewPos);
			vec3 POMResults = ParallaxMapping(texcoord, viewDirTBN, textureBounds.zw-textureBounds.xy, normals, textureBounds);
			texcoordUse = POMResults.xy;

			#ifdef POM_PDO
				// vec3 tbnDiff = vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), POMResults.z);
				// vec3 tbnDiff = (gbufferModelView * vec4(vec3((texcoordUse - texcoord) / (textureBounds.zw - textureBounds.xy), -POMResults.z) * tbn, 1.0)).xyz;
				vec3 tbnDiff = ((viewDirTBN / viewDirTBN.z) * POMResults.z) * tbn;
				// vec3 tbnDiff = vec3(0.0);
				vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos + tbnDiff, 1.0);
				vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
				gl_FragDepth = screenPos.z;
			#endif
		// }
		#endif
		#endif
	}

	vec4 color = texture2D(texture, texcoordUse);
	color.rgb *= glcolor.rgb;

	gl_FragData[0] = color; //gcolor
	#ifdef MC_NORMAL_MAP
		vec4 normalTexVal = texture2D(normals, texcoordUse);
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
        gl_FragData[4] = vec4(texture2D(specular, texcoordUse).rgb, 1.0);
    #endif
	gl_FragData[5] = vec4(0.0, ao, 0.0, 1.0);
}
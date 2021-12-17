#define POM
#define POM_Depth 1.0 // Depth of POM in blocks. Lower values decreases effect. Appealing values may depend on resource pack [0.2 0.4 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.6 1.8 2.0 3.0 4.0]
#define POM_Layers 50 // Quality of POM. Higher values are better quality with more performance cost [5 10 20 30 40 50 75 100 200]
#define POM_PDO

vec3 ParallaxMapping(vec2 texcoord, vec3 viewDir, vec2 singleTexSize, sampler2D normalTex, vec4 texcoordRange) {
    // float layerCount = mix(256, 20, clamp(dot(normal, viewDir), 0.0, 1.0));
    // float layerCount = mix(256, 20, dot(viewDir, vec3(0.0, 0.0, -1.0)));
    float layerCount = POM_Layers;

	float layerDepth = 1.0 / layerCount;
	float currentLayerDepth = 0.0;
    vec2 p = (-viewDir.xy / viewDir.z) * 0.25 * POM_Depth * singleTexSize;
    vec2 deltaTexCoords = p / layerCount;

	vec2  texcoordFinal = texcoord;

    #ifdef POM_Interpolate
	    float currentDepthMapValue = 1.0 - interpolateHeight(normalTex, texcoordFinal, texcoordRange);
    #else
        float currentDepthMapValue = 1.0 - texture2D(normalTex, texcoordFinal).a;
    #endif
	
	while(currentLayerDepth < currentDepthMapValue)
	{
		// shift texture coordinates along direction of P
		texcoordFinal += deltaTexCoords;

        // wrap texture coordinates if they extend out of range
        texcoordFinal.x -= floor((texcoordFinal.x - texcoordRange.x) / singleTexSize.x) * singleTexSize.x;
        texcoordFinal.y -= floor((texcoordFinal.y - texcoordRange.y) / singleTexSize.y) * singleTexSize.y;

		// get depthmap value at current texture coordinates
		// currentDepthMapValue = 1.0 - texture2D(normalTex, texcoordFinal).a;
        #ifdef POM_Interpolate
            currentDepthMapValue = 1.0 - interpolateHeight(normalTex, texcoordFinal, texcoordRange);
        #else
            currentDepthMapValue = 1.0 - texture2D(normalTex, texcoordFinal).a;
        #endif
		// get depth of next layer
		currentLayerDepth += layerDepth;
	}

    // #ifdef shadowFSH
    //     return vec3(texcoordFinal, -(currentLayerDepth) * 0.25 * POM_Depth);
    // #else
	    return vec3(texcoordFinal, -(currentLayerDepth - layerDepth) * 0.25 * POM_Depth);
    // #endif
}
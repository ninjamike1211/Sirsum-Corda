#define Water_Direction 4
#define Water_Depth 0.25

const vec2 waveDirs[] = vec2[] (
#if Water_Direction == 0
    vec2(-0.65364, -0.75680),
    vec2(0.26749, 0.96355),
    vec2(-0.84810, -0.52983),
    vec2(0.90044, 0.43496),
    vec2(0.92747, -0.37387)
#elif Water_Direction == 1
    vec2(-0.65364, -0.75680),
    vec2(-0.26749, -0.96355),
    vec2(-0.84810, -0.52983),
    vec2(-0.90044, -0.43496),
    vec2(-0.92747, -0.37387)
#elif Water_Direction == 2
    vec2(-0.65364, 0.75680),
    vec2(-0.26749, 0.96355),
    vec2(-0.84810, 0.52983),
    vec2(-0.90044, 0.43496),
    vec2(-0.92747, 0.37387)
#elif Water_Direction == 3
    vec2(0.65364, -0.75680),
    vec2(0.26749, -0.96355),
    vec2(0.84810, -0.52983),
    vec2(0.90044, -0.43496),
    vec2(0.92747, -0.37387)
#elif Water_Direction == 4
    vec2(0.65364, 0.75680),
    vec2(0.26749, 0.96355),
    vec2(0.84810, 0.52983),
    vec2(0.90044, 0.43496),
    vec2(0.92747, 0.37387)
#endif
);

float waveFunction(vec2 pos, float time, float amplitude, float frequency, float speed, vec2 direction) {
    return amplitude * (sin(dot(pos, direction) * frequency + time * speed) + 1.0) / 2.0;
}

vec2 waveFunctionDeriv(vec2 pos, float time, float amplitude, float frequency, float speed, vec2 direction) {
    float partialX = direction.x * frequency * amplitude * cos(dot(pos, direction) * frequency + time * speed);
    float partialZ = direction.y * frequency * amplitude * cos(dot(pos, direction) * frequency + time * speed);

    return 0.5 * Water_Depth * vec2(partialX, partialZ);
}

float waterWaveOffset(vec2 horizontalPos, float frameTimeCounter) {

    float offset =  + waveFunction(horizontalPos, frameTimeCounter, 0.6, 1, PI / 3.0, waveDirs[0])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 1, PI / 1.25, waveDirs[1])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 2, PI, waveDirs[2])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 4, PI / 0.75, waveDirs[3])
                    + waveFunction(horizontalPos, frameTimeCounter, 0.1, 6, PI / 0.5, waveDirs[4]);
    
    #ifdef Water_Noise
        return mix(offset, 0.5, texture2D(noisetex, 0.05 * horizontalPos + vec2(0.01 * frameTimeCounter)).a * 0.2);
    #else
        return offset;
    #endif
}

vec3 waterNormal(vec2 horizontalPos, float frameTimeCounter) {

    vec2 partials = waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.6, 1, PI / 3.0, waveDirs[0]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 1, PI / 1.25, waveDirs[1]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 2, PI, waveDirs[2]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 4, PI / 0.75, waveDirs[3]);
    partials += waveFunctionDeriv(horizontalPos, frameTimeCounter, 0.1, 6, PI / 0.5, waveDirs[4]);
    
    #ifdef Water_Noise
        vec4 noiseVal = texture2D(noisetex, 0.05 * horizontalPos + vec2(0.01 * frameTimeCounter));
        return normalize(mix(vec3(0.2 * partials, 1.0), vec3(-Water_Depth, -Water_Depth, 1.0) * (noiseVal.rgb * 2.0 - 1.0), noiseVal.a * 0.2));
    #else
        return vec3(Water_Depth * partials, 1.0);
    #endif
}
#define PI 3.141592654
#define skySamples 16
#define lightSamples 8
#define earthRadius 4*636000
#define atmosphereRadius 4*642000
#define seaLevel 0
#define rayleighScaleHeight 7994
#define mieScaleHeight 2200
#define rayleighRedScatter 0.0000038
#define rayleighGreenScatter 0.0000135
#define rayleighBlueScatter 0.0000331
#define rayleighScatter vec3(rayleighRedScatter, rayleighGreenScatter, rayleighBlueScatter)
#define mieScatter 0.000021
#define meanCosine 0.76

// https://gist.github.com/wwwtyro/beecc31d65d1004f5a9d
float intersectFromInside(vec3 r0, vec3 rd, vec3 s0, float sr) {
    // - r0: ray origin
    // - rd: normalized ray direction
    // - s0: sphere center
    // - sr: sphere radius
    // - Returns distance from r0 to first intersecion with sphere,
    //   or -1.0 if no intersection.
    float a = dot(rd, rd);
    vec3 s0_r0 = r0 - s0;
    float b = 2.0 * dot(rd, s0_r0);
    float c = dot(s0_r0, s0_r0) - (sr * sr);
    if (b*b - 4.0*a*c < 0.0) {
        return -1.0;
    }
    return (-b + sqrt((b*b) - 4.0*a*c))/(2.0*a);
}

float intersectFromOutside(vec3 r0, vec3 rd, vec3 s0, float sr) {
    // - r0: ray origin
    // - rd: normalized ray direction
    // - s0: sphere center
    // - sr: sphere radius
    // - Returns distance from r0 to first intersecion with sphere,
    //   or -1.0 if no intersection.
    float a = dot(rd, rd);
    vec3 s0_r0 = r0 - s0;
    float b = 2.0 * dot(rd, s0_r0);
    float c = dot(s0_r0, s0_r0) - (sr * sr);
    if (b*b - 4.0*a*c < 0.0) {
        return -1.0;
    }
    return (-b - sqrt((b*b) - 4.0*a*c))/(2.0*a);
}

// vec3 skyColor2(vec3 eyeDir, vec3 sunEyeDir, float altitude) {

//     vec3 eyeOrigin = vec3(0.0, earthRadius + 0.0001 * (altitude-seaLevel), 0.0);

//     float rayLength = raySphereIntersect(eyeOrigin, eyeDir, vec3(0.0), atmosphereRadius);
    
//     vec3 position = 
//     for(int i = 0; i < skySamples; ++i, position += increment) {
//         float height = length(position);
//         vec3 density = calculateAtmosphereDensity(height, dot(position, rayDir) / height);
//         if(density.y > 1e35) break;
//         vec3 airmass = stepSize * density;
//         vec3 stepOpticalDepth = ec * airmass;

//         vec3 stepTransmittance = saturate(exp(-stepOpticalDepth));
//         vec3 stepTransmittedFraction = saturate((stepTransmittance - 1.0) / -stepOpticalDepth);
//         vec3 visibleScattering = transmittance * stepTransmittedFraction;

//         mat3x3 scatteringViewStep;
//         scatteringViewStep[0] = sc * vec2(airmass.xy * phase);
//         scatteringViewStep[0] *= visibleScattering;

//         scattering += scatteringViewStep[0] * calculateAtmosphereTransmittance(sunDirection, position, ec);

//         //scatteredMulti += multipleScattering(SCATTERING_STEPS, i, sunDirection, rayDir, visibleScattering, airmass, position, sc, ec);

//         transmittance *= stepTransmittance;
//         opticalDepth += stepOpticalDepth;
//     }



//     return vec3(rayLength);
// }

vec3 skyColor(vec3 viewDir, vec3 sunDir, float altitude, mat3 modelViewInverse) {

    vec3 eyeDir = modelViewInverse * viewDir;
    vec3 eyeOrigin = vec3(0.0, earthRadius + 5.0 * (altitude-seaLevel), 0.0);
    vec3 eyeSunDir = modelViewInverse * sunDir;

    float tmin = 0.0;
    float tmax = intersectFromInside(eyeOrigin, eyeDir, vec3(0.0), atmosphereRadius);
    float tmaxPlanet = intersectFromOutside(eyeOrigin, eyeDir, vec3(0.0), earthRadius);
    if(tmaxPlanet > -0.5)
        tmax = min(tmax, tmaxPlanet);

    float tCurrent = tmin;
    float segmentLength = (tmax - tmin) / skySamples; 

    vec3 sumR = vec3(0.0);
    vec3 sumM = vec3(0.0);
    float opticalDepthR = 0;
    float opticalDepthM = 0; 

    float mu = dot(eyeDir, eyeSunDir);
    float phaseR = 3.0 / (16.0 * PI) * (1 + mu * mu);
    float phaseM = 3.0 / (8.0 * PI) * ((1.0 - meanCosine * meanCosine) * (1.0 + mu * mu)) / ((2.0 + meanCosine * meanCosine) * pow(1.0 + meanCosine * meanCosine - 2.0 * meanCosine * mu, 1.5));

    for(int i = 0; i < skySamples; ++i) {
        vec3 samplePosition = eyeOrigin + (tCurrent + segmentLength*0.5) * eyeDir;
        float height = length(samplePosition) - earthRadius;

        float hr = exp(-height / rayleighScaleHeight) * segmentLength;
        float hm = exp(-height / mieScaleHeight) * segmentLength;
        opticalDepthR += hr;
        opticalDepthM += hm;

        float t1Light = intersectFromInside(samplePosition, eyeSunDir, vec3(0.0), atmosphereRadius);

        float segmentLengthLight = t1Light / lightSamples;
        float tCurrentLight = 0;
        float opticalDepthLightR = 0;
        float opticalDepthLightM = 0; 

        int j = 0;
        for (j = 0; j < lightSamples; ++j) { 
            vec3 samplePositionLight = samplePosition + (tCurrentLight + segmentLengthLight * 0.5f) * eyeSunDir; 
            float heightLight = length(samplePositionLight) - earthRadius;

            if (heightLight < 0) break;

            opticalDepthLightR += exp(-heightLight / rayleighScaleHeight) * segmentLengthLight; 
            opticalDepthLightM += exp(-heightLight / mieScaleHeight) * segmentLengthLight; 
            tCurrentLight += segmentLengthLight; 
        }

        if (j == lightSamples) { 
            vec3 tau = rayleighScatter * (opticalDepthR + opticalDepthLightR) + mieScatter * 1.1 * (opticalDepthM + opticalDepthLightM); 
            vec3 attenuation = exp(-tau);
            sumR += attenuation * hr; 
            sumM += attenuation * hm; 
        } 
        tCurrent += segmentLength; 
    }
 

    float sunDisk = smoothstep(0.9985, 0.999, dot(viewDir, sunDir)) * float(tmax != tmaxPlanet);

    // We use a magic number here for the intensity of the sun (20). We will make it more
    // scientific in a future revision of this lesson/code
    vec3 result = (sumR * rayleighScatter * phaseR + sumM * mieScatter * phaseM) * mix(20, 100, sunDisk);

    // const float gamma = 2.2;
    // result = pow(result, vec3(gamma));
    // result = sRGBToLinear(vec4(result, 1.0)).rgb;

    // reinhard tone mapping
    result = vec3(1.0) - exp(-result * 0.4);
    // gamma correction 
    // result = pow(result, vec3(1.0 / gamma));
    result = linearToSRGB(vec4(result, 1.0)).rgb;

    // result.r = result.r < 1.413 ? pow(result.r * 0.38317, 1.0 / gamma) : 1.0 - exp(-result.r); 
    // result.g = result.g < 1.413 ? pow(result.g * 0.38317, 1.0 / gamma) : 1.0 - exp(-result.g); 
    // result.b = result.b < 1.413 ? pow(result.b * 0.38317, 1.0 / gamma) : 1.0 - exp(-result.b); 

    return result;
}
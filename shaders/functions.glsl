#define PI 3.141592654
#define goldenRatioConjugate 0.61803398875

/*
const int colortex0Format = RGBA16F;
const int colortex0ClearColor = vec4(0.0, 0.0, 0.0, 0.0);
const int colortex1Format = RGBA16;
const int colortex14Format = R8;
const int colortex15Format = R16F;
const bool colortex15Clear = false;
const bool colortex0MipmapEnabled = true;
*/
const int shadowMapResolution = 2048;
const float sunPathRotation = -20;
const float shadowDistance = 120;

#define Shadow_Distort_Factor 0.1
#define Shadow_Bias 0.00005

uniform mat4 gbufferProjection;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float near;
uniform float far;

// https://www.titanwolf.org/Network/q/bb468365-7407-4d26-8441-730aaf8582b5/x
vec4 linearToSRGB(vec4 linear) {
    vec4 higher = (pow(abs(linear), vec4(1.0 / 2.4)) * 1.055) - 0.055;
    vec4 lower  = linear * 12.92;
    return mix(higher, lower, step(linear, vec4(0.0031308)));

    // return pow(linear, vec4(1.0 / 2.2));
}

vec4 sRGBToLinear(vec4 sRGB) {
    vec4 higher = pow((sRGB + 0.055) / 1.055, vec4(2.4));
    vec4 lower  = sRGB / 12.92;
    return mix(higher, lower, step(sRGB, vec4(0.04045)));

    // return pow(sRGB, vec4(2.2));
}

float linearizeDepthFast(float depth) {
    return (near * far) / (depth * (near - far) + far);
}

float linearizeDepthNorm(float depth) {
  return (linearizeDepthFast(depth) - near) / (far - near);
}

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
  vec4 homoPos = projectionMatrix * vec4(position, 1.0);
  return homoPos.xyz / homoPos.w;
}

vec2 GetVogelDiskSample(int sampleIndex, int sampleCount, float phi) 
{
    const float goldenAngle = 2.399963;
    float sampleIndexF = float(sampleIndex);
    float sampleCountF = float(sampleCount);
    
    float r = sqrt(sampleIndexF + 0.5) / sqrt(sampleCountF);
    float theta = sampleIndexF * goldenAngle + phi;
    
    float sine = sin(theta);
    float cosine = cos(theta);
    
    return vec2(cosine, sine) * r;
}

float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}

float getDistortFactor(vec2 v) {
	return cubeLength(v) + Shadow_Distort_Factor;
}

vec3 distort(vec3 v, float factor) {
	return vec3(v.xy / factor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v.xy));
}

vec3 calcViewPos(vec3 viewVector, float depth) {
	float viewZ = -gbufferProjection[3][2] / ((depth * 2.0 - 1.0) + gbufferProjection[2][2]);
	return viewVector * viewZ;
}

vec3 screenToView(vec2 texcoord, float depth, mat4 projectionInverse) {
    vec4 clipPos = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos = projectionInverse * clipPos;
    return viewPos.xyz / viewPos.w;
}

vec3 viewToScreen(vec3 viewPos, mat4 projectionMatrix) {
  return projectAndDivide(projectionMatrix, viewPos) * 0.5 + 0.5;
}

vec3 shadowVisibility(vec3 shadowPos, sampler2D shadowtex0, sampler2D shadowtex1, sampler2D shadowcolor0) {
    vec4 shadowColor = texture2D(shadowcolor0, shadowPos.xy);
    shadowColor.rgb = shadowColor.rgb * (1.0 - shadowColor.a);
    float visibility0 = step(shadowPos.z, texture2D(shadowtex0, shadowPos.xy).r);
    float visibility1 = step(shadowPos.z, texture2D(shadowtex1, shadowPos.xy).r);
    return mix(shadowColor.rgb * visibility1, vec3(1.0f), visibility0);
}

vec3 calcShadowPos(vec3 viewPos, mat4 modelViewInverse) {
  vec4 playerPos = modelViewInverse * vec4(viewPos, 1.0);
  vec3 shadowPos = (shadowProjection * (shadowModelView * playerPos)).xyz;
  float distortFactor = getDistortFactor(shadowPos.xy);
  shadowPos.xyz = distort(shadowPos.xyz, distortFactor); //apply shadow distortion
  return shadowPos.xyz * 0.5 + 0.5; //convert from -1 ~ +1 to 0 ~ 1
}

void applyShadowBias(inout vec3 shadowPos, float NGdotL) {
  shadowPos.z -= Shadow_Bias / abs(NGdotL);
}

vec3 extractNormalZ(vec2 normal) {
    return vec3(normal, sqrt(1.0 - dot(normal.xy, normal.xy)));
}

/*
    Normals encoding and decoding based on Spectrum by Zombye, a orthogonal approach
*/
vec2 NormalEncode(vec3 normal) {
    normal.xy /= abs(normal.x) + abs(normal.y) + abs(normal.z);
    return (normal.z <= 0.0 ? (1.0 - abs(normal.yx)) * vec2(normal.x >= 0.0 ? 1.0 : -1.0, normal.y >= 0.0 ? 1.0 : -1.0) : normal.xy) * 0.5 + 0.5;
}
vec3 NormalDecode(vec2 encodedNormal) {
    encodedNormal = encodedNormal * 2.0 - 1.0;
	vec3 normal = vec3(encodedNormal, 1.0 - abs(encodedNormal.x) - abs(encodedNormal.y));
	float t = max(-normal.z, 0.0);
	normal.xy += vec2(normal.x >= 0.0 ? -t : t, normal.y >= 0.0 ? -t : t);
	return normalize(normal);
}

// vec2 OctWrap( vec2 v )
// {
//     return ( 1.0 - abs( v.yx ) ) * vec2( v.x >= 0.0 ? 1.0 : -1.0, v.y >= 0.0 ? 1.0 : -1.0 );
// }
 
// vec2 NormalEncode( vec3 n )
// {
//     n.xy /= (abs(n.x) + abs(n.y) + abs(n.z));
//     n.xy = n.z >= 0.0 ? n.xy : OctWrap( n.xy );
//     n.xy = n.xy * 0.5 + 0.5;
//     return n.xy;
// }
 
// vec3 NormalDecode( vec2 f )
// {
//     f = f * 2.0 - 1.0;
 
//     // https://twitter.com/Stubbesaurus/status/937994790553227264
//     vec3 n = vec3( f.x, f.y, 1.0 - abs( f.x ) - abs( f.y ) );
//     float t = clamp( -n.z, 0.0, 1.0);
//     n.xy += vec2(n.x >= 0.0  ? -t : t, n.y >= 0.0  ? -t : t);
//     return normalize( n );
// }

float dayTimeFactor(int time) {
    float adjustedTime = mod(time + 785.0, 24000.0);

    if(adjustedTime > 13570.0)
        return sin((adjustedTime - 3140.0) * PI / 10430.0);

    return sin(adjustedTime * PI / 13570.0);
}

vec3 skyLightColor(int time, float rainStrength) {
    float timeFactor = dayTimeFactor(time);
    vec3 night = mix(vec3(0.08, 0.08, 0.14), vec3(0.08), rainStrength);
    vec3 day = mix(mix(vec3(1.0, 0.6, 0.4), vec3(0.9, 0.87, 0.85), clamp(5.0 * (timeFactor - 0.2), 0.0, 1.0)), vec3(0.3), rainStrength);
	return mix(night, day, clamp(2.0 * (timeFactor + 0.4), 0.0, 1.0));
}

// vec3 skyLightColor(int time, float rainStrength) {
// 	float a = 0.204068920917;
// 	float b = 0.4;
// 	float factor = (abs(sin(PI/12000 * time) + a) + b) / (1 + a + b);

// 	return vec3(factor * (1.0 - 0.3 * rainStrength));
// }


// simplex noise, from here: https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+10.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}



//
//	FAST32_hash
//	A very fast hashing function.  Requires 32bit support.
//	http://briansharpe.wordpress.com/2011/11/15/a-fast-and-simple-32bit-floating-point-hash-function/
//
//	The 2D hash formula takes the form....
//	hash = mod( coord.x * coord.x * coord.y * coord.y, SOMELARGEFLOAT ) / SOMELARGEFLOAT
//	We truncate and offset the domain to the most interesting part of the noise.
//	SOMELARGEFLOAT should be in the range of 400.0->1000.0 and needs to be hand picked.  Only some give good results.
//	A 3D hash is achieved by offsetting the SOMELARGEFLOAT value by the Z coordinate
//
vec4 FAST32_hash_2D( vec2 gridcell )	//	generates a random number for each of the 4 cell corners
{
    //	gridcell is assumed to be an integer coordinate
    const vec2 OFFSET = vec2( 26.0, 161.0 );
    const float DOMAIN = 71.0;
    const float SOMELARGEFLOAT = 951.135664;
    vec4 P = vec4( gridcell.xy, gridcell.xy + 1.0 );
    P = P - floor(P * ( 1.0 / DOMAIN )) * DOMAIN;	//	truncate the domain
    P += OFFSET.xyxy;								//	offset to interesting part of the noise
    P *= P;											//	calculate and return the hash
    return fract( P.xzxz * P.yyww * ( 1.0 / SOMELARGEFLOAT ) );
}
void FAST32_hash_2D( vec2 gridcell, out vec4 hash_0, out vec4 hash_1 )	//	generates 2 random numbers for each of the 4 cell corners
{
    //    gridcell is assumed to be an integer coordinate
    const vec2 OFFSET = vec2( 26.0, 161.0 );
    const float DOMAIN = 71.0;
    const vec2 SOMELARGEFLOATS = vec2( 951.135664, 642.949883 );
    vec4 P = vec4( gridcell.xy, gridcell.xy + 1.0 );
    P = P - floor(P * ( 1.0 / DOMAIN )) * DOMAIN;
    P += OFFSET.xyxy;
    P *= P;
    P = P.xzxz * P.yyww;
    hash_0 = fract( P * ( 1.0 / SOMELARGEFLOATS.x ) );
    hash_1 = fract( P * ( 1.0 / SOMELARGEFLOATS.y ) );
}
void FAST32_hash_2D( 	vec2 gridcell,
                        out vec4 hash_0,
                        out vec4 hash_1,
                        out vec4 hash_2	)	//	generates 3 random numbers for each of the 4 cell corners
{
    //    gridcell is assumed to be an integer coordinate
    const vec2 OFFSET = vec2( 26.0, 161.0 );
    const float DOMAIN = 71.0;
    const vec3 SOMELARGEFLOATS = vec3( 951.135664, 642.949883, 803.202459 );
    vec4 P = vec4( gridcell.xy, gridcell.xy + 1.0 );
    P = P - floor(P * ( 1.0 / DOMAIN )) * DOMAIN;
    P += OFFSET.xyxy;
    P *= P;
    P = P.xzxz * P.yyww;
    hash_0 = fract( P * ( 1.0 / SOMELARGEFLOATS.x ) );
    hash_1 = fract( P * ( 1.0 / SOMELARGEFLOATS.y ) );
    hash_2 = fract( P * ( 1.0 / SOMELARGEFLOATS.z ) );
}
vec4 FAST32_hash_2D_Cell( vec2 gridcell )	//	generates 4 different random numbers for the single given cell point
{
    //	gridcell is assumed to be an integer coordinate
    const vec2 OFFSET = vec2( 26.0, 161.0 );
    const float DOMAIN = 71.0;
    const vec4 SOMELARGEFLOATS = vec4( 951.135664, 642.949883, 803.202459, 986.973274 );
    vec2 P = gridcell - floor(gridcell * ( 1.0 / DOMAIN )) * DOMAIN;
    P += OFFSET.xy;
    P *= P;
    return fract( (P.x * P.y) * ( 1.0 / SOMELARGEFLOATS.xyzw ) );
}

//
//	SimplexPerlin2D_Deriv
//	SimplexPerlin2D noise with derivatives
//	returns vec3( value, xderiv, yderiv )
//
vec3 SimplexPerlin2D_Deriv( vec2 P )
{
    //	simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;			// 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;			// (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;	// sqrt( 0.5 )	height of simplex triangle
    const vec3 SIMPLEX_POINTS = vec3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );		//	vertex info for simplex triangle

    //	establish our grid cell.
    P *= SIMPLEX_TRI_HEIGHT;		// scale space so we can have an approx feature size of 1.0  ( optional )
    vec2 Pi = floor( P + dot( P, vec2( SKEWFACTOR ) ) );

    //	calculate the hash.
    //	( various hashing methods listed in order of speed )
    vec4 hash_x, hash_y;
    FAST32_hash_2D( Pi, hash_x, hash_y );
    //SGPP_hash_2D( Pi, hash_x, hash_y );

    //	establish vectors to the 3 corners of our simplex triangle
    vec2 v0 = Pi - dot( Pi, vec2( UNSKEWFACTOR ) ) - P;
    vec4 v1pos_v1hash = (v0.x < v0.y) ? vec4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : vec4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    vec4 v12 = vec4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //	calculate the dotproduct of our 3 corner vectors with 3 random normalized vectors
    vec3 grad_x = vec3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    vec3 grad_y = vec3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    vec3 norm = inversesqrt( grad_x * grad_x + grad_y * grad_y );
    grad_x *= norm;
    grad_y *= norm;
    vec3 grad_results = grad_x * vec3( v0.x, v12.xz ) + grad_y * vec3( v0.y, v12.yw );

    //	evaluate the surflet
    vec3 m = vec3( v0.x, v12.xz ) * vec3( v0.x, v12.xz ) + vec3( v0.y, v12.yw ) * vec3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);		//	The 0.5 here is SIMPLEX_TRI_HEIGHT^2
    vec3 m2 = m*m;
    vec3 m4 = m2*m2;

    //	calc the deriv
    vec3 temp = 8.0 * m2 * m * grad_results;
    float xderiv = dot( temp, vec3( v0.x, v12.xz ) ) - dot( m4, grad_x );
    float yderiv = dot( temp, vec3( v0.y, v12.yw ) ) - dot( m4, grad_y );

    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;	//	scales the final result to a strict 1.0->-1.0 range

    //	sum the surflets and return all results combined in a vec3
    return vec3( dot( m4, grad_results ), xderiv, yderiv ) * FINAL_NORMALIZATION;
}

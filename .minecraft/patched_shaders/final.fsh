#version 150 core
#define gl_FragData iris_FragData
#define varying in
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix mat4(1.0)
#define gl_NormalMatrix mat3(1.0)
#define gl_Color vec4(1.0, 1.0, 1.0, 1.0)
#define gl_ProjectionMatrix mat4(1.0)
#define gl_FogFragCoord iris_FogFragCoord
uniform float iris_FogDensity;
uniform float iris_FogStart;
uniform float iris_FogEnd;
uniform vec4 iris_FogColor;

struct iris_FogParameters {
    vec4 color;
    float density;
    float start;
    float end;
    float scale;
};

iris_FogParameters iris_Fog = iris_FogParameters(iris_FogColor, iris_FogDensity, iris_FogStart, iris_FogEnd, 1.0 / (iris_FogEnd - iris_FogStart));

#define gl_Fog iris_Fog
in float iris_FogFragCoord;
out vec4 iris_FragData[8];
vec4 texture2D(sampler2D sampler, vec2 coord) { return texture(sampler, coord); }
vec4 texture2D(sampler2D sampler, vec2 coord, float bias) { return texture(sampler, coord, bias); }
vec4 texture2DLod(sampler2D sampler, vec2 coord, float lod) { return textureLod(sampler, coord, lod); }
vec4 shadow2D(sampler2DShadow sampler, vec3 coord) { return vec4(texture(sampler, coord)); }
vec4 shadow2DLod(sampler2DShadow sampler, vec3 coord, float lod) { return vec4(textureLod(sampler, coord, lod)); }
#define MC_RENDER_QUALITY 1.0
#define MC_SHADOW_QUALITY 1.0

	#define Global
	#define fsh


#ifdef fsh
	#ifdef Global
		/* #### Adjustable Variables #### */

			// #define lensMonochrome
				#define lMonoRed 255 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoGreen 105 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoBlue 205 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoAlpha 0.75 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

		/* #### Variables #### */

			uniform sampler2D gcolor;

			varying vec2 texcoord;

		/* #### Functions #### */

		/* #### Includes #### */


// Some parts taken from BSL with Tatsu's permission

#define TONEMAP 1 //[1 2 3 4 5 6]

#define TonemapExposure 1.2 //[1.0 1.2 1.4 2.0 2.8 4.0 5.6 8.0 11.3 16.0]
#define TonemapWhiteCurve 2.0 //[1.0 1.5 2.0 2.5 3.0 3.5 4.0]
#define TonemapLowerCurve 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define TonemapUpperCurve 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define BSLSaturation 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define BSLVibrance 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

#define SWIZZLE rgb //Channel mixing [rgb rbg grb gbr brg bgr rrb rrg rgg rbb ggb ggr grr gbb bbg bbr brr bgg]


vec3 BetterColors(in vec3 color) {
	vec3 BetterColoredImage;

	vec3 overExposed = color * 1.0;

	vec3 underExposed = color / 1.0;

	BetterColoredImage = mix(underExposed, overExposed, color);


	return BetterColoredImage;
}

#if TONEMAP == 2
	vec3 BOTWTonemap(vec3 color){
		color = pow(color, vec3(1.0 / 1.2));

		float avg = (color.r + color.g + color.b) * 0.2;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 1.0 + w * 0.18;

		return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 3
	vec3 BWTonemap(vec3 color){
	
	float avg = (color.r + color.g + color.b) * 0.2;
	float maxc = max(color.r, max(color.g, color.b));

	float w = 1.0 - pow(1.0 - 1.0 * avg, 0.0);
	float weight = 0.0 + w;

	return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 4
	vec3 NegativeTonemap(vec3 color){
		color = pow(color, vec3(BetterColors(color) * 5.0));

		float avg = (color.r + color.g + color.b) * 0.2;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 1.0 + w;

		return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 5
	vec3 SpoopyTonemap(vec3 color){

		float avg = (color.r + color.g + color.b) / 5.0;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 0.0 + w;

		return mix(vec3(maxc), color * 0.0, weight);
	}
#elif TONEMAP == 6
	vec3 BSLTonemap(vec3 x){
		x = TonemapExposure * x;
		x = x / pow(pow(x,vec3(TonemapWhiteCurve)) + 1.0,vec3(1.0/TonemapWhiteCurve));
		x = pow(x,mix(vec3(TonemapLowerCurve),vec3(TonemapUpperCurve),sqrt(x)));
		return x;
	}

	vec3 colorSaturation(vec3 x){
		float grayv = (x.r + x.g + x.b) * 0.333;
		float grays = grayv;
		if (BSLSaturation < 1.0) grays = dot(x,vec3(0.299, 0.587, 0.114));

		float mn = min(x.r, min(x.g, x.b));
		float mx = max(x.r, max(x.g, x.b));
		float sat = (1.0-(mx-mn)) * (1.0-mx) * grayv * 5.0;
		vec3 lightness = vec3((mn+mx)*0.5);

		x = mix(x,mix(x,lightness,1.0-BSLVibrance),sat);
		x = mix(x, lightness, (1.0-lightness)*(2.0-BSLVibrance)/2.0*abs(BSLVibrance-1.0));

		return x * BSLSaturation - grays * (BSLSaturation - 1.0);
	}
#endif

		/* #### VoidMain #### */

		void main() {
			vec3 color = texture2D(gcolor, texcoord).rgb;

			// Tonemapping 

			#if TONEMAP == 2
				color.rgb = BOTWTonemap(color.rgb);
			#elif TONEMAP == 3
				color.rgb = BWTonemap(color.rgb);
			#elif TONEMAP == 4
				color.rgb = NegativeTonemap(color.rgb);
			#elif TONEMAP == 5
				color.rgb = SpoopyTonemap(color.rgb);
			#elif TONEMAP == 6
				color.rgb = BSLTonemap(color.rgb);
				color.rgb = colorSaturation(color.rgb);
			#else
				color.rgb = BetterColors(color.rgb);
				color.rgb = color.SWIZZLE;
			#endif

			#ifdef lensMonochrome
				float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114)); // or (color.r + color.g + color.b) / 3
				vec3 tint = vec3(lMonoRed, lMonoGreen, lMonoBlue) / 255; // or vec3(1.0) - vec3(red, green, blue), idk how you want it
				color.rgb = mix(color.rgb, vec3(brightness * tint.r, brightness * tint.g, brightness * tint.b), lMonoAlpha);
			#endif

			/* DRAWBUFFERS:0 */
			gl_FragData[0] = vec4(color, 1.0); //gcolor
		}
	#endif


	#ifdef Nether
		/* #### Adjustable Variables #### */

			//#define lensMonochrome
				#define lMonoRed 255 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoGreen 105 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoBlue 205 //[0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0 85.0 90.0 95.0 100.0 105.0 110.0 115.0 120.0 125.0 130.0 135.0 140.0 145.0 150.0 155.0 160.0 165.0 170.0 175.0 180.0 185.0 190.0 195.0 200.0 205.0 210.0 215.0 220.0 225.0 230.0 235.0 240.0 245.0 250.0 255.0]
				#define lMonoAlpha 0.75 //[0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]

			#define NETHER_REFRACTION
				#define NETHER_REFRACTION_AMOUNT 0.25 ///[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]
				#define NETHER_REFRACTION_ANIMATION_SPEED 0.75 //[0.0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]

		/* #### Variables #### */

			uniform sampler2D colortex0;

			varying vec2 texcoord;

			#ifdef NETHER_REFRACTION
				uniform float frameTimeCounter;

				uniform float aspectRatio;
			#endif
		/* #### Functions #### */

			#ifdef NETHER_REFRACTION
				vec2 NetherRefraction(in vec2 coord) {
					vec2 refraction = vec2(sin(frameTimeCounter * 1.75 * NETHER_REFRACTION_ANIMATION_SPEED + texcoord.x * 50.0 + texcoord.y * 25.0), cos(frameTimeCounter * 2.5 * NETHER_REFRACTION_ANIMATION_SPEED + texcoord.y * 100.0 + texcoord.x * 25.0));
					return coord + refraction * 0.002 * NETHER_REFRACTION_AMOUNT;
					return coord;
				}
			#endif

		/* #### Includes #### */


// Some parts taken from BSL with Tatsu's permission

#define TONEMAP 1 //[1 2 3 4 5 6]

#define TonemapExposure 1.2 //[1.0 1.2 1.4 2.0 2.8 4.0 5.6 8.0 11.3 16.0]
#define TonemapWhiteCurve 2.0 //[1.0 1.5 2.0 2.5 3.0 3.5 4.0]
#define TonemapLowerCurve 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]
#define TonemapUpperCurve 1.0 //[0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5]

#define BSLSaturation 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define BSLVibrance 1.00 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

#define SWIZZLE rgb //Channel mixing [rgb rbg grb gbr brg bgr rrb rrg rgg rbb ggb ggr grr gbb bbg bbr brr bgg]


vec3 BetterColors(in vec3 color) {
	vec3 BetterColoredImage;

	vec3 overExposed = color * 1.0;

	vec3 underExposed = color / 1.0;

	BetterColoredImage = mix(underExposed, overExposed, color);


	return BetterColoredImage;
}

#if TONEMAP == 2
	vec3 BOTWTonemap(vec3 color){
		color = pow(color, vec3(1.0 / 1.2));

		float avg = (color.r + color.g + color.b) * 0.2;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 1.0 + w * 0.18;

		return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 3
	vec3 BWTonemap(vec3 color){
	
	float avg = (color.r + color.g + color.b) * 0.2;
	float maxc = max(color.r, max(color.g, color.b));

	float w = 1.0 - pow(1.0 - 1.0 * avg, 0.0);
	float weight = 0.0 + w;

	return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 4
	vec3 NegativeTonemap(vec3 color){
		color = pow(color, vec3(BetterColors(color) * 5.0));

		float avg = (color.r + color.g + color.b) * 0.2;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 1.0 + w;

		return mix(vec3(maxc), color * 1.0, weight);
	}
#elif TONEMAP == 5
	vec3 SpoopyTonemap(vec3 color){

		float avg = (color.r + color.g + color.b) / 5.0;
		float maxc = max(color.r, max(color.g, color.b));

		float w = 1.0 - pow(1.0 - 1.0 * avg, 2.0);
		float weight = 0.0 + w;

		return mix(vec3(maxc), color * 0.0, weight);
	}
#elif TONEMAP == 6
	vec3 BSLTonemap(vec3 x){
		x = TonemapExposure * x;
		x = x / pow(pow(x,vec3(TonemapWhiteCurve)) + 1.0,vec3(1.0/TonemapWhiteCurve));
		x = pow(x,mix(vec3(TonemapLowerCurve),vec3(TonemapUpperCurve),sqrt(x)));
		return x;
	}

	vec3 colorSaturation(vec3 x){
		float grayv = (x.r + x.g + x.b) * 0.333;
		float grays = grayv;
		if (BSLSaturation < 1.0) grays = dot(x,vec3(0.299, 0.587, 0.114));

		float mn = min(x.r, min(x.g, x.b));
		float mx = max(x.r, max(x.g, x.b));
		float sat = (1.0-(mx-mn)) * (1.0-mx) * grayv * 5.0;
		vec3 lightness = vec3((mn+mx)*0.5);

		x = mix(x,mix(x,lightness,1.0-BSLVibrance),sat);
		x = mix(x, lightness, (1.0-lightness)*(2.0-BSLVibrance)/2.0*abs(BSLVibrance-1.0));

		return x * BSLSaturation - grays * (BSLSaturation - 1.0);
	}
#endif

		/* #### VoidMain #### */

			void main() {

				vec2 coord = texcoord.st;

				#ifdef NETHER_REFRACTION
					coord = NetherRefraction(coord);
				#endif

				vec4 color = vec4(texture2D(colortex0, coord).rgb, 1.0); //always use the "refracted" coord instead of texcoord after the refraction

				// Tonemapping 

				#if TONEMAP == 2
					color.rgb = BOTWTonemap(color.rgb);
				#elif TONEMAP == 3
					color.rgb = BWTonemap(color.rgb);
				#elif TONEMAP == 4
					color.rgb = NegativeTonemap(color.rgb);
				#elif TONEMAP == 5
					color.rgb = SpoopyTonemap(color.rgb);
				#elif TONEMAP == 6
					color.rgb = BSLTonemap(color.rgb);
					color.rgb = colorSaturation(color.rgb);
				#else
					color.rgb = BetterColors(color.rgb);
					color.rgb = color.SWIZZLE;
				#endif

				#ifdef lensMonochrome
					float brightness = dot(color.rgb, vec3(0.299, 0.587, 0.114)); // or (color.r + color.g + color.b) / 3
					vec3 tint = vec3(lMonoRed, lMonoGreen, lMonoBlue) / 255; // or vec3(1.0) - vec3(red, green, blue), idk how you want it
					color.rgb = mix(color.rgb, vec3(brightness * tint.r, brightness * tint.g, brightness * tint.b), lMonoAlpha);
				#endif
				
				gl_FragData[0] = vec4(color);
			}
	#endif
#endif


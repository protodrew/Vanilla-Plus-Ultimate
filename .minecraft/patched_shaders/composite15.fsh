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

		#define nightEye
			#define ndeSat 15.0 //[30.0 29.0 28.0 27.0 26.0 25.0 24.0 23.0 22.0 21.0 20.0 19.0 18.0 17.0 16.0 15.0 14.0 13.0 12.0 11.0 10.0 9.0 8.0 7.0 6.0 5.0 4.0 3.0 2.0 1.0]

		#define UNDERWATER_REFRACTION
			#define UNDERWATER_REFRACTION_AMOUNT 0.5 //[0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]
			#define UNDERWATER_REFRACTION_ANIMATION_SPEED 1.0 //[0.0 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]

		/* #### Variables #### */

			uniform sampler2D colortex0;
			uniform sampler2D depthtex0;

			uniform float frameTimeCounter;

			varying vec2 texcoord;

			uniform int isEyeInWater;
		/* #### Functions #### */

		#ifdef nightEye
			void getNightDesaturation(inout vec3 color) {
				float weight = ndeSat;

				color = pow(color, vec3(2.2)); // convert from gamma to linear

				float brightness = dot(color, vec3(0.2627, 0.6780, 0.0593));
				float amount = 0.01 / (pow(brightness * weight, 2.0) + 0.01);
				vec3 desatColor = mix(color, vec3(brightness), vec3(0.9)) * vec3(0.2, 1.0, 2.0);

				color = mix(color, desatColor, amount);

				color = pow(color, vec3(1.0 / 2.2)); // convert from linear to gamma
			}
		#endif

		#ifdef UNDERWATER_REFRACTION
			vec2 UnderwaterRefraction(in vec2 coord) {
				if(isEyeInWater == 1) {
					vec2 refraction = vec2(sin(frameTimeCounter * 1.75 * UNDERWATER_REFRACTION_ANIMATION_SPEED + texcoord.x * 50.0 + texcoord.y * 25.0), cos(frameTimeCounter * 2.5 * UNDERWATER_REFRACTION_ANIMATION_SPEED + texcoord.y * 100.0 + texcoord.x * 25.0));
					return coord + refraction * 0.002 * UNDERWATER_REFRACTION_AMOUNT;
				}
				return coord;
			}
		#endif

		/* #### Includes #### */

//#define FGrain	
	#define FGStrength 0.035

float depth0 = texture2D(depthtex0, texcoord).x;

#ifdef FGrain
	float randFilmGrain(in vec2 refcoord) { //just a noise function, calculates noise based on the given coord
		return fract(sin(dot(refcoord.st, vec2(12.9898, 78.233))) * 43758.5453); 
	}


	void FilmGrain(inout vec3 color) {
		if	(depth0 < 1.0) {
		float brightness = dot(color.rgb, vec3(0.2627, 0.6780, 0.0593)); //gets brightness of screen
		float strength = FGStrength * (1.0 - brightness * 1.9); //applies brightness to strength
		
		if (strength >= 0) {
			vec2 refcoord = texcoord.st + frameTimeCounter * 0.01; //makes the texcoord move over time because the offset is frameTimeCounter which changes after every frame multiplied with 0.01 to make it slower than it is by default
			color += vec3(randFilmGrain(refcoord + 0.1), randFilmGrain(refcoord), randFilmGrain(refcoord - 0.1)) * strength; //use the moving texcoord to make the whole noise move and use offsets for the red and blue channel to make the noise colored, without the offset red, green and blue would overlap each other and the noise would be white/gray
		} else {
			color = color;
		}
		}
	}
#endif

		/* #### VoidMain #### */

		void main() {
			vec2 coord = texcoord.st;

			#ifdef UNDERWATER_REFRACTION
				coord = UnderwaterRefraction(coord);
			#endif

			vec4 color = vec4(texture2D(colortex0, coord).rgb, 1.0);
			
			#ifdef FGrain
				FilmGrain(color.rgb);
			#endif

			#ifdef nightEye
				getNightDesaturation(color.rgb);
			#endif
			
			gl_FragData[0] = color;
		}
	#endif


	#ifdef Nether
		/* #### Adjustable Variables #### */

			#define nightEye
				#define ndeSat 15.0 //[30.0 29.0 28.0 27.0 26.0 25.0 24.0 23.0 22.0 21.0 20.0 19.0 18.0 17.0 16.0 15.0 14.0 13.0 12.0 11.0 10.0 9.0 8.0 7.0 6.0 5.0 4.0 3.0 2.0 1.0]

		/* #### Variables #### */

			uniform sampler2D colortex0;
			uniform sampler2D depthtex0;

			uniform float frameTimeCounter;

			varying vec2 texcoord;

		/* #### Functions #### */

		#ifdef nightEye
			void getNightDesaturation(inout vec3 color) {
				float weight = ndeSat;

				color.rgb = pow(color.rgb, vec3(2.2)); // convert from gamma to linear

				float brightness = dot(color.rgb, vec3(0.2627, 0.6780, 0.0593));
				float amount = 0.01 / (pow(brightness * weight, 2.0) + 0.01);
				vec3 desatColor = mix(color, vec3(brightness), vec3(0.9)) * vec3(0.2, 1.0, 2.0);

				color = mix(color, desatColor, amount);

				color.rgb = pow(color.rgb, vec3(1.0 / 2.2)); // convert from linear to gamma
			}
		#endif

		/* #### Includes #### */

//#define FGrain	
	#define FGStrength 0.035

float depth0 = texture2D(depthtex0, texcoord).x;

#ifdef FGrain
	float randFilmGrain(in vec2 refcoord) { //just a noise function, calculates noise based on the given coord
		return fract(sin(dot(refcoord.st, vec2(12.9898, 78.233))) * 43758.5453); 
	}


	void FilmGrain(inout vec3 color) {
		if	(depth0 < 1.0) {
		float brightness = dot(color.rgb, vec3(0.2627, 0.6780, 0.0593)); //gets brightness of screen
		float strength = FGStrength * (1.0 - brightness * 1.9); //applies brightness to strength
		
		if (strength >= 0) {
			vec2 refcoord = texcoord.st + frameTimeCounter * 0.01; //makes the texcoord move over time because the offset is frameTimeCounter which changes after every frame multiplied with 0.01 to make it slower than it is by default
			color += vec3(randFilmGrain(refcoord + 0.1), randFilmGrain(refcoord), randFilmGrain(refcoord - 0.1)) * strength; //use the moving texcoord to make the whole noise move and use offsets for the red and blue channel to make the noise colored, without the offset red, green and blue would overlap each other and the noise would be white/gray
		} else {
			color = color;
		}
		}
	}
#endif

		/* #### VoidMain #### */

		void main() {

			vec4 color = vec4(texture2D(colortex0, texcoord).rgb, 1.0);

			#ifdef FGrain
				FilmGrain(color.rgb);
			#endif

			#ifdef nightEye
				getNightDesaturation(color.rgb);
			#endif

			gl_FragData[0] = color;
		}
	#endif
#endif


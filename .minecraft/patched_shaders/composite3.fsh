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
		//#define MOTION_BLUR
		#define MOTION_BLUR_NOISE
		#define MOTION_BLUR_STRENGTH 3.0 //[0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.25 2.5 2.75 3.0]

		uniform sampler2D colortex0;
		varying vec4 texcoord;

		#ifdef MOTION_BLUR
			uniform mat4 gbufferProjectionInverse;
			uniform mat4 gbufferPreviousProjection;
			uniform mat4 gbufferModelViewInverse;
			uniform mat4 gbufferPreviousModelView;

			uniform vec3 cameraPosition;
			uniform vec3 previousCameraPosition;

			uniform float frameTime;
			uniform sampler2D depthtex0;


			vec4 getCameraPosition(in vec2 coord) {
				float depth = texture2D(depthtex0, texcoord.st).x;
				vec4 positionNdcSpace = vec4(coord.s * 2.0 - 1.0, coord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);
				vec4 positionCameraSpace = gbufferProjectionInverse * positionNdcSpace;

				return positionCameraSpace / positionCameraSpace.w;
			}

			vec4 getWorldSpacePosition(in vec2 coord) {
				vec4 cameraPos = getCameraPosition(coord);
				vec4 worldPos = gbufferModelViewInverse * cameraPos;
				worldPos.xyz += cameraPosition;

				return worldPos;
			}

			vec4 worldSpaceToPreviousNdcSpace(in vec4 worldSpacePosition) {
				vec4 previousWorldSpacePosition = worldSpacePosition;
				previousWorldSpacePosition.xyz -= previousCameraPosition;

				vec4 previousNdcSpacePosition = gbufferPreviousModelView * previousWorldSpacePosition;
				previousNdcSpacePosition = gbufferPreviousProjection * previousNdcSpacePosition;
				previousNdcSpacePosition /= previousNdcSpacePosition.w;
				return previousNdcSpacePosition;
			}

			float rand(vec2 coord) {
				return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453);
			}

			//////////////////////////////////////////////////////////////////////////////////////////////////
			// Motion Blur implemented using: https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch27.html
			const int samples = 5;
			const float maxVel = 0.05;

			vec3 MotionBlur(in vec3 color) {
				float depth = texture2D(depthtex0, texcoord.st).x;
				if(depth < 0.56) { //hand
					return color;
				}

				//get current position in NDC space
				vec4 curPosition = vec4(texcoord.s * 2.0 - 1.0, texcoord.t * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0); 

				//get previous position in NDC space
				vec4 prevPosition = getWorldSpacePosition(texcoord.st);
				prevPosition = worldSpaceToPreviousNdcSpace(prevPosition);

				vec2 vel = clamp((curPosition - prevPosition).st * (1.0 / frameTime) * 0.003, vec2(-maxVel), vec2(maxVel));

				#ifdef MOTION_BLUR_NOISE
					float noise = rand(texcoord.st);
				#else
					float noise = 0.0;
				#endif

				vec3 col = vec3(0.0);
				int fSamples = (samples - 1) / 2;

				for (int i = -fSamples; i <= fSamples; ++i) {
					vec2 coord = texcoord.st + vel * (i + noise) / MOTION_BLUR_STRENGTH;
					col += texture2D(colortex0, coord).xyz; //or however you get your color (just use the coord)
				}

				return col /= samples;
			}
		#endif
		//////////////////////////////////////////////////////////////////////////////////////////////////

		/* DRAWBUFFERS:0 */
		//depending on your input, at least 0

		void main() {
			vec3 color = texture2D(colortex0, texcoord.st).xyz;

			#ifdef MOTION_BLUR
				color = MotionBlur(color);
			#endif

			gl_FragData[0] = vec4(color, 1.0);
		}
	#endif
#endif


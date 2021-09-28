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
		/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////ADJUSTABLE VARIABLES//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//#define CELSHADING
			#define BORDER 1.0

		/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////INTERNAL VARIABLES////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		uniform sampler2D colortex0;

		varying vec2 texcoord;
		
		#ifdef CELSHADING
			uniform sampler2D gaux1;
			uniform sampler2D depthtex0;
			uniform float near;
			uniform float far;
			uniform float viewWidth;
			uniform float viewHeight;
		#endif

		/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////FUNCTIONS/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		#ifdef CELSHADING
			vec2 newtc = texcoord.xy;


			float pw = 1.0/ viewWidth;
			float ph = 1.0/ viewHeight;

			float edepth(vec2 coord) {
				return texture2D(depthtex0,coord).z;
			}


			vec3 celshade(vec3 clrr, float iswater) {
				//  if (iswater < 0.9) return clrr;
						//edge detect
						float d = edepth(newtc.xy);
						float dtresh = 1/(far-near)/5000.0;
						vec4 dc = vec4(d,d,d,d);
						vec4 sa;
						vec4 sb;
						sa.x = edepth(newtc.xy + vec2(-pw,-ph)*BORDER);
						sa.y = edepth(newtc.xy + vec2(pw,-ph)*BORDER);
						sa.z = edepth(newtc.xy + vec2(-pw,0.0)*BORDER);
						sa.w = edepth(newtc.xy + vec2(0.0,ph)*BORDER);

						//opposite side samples
						sb.x = edepth(newtc.xy + vec2(pw,ph)*BORDER);
						sb.y = edepth(newtc.xy + vec2(-pw,ph)*BORDER);
						sb.z = edepth(newtc.xy + vec2(pw,0.0)*BORDER);
						sb.w = edepth(newtc.xy + vec2(0.0,-ph)*BORDER);

						vec4 dd = abs(2.0* dc - sa - sb) - dtresh;
						dd = vec4(step(dd.x,0.0),step(dd.y,0.0),step(dd.z,0.0),step(dd.w,0.0));

						float e = clamp(dot(dd,vec4(0.25f,0.25f,0.25f,0.25f)),0.0,1.0);
						return clrr*e;
			}
			vec3 aux = texture2D(gaux1, texcoord.st).rgb;
		#endif	
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////////////////////////////MAIN//////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		void main() {
			vec3 color = texture2D(colortex0, texcoord).rgb;


			#ifdef CELSHADING
				float iswater = float(aux.g > 0.04 && aux.g < 0.07);
				color = celshade(color, iswater);
			#endif

		/* DRAWBUFFERS:0 */
			gl_FragData[0] = vec4(color, 1.0); //colortex0
		}
	#endif
#endif


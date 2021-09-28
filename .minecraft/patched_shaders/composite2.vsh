#version 150 core
#define varying out
#define attribute in
#define gl_Vertex vec4(Position, 1.0)
#define gl_ModelViewProjectionMatrix (gl_ProjectionMatrix * gl_ModelViewMatrix)
#define gl_ModelViewMatrix mat4(1.0)
#define gl_NormalMatrix mat3(1.0)
#define gl_Normal vec3(0.0, 0.0, 1.0)
#define gl_Color vec4(1.0, 1.0, 1.0, 1.0)
#define gl_MultiTexCoord7 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord6 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord5 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord4 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord3 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord2 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord1 vec4(0.0, 0.0, 0.0, 1.0)
#define gl_MultiTexCoord0 vec4(UV0, 0.0, 1.0)
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
out float iris_FogFragCoord;
in vec2 UV0;
in vec3 Position;
vec4 ftransform() { return gl_ModelViewProjectionMatrix * gl_Vertex; }
vec4 texture2D(sampler2D sampler, vec2 coord) { return texture(sampler, coord); }
vec4 texture2DLod(sampler2D sampler, vec2 coord, float lod) { return textureLod(sampler, coord, lod); }
vec4 shadow2D(sampler2DShadow sampler, vec3 coord) { return vec4(texture(sampler, coord)); }
vec4 shadow2DLod(sampler2DShadow sampler, vec3 coord, float lod) { return vec4(textureLod(sampler, coord, lod)); }
#define MC_RENDER_QUALITY 1.0
#define MC_SHADOW_QUALITY 1.0

varying vec2 texcoord;

void main(){
	gl_Position = ftransform();

	texcoord = gl_MultiTexCoord0.xy;
}


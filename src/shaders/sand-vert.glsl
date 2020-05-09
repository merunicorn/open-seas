#version 300 es
precision highp float;

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform mat4 u_RotMat; // rotation matrix dependent on keyboard presses
uniform int u_Time;
uniform int u_Color;
uniform int u_Anim;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec3 fs_Pos;
out vec2 fs_UV;
out float fs_Time;
out float fs_FBM;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

float random1( vec3 p , vec3 seed) {
  return fract(sin(dot(p + seed, vec3(987.654, 123.456, 531.975))) * 85734.3545);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

//Smoothstep (Adam's code)
vec2 mySmoothStep(vec2 a, vec2 b, float t) {
    t = smoothstep(0.0, 1.0, t);
    return mix(a, b, t);
}

//2d Noise (Adam's code)
vec2 interpNoise2D(vec2 uv) {
    vec2 uvFract = fract(uv);
    vec2 ll = random2(floor(uv), vec2(10.0)); //need to input seeds
    vec2 lr = random2(floor(uv) + vec2(1,0), vec2(10.0));
    vec2 ul = random2(floor(uv) + vec2(0,1), vec2(10.0));
    vec2 ur = random2(floor(uv) + vec2(1,1), vec2(10.0));

    vec2 lerpXL = mySmoothStep(ll, lr, uvFract.x);
    vec2 lerpXU = mySmoothStep(ul, ur, uvFract.x);

    return mySmoothStep(lerpXL, lerpXU, uvFract.y);
}

//FBM (Adam's base code)
vec2 fbm(vec2 uv) {
    float amp = 20.0;
    float freq = 1.0;
    vec2 sum = vec2(0.0);
    float maxSum = 0.0;
    int octaves = 2; //can modify
    for(int i = 0; i < octaves; i++) {
        sum += interpNoise2D(uv * freq) * amp;
        maxSum += amp;
        amp *= 3.5;
        freq *= 12.0;
    }
    return sum / (maxSum);
}

void main() {
  //gl_Position = vs_Pos;
  fs_Pos = vs_Pos.xyz;
  fs_UV = vec2(vs_Pos.xz + u_PlanePos.xy);
  //fs_Time = float(u_Time);

  vec2 fbm_mid = fbm((fs_UV.xy / 0.03) * 5.f);
  fs_FBM = (fbm_mid.x * fbm_mid.y) * 5.0;

  vec3 coor = fs_Pos;
  vec4 modelposition = vec4(coor.x, coor.y + fs_FBM, coor.z, 1.0);
  modelposition = u_Model * modelposition;

  gl_Position = (u_ViewProj * u_RotMat) * modelposition;

  
}

#version 300 es
#define M_PI 3.1415926535897932384626433832795

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
out vec4 fs_Nor;
out vec4 fs_Col;
out vec2 fs_UV;

out float fs_Sine;
out float fs_FBM;
out float fs_Worley;
out float fs_Rock;
out float fs_guiCol;
out float fs_guiSan;
out float fs_Time;

out float fs_Peak;

vec3 h_vals = vec3(0,0,0);

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
    int octaves = 10; //can modify
    for(int i = 0; i < octaves; i++) {
        sum += interpNoise2D(uv * freq) * amp;
        maxSum += amp;
        amp *= 0.5;
        freq *= 2.0;
    }
    return sum / maxSum;
}

//Worley Noise (Adam's code)
float WorleyNoise(vec2 uv, int j)
{
    // Tile the space
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);

    float minDist = 1.0; // Minimum distance initialized to max.

    // Search all neighboring cells and this cell for their point
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));

            // Random point inside current neighboring cell
            vec2 point = random2(uvInt + neighbor, vec2(10.0));

            // Compute the distance b/t the point and the fragment
            // Store the min dist thus far
            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

// from medium
float calculateSurface(float x, float z) {
    float scale = 10.0;
    float y = 0.0;
    float t = float(u_Time) / 30.0;
    y += (sin(x * 1.0 / scale + t * 1.0) + 
          sin(x * 2.3 / scale + t * 1.5) + sin(x * 3.3 / scale + t * 0.4)) / 3.0;
    y += (sin(z * 0.2 / scale + t * 1.8) + 
          sin(z * 1.8 / scale + t * 1.8) + sin(z * 2.8 / scale + t * 0.8)) / 3.0;
    return y;
}

// from tessendorf
vec3 wavePropogation(vec3 h_vals) {
    // constants
    float g = 9.81;
    float alpha = 1.0;
    float dt = float(u_Time) / 30.0;
    //h_vals: h, vd, prev_h
    vec3 new_vals = vec3(0,0,0);
    //convolve height w kernel + put into h_vals[1]
    h_vals[1] = 1.0;
    float temp = h_vals[0];
    new_vals[0] = h_vals[0] * (2.0 - alpha*dt) / (1.0 + alpha*dt)
        - h_vals[2] / (1.0 + alpha*dt)
        - h_vals[1] * g * dt * dt / (1.0 + alpha * dt);
    new_vals[1] = h_vals[1];
    new_vals[2] = temp;
    return new_vals;
}

// gerstner wave model
vec3 gerstnerWave(vec2 x0) {
    // define number of functions
    //int n = 4;
    int n = int(random1(vec2(1.0,2.0), vec2(int(x0.x),int(x0.y))) * 2.f) + 2;

    // define wave parameter arrays
    //float A[] = float[](0.3, 0.5 / 3.0, 0.3 / 3.0, 0.45 / 3.0); // wave amplitude
    //float A[] = float[](0.4, 0.25, 0.075, 0.25); // wave amplitude

    float A[] = float[](0.3, 0.15, 0.1, 0.6); // wave amplitude

    vec2 k[] = vec2[](vec2(0.f,-1.f),vec2(0.6f,-0.5f),vec2(0.9f,0.2f),vec2(1.f,0.f)); // wave vector (horiz)
    //vec2 k[] = vec2[](vec2(0.f,-1.f),vec2(-0.5f,-0.5f),vec2(0.5f,0.9f),vec2(-0.7f,-0.1f)); // wave vector (horiz)

    //vec2 k[] = vec2[](vec2(0.f,1.f),vec2(0.5,0.5f),vec2(0.9f,0.5f),vec2(0.1f,0.7f)); // wave vector (horiz)

    //float theta[] = float[](8.0, 2.0, 3.0, 1.5); // wavelength
    //float theta[] = float[](0.5, 4.0, 5.0, 2.5); // wavelength
    //float theta[] = float[](8.0, 5.0, 3.0, 1.0); // wavelength

    //float theta[] = float[](8.0, 2.0, 3.0, 5.0); // wavelength
    float theta[] = float[](8.0, 2.0, 3.0, 3.0); // wavelength

    //float k_mag[] = float[](1.0, 3.0, 2.0, 5.0); // k magnitude
    float k_mag[] = float[](1.0, 3.0, 2.0, 10.0); // k magnitude
    //float w[] = float[](1.0, 0.5, 0.25, 1.5); // frequency
    float w[] = float[](1.0, 0.5, 0.25, 0.75); // frequency
    //float p[] = float[](0.f, 3.f, 0.2f, 0.5f); // phase
    float p[] = float[](0.75f, 3.f, 0.2f, 0.5f); // phase

    // define variables
    //float A = 0.7; // wave amplitude
    //vec2 k = vec2(1.f,0.5f); // horizontal vector in dir of wave
    //float theta = 17.0; // wavelength
    //float k_mag = (2.f * M_PI)/theta; // magnitude of k
    //float w; // frequency
    //float p = 0.f; // phase
    float g = 9.81; // gravity
    float t = float(u_Time) / 40.0; // time

    // define return vec2(x,y)
    vec3 coor = vec3(x0[0],0,x0[1]);

    vec2 xcalc = vec2(0.0,0.0);
    float ycalc = 0.f;
    vec3 binormals = vec3(0.0,0.0,0.0);
    vec3 tangents = vec3(0.0,0.0,0.0);
  
    for (int i = 0; i < n; i++) {
      // calculate k_mag & w
      k_mag[i] = (2.f * M_PI) / theta[i];
      w[i] = sqrt(g * k_mag[i]);
      float cycle = 24.0; // cycle length
      float w0 = (2.f * M_PI)/cycle;
      w[i] = floor(w[i] / w0) * w0; // ensures w is a multiple of w0

      // calculate
      xcalc = xcalc + (k[i]/k_mag[i])*A[i]*sin(dot(k[i],x0) - w[i]*t + p[i]);
      ycalc = ycalc + A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]);

      // calculate normals
      binormals = vec3(1.f - (binormals.x + (k[i]/k_mag[i]).x * (k[i]/k_mag[i]).x * A[i]*sin(dot(k[i],x0) - w[i]*t + p[i])),
                            -1.f * (binormals.y + (k[i]/k_mag[i]).x * (k[i]/k_mag[i]).y * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i])),
                            binormals.z + (k[i]/k_mag[i]).x * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]));
      tangents = vec3(tangents.x + (-1.f * (k[i]/k_mag[i]).x * (k[i]/k_mag[i]).y *A[i]*sin(dot(k[i],x0) - w[i]*t + p[i])), 
                           tangents.y + (1.f - (k[i]/k_mag[i]).y * (k[i]/k_mag[i]).y * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i])), 
                           tangents.z + ((k[i]/k_mag[i]).y * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i])));
      /*fs_Nor = vec4(-1.f * fs_Nor.x + (k[i]/k_mag[i]).x * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]), 
                    -1.f * fs_Nor.y + (k[i]/k_mag[i]).y * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]), 
                    1.f - (fs_Nor.z + A[i]*sin(dot(k[i],x0) - w[i]*t + p[i])), 
                    1.f);*/
      fs_Nor = vec4(-1.f * fs_Nor.x + (k[i]/k_mag[i]).x * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]), 
                    fs_Nor.y + (k[i]/k_mag[i]).y * A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]), 
                    -1.f * fs_Nor.z * sin(dot(k[i],x0) - w[i]*t + p[i]), 1.f);
    }
    
    coor.xz = x0 - xcalc;
    coor.y = ycalc;

    return coor;
}

void main()
{
  fs_Pos = vs_Pos.xyz;
  fs_UV = vec2(vs_Pos.xz + u_PlanePos.xy);

  fs_Time = float(u_Time);

  //vec4 modelposition = vec4(vs_Pos.x, fs_Rock + fs_FBM * 0.5, vs_Pos.z, 1.0);
  //vec4 modelposition = vec4(vs_Pos.x, fs_FBM * 0.5, vs_Pos.z, 1.0);

  // medium
  /*float strength = 1.0;
  float newy = vs_Pos.y;
  newy += strength * calculateSurface(vs_Pos.x, vs_Pos.z);
  newy -= strength * calculateSurface(0.0, 0.0);*/
  
  // tessendorf
  //vec3 new_vals = wavePropogation(h_vals);
  //h_vals = new_vals;
  //float newy = h_vals[0];
  //vec4 modelposition = vec4(vs_Pos.x, newy, vs_Pos.z, 1.0);

  vec3 coor = gerstnerWave(vs_Pos.xz);
  //vec4 modelposition = vec4(vs_Pos.x, vs_Pos.y, vs_Pos.z, 1.0);
  vec4 modelposition = vec4(coor.x, coor.y, coor.z, 1.0);

  // offset so boat stays on top of water
  //if (vs_Pos.xz > vec2(-0.1f,-0.1f) && vs_Pos.xz < vec2(0.1f,0.1f)) {
  /*if (coor.x > -0.5 && coor.x < 0.5
      && coor.z > -15.5 && coor.z < -14.5) {
    modelposition.y -= coor.y;
    //modelposition.y += 10.0;
  }*/
  
  modelposition.y -= 0.5;

  // pass fs_Peak
  if (modelposition.y > -0.15f) {
      fs_Peak = 1.0;
  } else if (modelposition.y > -0.25f) {
      fs_Peak = 0.5;
  } else {
      fs_Peak = 0.0;
  }

  modelposition = u_Model * modelposition;
  //gl_Position = u_ViewProj * modelposition;
  /*mat4 transfMat = mat4(1.0,0.0,0.0,16.0,
  0.0,1.0,0.0,16.0,
  0.0,0.0,1.0,-16.0,
  0.0,0.0,0.0,1.0);
  mat4 transfMat2 = transfMat;
  transfMat2[2][3] = -1.f * transfMat[2][3];
  transfMat2[0][3] = -1.f * transfMat[0][3];
  transfMat2[1][3] = -1.f * transfMat[1][3];
  vec4 transform = transfMat * u_RotMat * transfMat2 * modelposition;*/
  vec4 transform = u_RotMat * modelposition;
  //gl_Position = u_ViewProj * transform;
  gl_Position = u_ViewProj * modelposition;
}

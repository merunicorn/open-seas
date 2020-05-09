#version 300 es
#define M_PI 3.1415926535897932384626433832795

uniform mat4 u_ViewProj;
uniform int u_Time;
uniform mat4 u_RotMat; // rotation matrix dependent on keyboard presses
uniform mat4 u_InvRotMat;
uniform int u_RotDeg;

uniform mat3 u_CameraAxes; // Used for rendering particles as billboards (quads that are always looking at the camera)
// gl_Position = center + vs_Pos.x * camRight + vs_Pos.y * camUp;

in vec4 vs_Pos; // Non-instanced; each particle is the same quad drawn in a different place
in vec4 vs_Nor; // Non-instanced, and presently unused
in vec4 vs_Col; // An instanced rendering attribute; each particle instance has a different color
in vec3 vs_Translate; // Another instance rendering attribute used to position each quad instance in the scene
/*in vec2 vs_UV; // Non-instanced, and presently unused in main(). Feel free to use it for your meshes.
in vec4 vs_Transf1;
in vec4 vs_Transf2;
in vec4 vs_Transf3;
in vec4 vs_Transf4;*/

out vec4 fs_Col;
out vec4 fs_Pos;
out vec4 fs_Nor;

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

// gerstner wave model
vec3 gerstnerWave(vec2 x0) {
    // define number of functions
    //int n = 4;
    int n = int(random1(vec2(1.0,2.0), vec2(int(x0.x),int(x0.y))) * 2.f) + 2;

    // define wave parameter arrays
    float A[] = float[](0.3, 0.15, 0.1, 0.6); // wave amplitude

    vec2 k[] = vec2[](vec2(0.f,-1.f),vec2(-0.5f,-0.5f),vec2(0.5f,0.9f),vec2(-0.7f,-0.1f)); // wave vector (horiz)
    float theta[] = float[](8.0, 2.0, 3.0, 5.0); // wavelength

    float k_mag[] = float[](1.0, 3.0, 2.0, 5.0); // k magnitude
    float w[] = float[](1.0, 0.5, 0.25, 1.5); // frequency
    float p[] = float[](0.75f, 3.f, 0.2f, 0.5f); // phase

    // define variables
    //float A = 0.7; // wave amplitude
    //vec2 k = vec2(1.f,0.5f); // horizontal vector in dir of wave
    //float theta = 17.0; // wavelength
    //float k_mag = (2.f * M_PI)/theta; // magnitude of k
    //float w; // frequency
    //float p; // phase
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
      //xcalc = xcalc + (k[i]/k_mag[i])*A[i]*sin(dot(k[i],x0) - w[i]*t + p[i]);
      ycalc = ycalc + A[i]*cos(dot(k[i],x0) - w[i]*t + p[i]);
    }
    
    //coor.xz = x0 - xcalc;
    coor.y = ycalc;

    return coor;
}

void main()
{
    fs_Col = vs_Col;
    fs_Pos = vs_Pos;
    fs_Nor = vs_Nor;

    
    //modelposition = u_Model * modelposition;
    //gl_Position = (u_ViewProj * u_RotMat) * modelposition;

    // pass fs_Peak
    /*if (modelposition.y > -0.15f) {
        fs_Peak = 1.0;
    } else if (modelposition.y > -0.25f) {
        fs_Peak = 0.5;
    } else {
        fs_Peak = 0.0;
    }*/

    //vec3 pos = vec3(vs_Pos.x, vs_Pos.y, vs_Pos.z - 16.f); //fixed pos closer to camera
    vec3 pos = vec3(vs_Pos.x, vs_Pos.y, vs_Pos.z);

    // calculate wave @ boat position; 4 corners
    
    vec2 c1 = vec2(-1.f, -1.5f); //bot left
    vec2 c2 = vec2(1.f, -1.5f); //bot right
    vec2 c3 = vec2(-1.f, 1.5f); //top left
    vec2 c4 = vec2(1.f, 1.5f); //top right

    // apply keyboard rotation matrix to account for updated position
    float rad = acos(u_RotMat[0][0]);
    //float rad = (float(u_RotDeg) * M_PI) / 180.f;
    mat3 rotMatY = mat3(cos(rad), 0, -sin(rad),
                        0, 1, 0,
                        sin(rad), 0, cos(rad));
    c1 = (rotMatY * vec3(-1.f, 0.f, -1.5f)).xz; //bot left
    c2 = (rotMatY * vec3(1.f, 0.f, -1.5f)).xz; //bot right
    c3 = (rotMatY * vec3(-1.f, 0.f, 1.5f)).xz; //top left
    c4 = (rotMatY * vec3(1.f, 0.f, 1.5f)).xz; //top right

    float bp1 = gerstnerWave(c1).y;
    float bp2 = gerstnerWave(c2).y;
    float bp3 = gerstnerWave(c3).y;
    float bp4 = gerstnerWave(c4).y;

    float diffX = bp1 - bp3;
    //float diffZ = bp3 - bp1;
    float diffZ = bp1 - bp2;

    // determine angle of rotation
    
    //float rotRadX = (atan(diffX/2.f))/5.f;
    rad = (float(u_RotDeg) * M_PI) / 180.f;
    float rotRadX = ((atan(diffX/2.f))/0.95f) * clamp(abs(sin(rad)), 0.2, 1.0); //3.2
    float rotRadZ = ((atan(diffZ/2.f))/1.5f) * clamp(abs(cos(rad)), 0.2, 1.0); //2.2
    // adjust angle based on keyboard rotation
    
    /*float rad = acos(u_RotMat[0][0]); // determine angle of keyboard rotation
    if (rad < (M_PI/2.f) + 0.1f && rad > (M_PI/2.f) - 0.1f) {
        float rotRadX = (atan(diffX/2.f))/1.2f;
        float rotRadZ = (atan(diffZ/3.f))/5.f;
    }*/

    // create rotation matrices
    mat4 rotMatX = mat4(1, 0, 0, 0,
                        0, cos(rotRadX), -sin(rotRadX), 0,
                        0, sin(rotRadX), cos(rotRadX), 0,
                        0, 0, 0, 1);
    mat4 rotMatZ = mat4(cos(rotRadZ), -sin(rotRadZ), 0, 0,
                        sin(rotRadZ), cos(rotRadZ), 0, 0,
                        0, 0, 1, 0,
                        0, 0, 0, 1);

    vec3 coor = gerstnerWave(vec2(0.f,0.f));
    float boatpos = coor.y;

    vec4 newPos = rotMatZ * rotMatX * u_InvRotMat * vec4(pos,1.0);
    newPos.z -= 16.f; // move boat closer to camera
    newPos.y -= (boatpos/4.f); // boat floats on wave

    // calculate new normals
    fs_Nor =  rotMatZ * rotMatX * vs_Nor;

    gl_Position = u_ViewProj * newPos;
}

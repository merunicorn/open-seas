#version 300 es
#define M_PI 3.1415926535897932384626433832795
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane
uniform mat4 u_RotMat;
uniform mat4 u_InvRotMat;

//vec3 bg_Col = vec3(88.0 / 255.0, 91.0 / 255.0, 196.0 / 255.0);
vec3 bg_Col = vec3(0.5216, 0.8157, 0.9059);
//vec3 sand_Col = vec3(u_Color.x, u_Color.y, u_Color.z);
vec3 sand_Col = vec3(255.0 / 255.0, 229.0 / 255.0, 99.0 / 255.0);

//[[0.718 0.698 0.548] [-0.212 0.498 0.500] [0.328 0.438 0.418] [-0.262 0.348 0.478]]
//rock cosine palette
vec3 rock_a = vec3(0.718, 0.698, 0.548);
vec3 rock_b = vec3(-0.212, 0.498, 0.500);
vec3 rock_c = vec3(0.328, 0.438, 0.418);
vec3 rock_d = vec3(-0.262, 0.348, 0.478);

//[[0.500 0.500 0.500] [0.500 0.500 0.500] [0.500 0.500 0.298] [1.448 0.588 -0.182]]
//sunlight cosine pallete
vec3 sun_a = vec3(0.5, 0.5, 0.5);
vec3 sun_b = vec3(0.5, 0.5, 0.5);
vec3 sun_c = vec3(0.5, 0.5, 0.298);
vec3 sun_d = vec3(1.448, 0.588, -0.182);

in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_Col;
in vec2 fs_UV;

in float fs_Sine;
in float fs_FBM;
in float fs_Worley;
in float fs_Rock;
in float fs_guiCol;
in float fs_guiSan;
in float fs_Time;
in float fs_Peak;

//Cosine Color Palette (Adam's code)
vec3 cosinePalette(float t, float i, float time) {
    if (i == 1.0) {
        if (fs_guiCol == 1.0) {
            float cosX = time * 3.14159 * 0.004;
            float sinY = time * 3.14159 * 0.004;
            sun_d -= (cosX, sinY, cosX);
        }
        return clamp(sun_a + sun_b * cos(2.0 * 3.14159 * 
        (sun_c * t + sun_d)), 0.0, 1.0);
    }
    else {
        return clamp(rock_a + rock_b * cos(2.0 * 3.14159 * 
        (rock_c * t + rock_d)), 0.0, 1.0);
    }
    
}

float random1( vec2 p , vec2 seed) {
  return fract(sin(dot(p + seed, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 random2( vec2 p , vec2 seed) {
  return fract(sin(vec2(dot(p + seed, vec2(311.7, 127.1)), dot(p + seed, vec2(269.5, 183.3)))) * 85734.3545);
}

//Worley Noise (Adam's code)
float WorleyNoise(vec2 uv)
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

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    //float t = clamp(smoothstep(40.0, 50.0, length(fs_Pos)), 0.0, 1.0); // Distance fog

    // medium
    //vec2 uv = fs_UV * 10.0 + vec2(fs_Time * -0.15);

    vec2 uv = fs_UV * 10.0 + vec2(fs_Time * -0.15);

    uv.y += sin(fs_Time * 0.1f);
    uv.x += sin(fs_Time * 0.025f);

    /*uv.y += 0.01 * (sin(uv.x * 13.5 + fs_Time * 5.35) + 
                     sin(uv.x * 4.8 + fs_Time * 1.05) + sin(uv.x * 7.3 + fs_Time * 0.45)) / 3.0;
    uv.x += 0.12 * (sin(uv.y * 4.0 + fs_Time * 0.5) + 
                     sin(uv.y * 16.8 + fs_Time * 3.75) + sin(uv.y * 11.3 + fs_Time * 0.2)) / 3.0;
    uv.y += 0.12 * (sin(uv.x * 14.2 + fs_Time * 0.64) + 
                     sin(uv.x * 6.3 + fs_Time * 1.65) + sin(uv.x * 8.2 + fs_Time * 2.45)) / 3.0;*/

    /*uv.y += 0.5 * (sin(uv.x * 13.5 + fs_Time * 5.35) + 
                     sin(uv.x * 4.8 + fs_Time * 1.05) + sin(uv.x * 7.3 + fs_Time * 0.45)) / 3.0;
    uv.x += 5.12 * (sin(uv.y * 4.0 + fs_Time * 0.5) + 
                     sin(uv.y * 16.8 + fs_Time * 3.75) + sin(uv.y * 11.3 + fs_Time * 0.2)) / 3.0;*/

    // worley texture
    float worl = WorleyNoise(uv.xy / 20.3);
    float worl2 = WorleyNoise(uv.xy / 18.2);
    vec3 col_worl = vec3(worl);
    vec3 col_worl2 = vec3(worl2);
    vec3 col_lvl1 = vec3(0.1686, 0.8314, 0.8784);
    vec3 col_lvl2 = vec3(0.2667, 0.2392, 0.5412);
    col_worl += col_lvl1;
    col_worl2 = vec3(1.0) - col_worl2;
    col_worl2 += col_lvl2 / vec3(5.0);
    //vec3 col_worl = cosinePalette(worl, 1.0, fs_Time);

    vec3 col_base = vec3(0.0706, 0.6431, 0.8667);

    // gradient
    vec3 grad_Col = vec3(0.4039, 0.9059, 0.8824);
    grad_Col = vec3(0.0588, 0.0902, 0.5725);
    float p = length(fs_Pos);
    float t1 = clamp(smoothstep(20.0, 80.0, p), 0.0, 1.0);
    //float t1 = distance(fs_Pos.xz, fs_UV);
    out_Col = vec4(mix(vec3(col_base),grad_Col,t1 * 0.7),1.0);

    // cool color distortion, potentially a good effect for wake??
    vec3 dist_Col = vec3(0.4039, 0.9059, 0.8824);
    float t3 = distance(fs_Pos.xy, vec2(0.f,0.5f));
    //out_Col = vec4(0.5) * vec4(mix(vec3(out_Col),dist_Col,t3),1.0);

    // WORLEY
    //vec3 col_base = vec3(0.1686, 0.8314, 0.8784);
    //out_Col = vec4(mix(vec3(out_Col),col_worl,0.2),1.0);
    //out_Col = vec4(mix(vec3(out_Col),col_worl2,0.125),1.0);
    
    out_Col = vec4(mix(vec3(out_Col),col_worl,0.075),1.0);
    out_Col = vec4(mix(vec3(out_Col),col_worl2,0.1),1.0);

    // lighting / using normals
    // Implement specular light
          vec4 H = vec4(1.0);
          vec4 lights = vec4(3.0, 5.0, 3.0, 2.0);
          for (int i = 0; i < 4; i++) {
            H[i] = (lights[i] + u_Eye[i]) / 2.0;
          }
          float specularIntensity = max(pow(dot(normalize(H), normalize(fs_Nor)), 1.0), 0.0);

          // Compute final shaded color
          vec3 mater = vec3(0.1647, 0.9451, 0.9451) * min(specularIntensity, 1.0);
          out_Col = vec4(mix(vec3(out_Col),mater,0.6),1.0);


    // ALT LIGHTING
    /*float dist = 1.0 - (length(fs_Pos.xyz) * 2.0);
    vec4 diffuseColor = vec4(out_Col);
    vec4 light = vec4(1.0, 5.0, 0.0, 0.0);
    // Calculate diffuse term for shading
    float diffuseTerm = dot(normalize(vec3(fs_Nor)), normalize(vec3(light)));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;
    lightIntensity = 1.f - lightIntensity;
    vec4 lightCol = vec4(1.0, 196.0/255.0, 97.0/255.0, 1.0);
    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity * lightCol.rgb, diffuseColor.a);*/
    

    // distance fog
    float t2 = clamp(smoothstep(40.0, 80.0, p), 0.0, 1.0);
    out_Col = vec4(mix(vec3(out_Col),bg_Col,t2),1.0);

    // GRID
    /*if (fract(fs_UV.x) < 0.01f || fract(fs_UV.y) < 0.01f) {
        out_Col = vec4(col_pt,1.0);
    } else {
        out_Col = vec4(col_base,1.0);
        //out_Col = vec4(mix(col_base,col_worl,0.15),1.0);
    }*/

    // GRID OR NORMAL
    vec3 col_pt = vec3(1.0, 1.0, 1.0);
    if (fract(fs_UV.x) < 0.01f || fract(fs_UV.y) < 0.01f) {
        //out_Col = vec4(col_pt,1.0); //white grid
        out_Col = vec4(mix(vec3(out_Col),col_pt,0.5),1.0); //grid opacity lowered
    }

    // CRESTS
    // float worl_test = WorleyNoise(fs_UV.yy);

    // worley tests
    float worl_test = WorleyNoise(fs_UV.xy * 2.0);
    vec3 worl_col = vec3(worl_test);
    // add random
    float bound = 0.65;
    float bound2 = 0.85;
    //bound = (random1(fs_UV, fs_UV) * 0.4f) + 0.4;

    // stronger distinctions
    // distort w second worley test: more white
    float worl_test2 = WorleyNoise(fs_UV.xy / 2.0);
    if (worl_test < bound) {
        worl_test = 0.0;
        worl_col = vec3(out_Col);
    } else if (worl_test < bound2 && worl_test2 < 0.5) {
        //worl_col = vec3(0.502, 0.7333, 0.8863);
        worl_col = vec3(out_Col);
    } else {
        worl_test = 1.0;
        worl_col = vec3(0.702, 0.8706, 0.9412);
        //out_Col += vec4(worl_col,0.0);
    }
    //out_Col += vec4(worl_col,1.0);
    out_Col = vec4(mix(vec3(out_Col),worl_col,0.65),1.0);

    // fs_Peak
    if (fs_Peak >= 0.5) {
        float worl_peak = WorleyNoise(fs_UV.yx * 9.5);
        float worl_peak2 = WorleyNoise(fs_UV.yy / 13.5);
        vec3 peak_col = vec3(out_Col);
        if (worl_peak < 0.85 && worl_peak > 0.6 && worl_peak2 > 0.3) {
            if (fs_Peak == 1.0) {
                peak_col = vec3(1.0);
            } else {
                peak_col = vec3(out_Col) + vec3(0.1137, 0.1176, 0.1216);
            }
        }
        out_Col = vec4(mix(vec3(out_Col),vec3(peak_col),0.7),1.0);
    }


    // FOAM around initial boat pos

    /*if (u_RotMat == id) {
        out_Col = vec4(1.0,0.0,1.0,1.0);
    }*/
    /*if (fs_UV.x > c1.x && fs_UV.x < c2.x && fs_UV.y > c1.y - 16.f && fs_UV.y < c3.y - 16.f) {
    //if (fs_UV.x > -1.f && fs_UV.x < 1.f && fs_UV.y > -4.5f - 16.f && fs_UV.y < 4.5f - 16.f) {
      out_Col = vec4(0.6039, 0.5569, 0.7804, 1.0);
    } else {
      out_Col = vec4(0.4549, 0.2549, 0.0706, 1.0);
    }*/
    
}

#version 300 es
precision highp float;

uniform vec2 u_PlanePos; // Our location in the virtual world displayed by the plane

vec3 bg_Col = vec3(88.0 / 255.0, 91.0 / 255.0, 196.0 / 255.0);
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

//Cosine Color Pallete (Adam's code)
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

    /*if(fs_guiSan == 1.0) {
        sand_Col = vec3(255.0 / 255.0, 165.0 / 255.0, 99.0 / 255.0);
    }
    else {
        sand_Col = vec3(255.0 / 255.0, 229.0 / 255.0, 99.0 / 255.0);
    }
    
    vec3 col_fbm = vec3(mix(sand_Col, vec3(0.25 * (fs_FBM + 1.0)), 0.5));
    vec4 col_step = vec4(mix(col_fbm, bg_Col, t), 1.0);

    vec3 col_sunlight = cosinePalette((fs_FBM/1.5) * fs_Worley, 1.0, fs_Time);
    vec4 col_step2 = vec4(mix(col_sunlight * 1.7, bg_Col, t), 1.0);

    vec3 col_rock = 0.5 * cosinePalette((fs_FBM/1.5) * pow(fs_Worley,0.2), 2.0, fs_Time);
    vec4 col_step3 = vec4(mix(col_rock, bg_Col, t), 1.0);
    if (fs_Rock < 0.2) {
        col_step3 = vec4(mix(vec3(col_step), bg_Col, t), 1.0);
    }

    vec4 col_sand = vec4(mix(col_step, col_step2, 0.2));
    vec4 col_rocksun = vec4(mix(col_step3, col_step2, 0.2));
    vec4 col_final = vec4(mix(col_sand, col_rocksun, 0.5));

    out_Col = col_final;*/
    // medium
    vec2 uv = fs_UV * 10.0 + vec2(fs_Time * -0.15);

    uv.y += 0.01 * (sin(uv.x * 13.5 + fs_Time * 5.35) + 
                     sin(uv.x * 4.8 + fs_Time * 1.05) + sin(uv.x * 7.3 + fs_Time * 0.45)) / 3.0;
    uv.x += 0.12 * (sin(uv.y * 4.0 + fs_Time * 0.5) + 
                     sin(uv.y * 16.8 + fs_Time * 3.75) + sin(uv.y * 11.3 + fs_Time * 0.2)) / 3.0;
    uv.y += 0.12 * (sin(uv.x * 14.2 + fs_Time * 0.64) + 
                     sin(uv.x * 6.3 + fs_Time * 1.65) + sin(uv.x * 8.2 + fs_Time * 2.45)) / 3.0;

    // worley texture
    float worl = WorleyNoise(uv.xy / 20.3);
    vec3 col_worl = vec3(worl);
    vec3 col_lvl1 = vec3(0.1686, 0.8314, 0.8784);
    col_worl += col_lvl1;
    //vec3 col_worl = cosinePalette(worl, 1.0, fs_Time);

    // grid
    vec3 col_base = vec3(0.2, 0.651, 0.8275);
    //vec3 col_base = vec3(0.1686, 0.8314, 0.8784);
    vec3 col_pt = vec3(1.0, 1.0, 1.0);
    out_Col = vec4(mix(col_base,col_worl,0.2),1.0);
    /*if (fract(fs_UV.x) < 0.01f || fract(fs_UV.y) < 0.01f) {
        out_Col = vec4(col_pt,1.0);
    } else {
        //out_Col = vec4(col_base,1.0);
        out_Col = vec4(mix(col_base,col_worl,0.25),1.0);
    }*/
    
}

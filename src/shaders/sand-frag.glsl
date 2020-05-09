#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting

in vec3 fs_Pos;
in float fs_FBM;

out vec4 out_Col;

void main() {
    vec3 sand = vec3(0.9451, 0.851, 0.5922);
    out_Col = vec4(sand, 1.0);

    // distance fog
    vec3 bg_Col = vec3(0.6941, 0.8745, 0.9451);
    float p = length(fs_Pos);
    float t2 = clamp(smoothstep(10.0, 50.0, p), 0.0, 1.0);
    

    vec3 col_fbm = vec3(mix(vec3(out_Col), vec3(0.25 * (fs_FBM + 1.0)), 0.5));
    out_Col = vec4(col_fbm,1.0);

    out_Col = vec4(mix(vec3(out_Col),bg_Col,t2),1.0);
}

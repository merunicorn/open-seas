#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
/*
in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 fs_Nor;

out vec4 out_Col;

void main() {
  //vec3 bg = vec3(0.4588, 0.7333, 0.098);
  out_Col = vec4(vec3(fs_Col), 1.0);
  //out_Col = vec4(88.0 / 255.0, 91.0 / 255.0, 196.0 / 255.0, 1.0);
  //out_Col = vec4(164.0 / 255.0, 233.0 / 255.0, 1.0, 1.0);
}
*/


/*

#version 300 es
precision highp float;
*/
in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 fs_Nor;

out vec4 out_Col;

void main()
{
    /*
    float dist = 1.0 - (length(fs_Pos.xyz) * 2.0);
    //out_Col = vec4(dist) * fs_Col;
    //out_Col = fs_Col;

    vec4 diffuseColor = vec4(fs_Col);

    vec4 light = vec4(1.0, 5.0, 0.0, 0.0);
    
    // Calculate diffuse term for shading
    float diffuseTerm = dot(normalize(vec3(fs_Nor)), normalize(vec3(light)));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
    
    float ambientTerm = 0.2;
    float lightIntensity = diffuseTerm + ambientTerm;

    vec4 lightCol = vec4(1.0, 196.0/255.0, 97.0/255.0, 1.0);
    
    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity * lightCol.rgb, diffuseColor.a);
    */
    out_Col = vec4(0.4549, 0.2549, 0.0706, 1.0);
}

#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting
in vec4 fs_Col;
in vec4 fs_Pos;
in vec4 fs_Nor;

out vec4 out_Col;

void main()
{
    
    float dist = 1.0 - (length(fs_Pos.xyz) * 2.0);
    //out_Col = vec4(dist) * fs_Col;
    //out_Col = fs_Col;
    vec4 boatCol;
    if (fs_Pos.x > -1.f && fs_Pos.x < 1.f && fs_Pos.z > -1.75f && fs_Pos.z < 1.25f) {
      boatCol = vec4(0.7686, 0.4706, 0.3804, 1.0);
    } else {
      boatCol = vec4(0.6549, 0.3412, 0.1961, 1.0);
    }

    vec4 diffuseColor = vec4(boatCol);

    vec4 light = vec4(-5.0, 25.0, 5.0, 0.0);
    
    // Calculate diffuse term for shading
    float diffuseTerm = dot(normalize(vec3(fs_Nor)), normalize(vec3(light)));
    // Avoid negative lighting values
    diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);
    
    float ambientTerm = 0.0; //0.2
    float lightIntensity = (diffuseTerm * 0.5) + ambientTerm;

    //vec4 lightCol = vec4(0.8275, 0.6902, 0.0863, 1.0);
    //vec4 lightCol = vec4(0.1647, 0.9451, 0.9451,1.0);
    vec4 lightCol = vec4(0.8588, 0.7804, 0.4196, 1.0);
    
    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb + (lightIntensity * lightCol.rgb), diffuseColor.a);
    
    //out_Col = vec4(0.4549, 0.2549, 0.0706, 1.0);
    /*if (fs_Pos.x > -1.f && fs_Pos.x < 1.f && fs_Pos.z > -1.5f && fs_Pos.z < 1.5f) {
      out_Col = vec4(0.7686, 0.4706, 0.3804, 1.0);
    } else {
      out_Col = vec4(0.6549, 0.3412, 0.1961, 1.0);
    }*/
}

#version 300 es
precision highp float;

// The fragment shader used to render the background of the scene
// Modify this to make your background more interesting

out vec4 out_Col;

void main() {
  vec3 bg = vec3(0.5216, 0.8157, 0.9059);
  out_Col = vec4(bg, 1.0);
  //out_Col = vec4(88.0 / 255.0, 91.0 / 255.0, 196.0 / 255.0, 1.0);
  //out_Col = vec4(164.0 / 255.0, 233.0 / 255.0, 1.0, 1.0);
}

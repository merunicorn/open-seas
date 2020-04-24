import {vec2, vec3, vec4, mat4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Plane from './geometry/Plane';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

import {readTextFile} from './globals';
import Mesh from './geometry/Mesh';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  //sandy: false,
  //animated: false,
  boat: true,
};

let square: Square;
let plane : Plane;
let mesh_cube: Mesh;

let wPressed: boolean;
let aPressed: boolean;
let sPressed: boolean;
let dPressed: boolean;
let planePos: vec2;

let planeRot: number;
//let sandBool: boolean = false;
//let animBool: boolean = false;
let boatBool: boolean = true;
let time: number = 0;
//let obj0: string = readTextFile('../mesh/cube2.obj');
let obj0: string = readTextFile('../mesh/rect8.obj');

//let target: vec3 = vec3.fromValues(0,-5,0);
let position: vec3;
let target: vec3;


function loadScene() {
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  //plane = new Plane(vec3.fromValues(0,0,0), vec2.fromValues(100,100), 20);
  plane = new Plane(vec3.fromValues(0,0,0), vec2.fromValues(150,150), 18); //18
  plane.create();

  // build mesh
  mesh_cube = new Mesh(obj0, vec3.fromValues(0,0,0));
  mesh_cube.create();

  wPressed = false;
  aPressed = false;
  sPressed = false;
  dPressed = false;
  planePos = vec2.fromValues(0,0);
  planeRot = 0.0;

  // mesh instancing
  /*let colorsArray = [];
  let transf1Array = [1, 0, 0, 0];
  let transf2Array = [0, 1, 0, 0];
  let transf3Array = [0, 0, 1, 0];
  let transf4Array = [0, 0, 0, 1];
  //let k: number = 4;
  for (let kcount = 0; kcount < 1; kcount++) {
    for (let icount = 0; icount < 4; icount++) {
      transf1Array.push(0);
      transf2Array.push(0);
      transf3Array.push(0);
      transf4Array.push(0);
      colorsArray.push(0);
    }
  }

  let colors: Float32Array = new Float32Array(colorsArray);
  let transf1: Float32Array = new Float32Array(transf1Array);
  let transf2: Float32Array = new Float32Array(transf2Array);
  let transf3: Float32Array = new Float32Array(transf3Array);
  let transf4: Float32Array = new Float32Array(transf4Array);

  //mesh_cube.setNumInstances(k);
  mesh_cube.setVBOTransform(colors, transf1, transf2, transf3, transf4);*/

  /*let offsetsArray = [];
  let colorsArray = [];
  let n: number = 10.0;
  for(let i = 0; i < n; i++) {
    for(let j = 0; j < n; j++) {
      offsetsArray.push(i);
      offsetsArray.push(j);
      offsetsArray.push(0);

      colorsArray.push(i / n);
      colorsArray.push(j / n);
      colorsArray.push(1.0);
      colorsArray.push(1.0); // Alpha channel
    }
  }*/
  //let offsets: Float32Array = new Float32Array(offsetsArray);
  //let colors: Float32Array = new Float32Array(colorsArray);
  //mesh_cube.setInstanceVBOs(offsets, colors);
  //mesh_cube.setNumInstances(n * n);
}

function main() {
  window.addEventListener('keypress', function (e) {
    // console.log(e.key);
    switch(e.key) {
      case 'w':
      wPressed = true;
      break;
      case 'a':
      aPressed = true;
      break;
      case 's':
      sPressed = true;
      break;
      case 'd':
      dPressed = true;
      break;
    }
  }, false);

  window.addEventListener('keyup', function (e) {
    switch(e.key) {
      case 'w':
      wPressed = false;
      break;
      case 'a':
      aPressed = false;
      break;
      case 's':
      sPressed = false;
      break;
      case 'd':
      dPressed = false;
      break;
    }
  }, false);

  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'boat');
  //gui.add(controls, 'sandy');
  //gui.add(controls, 'animated');

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  //const camera = new Camera(vec3.fromValues(0, 5, -20), vec3.fromValues(0, 0, 0));
  const camera = new Camera(vec3.fromValues(0, 2.5, -20), vec3.fromValues(0, -5, 0));
  //const camera = new Camera(position, target);

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/terrain-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/terrain-frag.glsl')),
  ]);

  const meshShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/mesh-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/mesh-frag.glsl')),
  ]);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  function processKeyPresses() {
    let velocity: vec2 = vec2.fromValues(0,0);
    //let v: number = 0.3;
    let v: number = 0.15;
    let degrees: number = 1.0;
    // convert rotation from degrees to radians
    let rotRad = (planeRot * Math.PI) / 180.0;

    if(wPressed) {
      velocity[1] += v*Math.cos(rotRad); // z
      velocity[0] -= v*Math.sin(rotRad); // x
    }
    if(aPressed) {
      planeRot -= degrees;
    }
    if(sPressed) {
      v = 0.075;
      velocity[1] -= v*Math.cos(rotRad); // z
      velocity[0] += v*Math.sin(rotRad); // x
    }
    if(dPressed) {
      planeRot += degrees;
    }
    let newPos: vec2 = vec2.fromValues(0,0);
    vec2.add(newPos, velocity, planePos); // velocity + planePos in dir of planeRot
    lambert.setPlanePos(newPos);
    planePos = newPos;

    // convert rotation from degrees to radians
    //rotRad = (planeRot * Math.PI) / 180.0;
    // create rotation matrix
    let rotMat: mat4 = mat4.fromValues(Math.cos(rotRad), 0, -Math.sin(rotRad), 0,
                                       0, 1, 0, 0,
                                       Math.sin(rotRad), 0, Math.cos(rotRad), 0,
                                       0, 0, 0, 1);
    lambert.setRotMatrix(rotMat);
    let invRotMat: mat4 = mat4.create();
    mat4.invert(invRotMat, rotMat);
    lambert.setInvRotMatrix(invRotMat);
    //console.log(rotMat);
  }

  // This function will be called every frame
  function tick() {
    time++;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    processKeyPresses();

    //dat.GUI controls
    /*if (controls.sandy == true) {
      sandBool = true;
    }
    else {
      sandBool = false;
    }
    if(controls.animated == true) {
      animBool = true;
    }
    else {
      animBool = false;
    }*/

    renderer.render(camera, lambert, [
      plane], 
      time);
    renderer.render(camera, flat, [
      square],
      time);
    if (controls.boat == true) {
      renderer.render(camera, meshShader, [
        mesh_cube],
        time);
    }
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();

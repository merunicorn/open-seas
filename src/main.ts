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
  'Load Scene': loadScene, // A function pointer, essentially
  //sandy: false,
  //animated: false,
  boat: true,
  foam: true,
  opacity: 7,
};

let square: Square;
let plane : Plane;
let sandPlane: Plane;
//let sandSquare: Square;
let mesh_cube: Mesh;

let wPressed: boolean;
let aPressed: boolean;
let sPressed: boolean;
let dPressed: boolean;
let planePos: vec2;

let planeRot: number;
let wOpacity: number = 7;
let time: number = 0;
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

  sandPlane = new Plane(vec3.fromValues(0,-5,0), vec2.fromValues(200,300), 6);
  sandPlane.create();
  //sandSquare = new Square(vec3.fromValues(0,-10,0));
  //sandSquare.create();

  // build mesh
  mesh_cube = new Mesh(obj0, vec3.fromValues(0,0,0));
  mesh_cube.create();

  wPressed = false;
  aPressed = false;
  sPressed = false;
  dPressed = false;
  planePos = vec2.fromValues(0,0);
  planeRot = 0.0;
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
  gui.add(controls, 'foam');
  gui.add(controls, 'opacity', 1, 10).step(1);

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
  const camera = new Camera(vec3.fromValues(0, 2.5, -22), vec3.fromValues(0, -5, 0));
  //const camera = new Camera(position, target);

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);
  
  gl.disable(gl.DEPTH_TEST);
  gl.enable(gl.BLEND);
  //gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  //gl.blendFunc(gl.ONE, gl.ONE);
  //

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/terrain-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/terrain-frag.glsl')),
  ]);
  
  //gl.enable(gl.BLEND);
  //gl.blendFunc(gl.ONE, gl.ONE);
  gl.enable(gl.DEPTH_TEST);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

  const meshShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/mesh-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/mesh-frag.glsl')),
  ]);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);

  const sandShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/sand-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/sand-frag.glsl')),
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
    //sandShader.setPlanePos(newPos);
    planePos = newPos;
    //console.log(planePos);

    // convert rotation from degrees to radians
    //rotRad = (planeRot * Math.PI) / 180.0;
    // create rotation matrix
    let rotMat: mat4 = mat4.fromValues(Math.cos(rotRad), 0, -Math.sin(rotRad), 0,
                                       0, 1, 0, 0,
                                       Math.sin(rotRad), 0, Math.cos(rotRad), 0,
                                       0, 0, 0, 1);
    lambert.setRotMatrix(rotMat);
    meshShader.setRotMatrix(rotMat);
    sandShader.setRotMatrix(rotMat);
    let invRotMat: mat4 = mat4.create();
    mat4.invert(invRotMat, rotMat);
    lambert.setInvRotMatrix(invRotMat);
    meshShader.setInvRotMatrix(invRotMat);
    sandShader.setInvRotMatrix(invRotMat);

    let pp: vec4 = vec4.fromValues(planePos[0], 0.0, planePos[1], 1.0);
    pp = vec4.transformMat4(pp, pp, rotMat);
    //lambert.setPlanePos(vec2.fromValues(pp[0], pp[2]));
    //planePos = vec2.fromValues(pp[0], pp[2]);
    //console.log(vec2.fromValues(pp[0], pp[2]));
    console.log(planeRot);
    lambert.setRotDeg(planeRot);
    meshShader.setRotDeg(planeRot);
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
    // opacity control
    //if (controls.opacity !== wOpacity) {
      lambert.setOpacity(controls.opacity);
    //}
    lambert.setFoam(controls.foam);

    renderer.render(camera, flat, [
      square],
      time);
    renderer.render(camera, sandShader, [
      sandPlane], 
      time);
    renderer.render(camera, lambert, [
      plane], 
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

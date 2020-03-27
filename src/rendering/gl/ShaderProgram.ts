import {vec2, vec4, vec3, mat4} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram {
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;

  attrTranslate: number; // Used in the vertex shader during instanced rendering to offset the vertex positions to the particle's drawn position.
  attrTransform1: number; // Mesh transformation data
  attrTransform2: number; // Mesh transformation data
  attrTransform3: number; // Mesh transformation data
  attrTransform4: number; // Mesh transformation data
  attrUV: number;

  unifRef: WebGLUniformLocation;
  unifEye: WebGLUniformLocation;
  unifUp: WebGLUniformLocation;

  unifModel: WebGLUniformLocation;
  unifModelInvTr: WebGLUniformLocation;
  unifViewProj: WebGLUniformLocation;
  unifColor: WebGLUniformLocation;
  unifPlanePos: WebGLUniformLocation;
  unifTime: WebGLUniformLocation;

  unifRotMat: WebGLUniformLocation;
  //unifCustomCol: WebGLUniformLocation;
  //unifAnimBool: WebGLUniformLocation;

  constructor(shaders: Array<Shader>) {
    this.prog = gl.createProgram();

    for (let shader of shaders) {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos = gl.getAttribLocation(this.prog, "vs_Pos");
    this.attrNor = gl.getAttribLocation(this.prog, "vs_Nor");
    this.attrCol = gl.getAttribLocation(this.prog, "vs_Col");

    this.attrTranslate = gl.getAttribLocation(this.prog, "vs_Translate");
    this.attrTransform1 = gl.getAttribLocation(this.prog, "vs_Transf1");
    this.attrTransform2 = gl.getAttribLocation(this.prog, "vs_Transf2");
    this.attrTransform3 = gl.getAttribLocation(this.prog, "vs_Transf3");
    this.attrTransform4 = gl.getAttribLocation(this.prog, "vs_Transf4");
    this.attrUV = gl.getAttribLocation(this.prog, "vs_UV");

    this.unifEye   = gl.getUniformLocation(this.prog, "u_Eye");
    this.unifRef   = gl.getUniformLocation(this.prog, "u_Ref");
    this.unifUp   = gl.getUniformLocation(this.prog, "u_Up");

    this.unifModel      = gl.getUniformLocation(this.prog, "u_Model");
    this.unifModelInvTr = gl.getUniformLocation(this.prog, "u_ModelInvTr");
    this.unifViewProj   = gl.getUniformLocation(this.prog, "u_ViewProj");
    this.unifPlanePos   = gl.getUniformLocation(this.prog, "u_PlanePos");
    this.unifTime   = gl.getUniformLocation(this.prog, "u_Time");

    this.unifRotMat = gl.getUniformLocation(this.prog, "u_RotMat");
    //this.unifCustomCol   = gl.getUniformLocation(this.prog, "u_Color");
    //this.unifAnimBool   = gl.getUniformLocation(this.prog, "u_Anim");
  }

  use() {
    if (activeProgram !== this.prog) {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }

  setEyeRefUp(eye: vec3, ref: vec3, up: vec3) {
    this.use();
    if(this.unifEye !== -1) {
      gl.uniform3f(this.unifEye, eye[0], eye[1], eye[2]);
    }
    if(this.unifRef !== -1) {
      gl.uniform3f(this.unifRef, ref[0], ref[1], ref[2]);
    }
    if(this.unifUp !== -1) {
      gl.uniform3f(this.unifUp, up[0], up[1], up[2]);
    }
  }

  setModelMatrix(model: mat4) {
    this.use();
    if (this.unifModel !== -1) {
      gl.uniformMatrix4fv(this.unifModel, false, model);
    }

    if (this.unifModelInvTr !== -1) {
      let modelinvtr: mat4 = mat4.create();
      mat4.transpose(modelinvtr, model);
      mat4.invert(modelinvtr, modelinvtr);
      gl.uniformMatrix4fv(this.unifModelInvTr, false, modelinvtr);
    }
  }

  setViewProjMatrix(vp: mat4) {
    this.use();
    if (this.unifViewProj !== -1) {
      gl.uniformMatrix4fv(this.unifViewProj, false, vp);
    }
  }

  setPlanePos(pos: vec2) {
    this.use();
    if (this.unifPlanePos !== -1) {
      gl.uniform2fv(this.unifPlanePos, pos);
    }
  }

  setRotMatrix(rot: mat4) {
    this.use();
    if (this.unifRotMat !== -1) {
      gl.uniformMatrix4fv(this.unifRotMat, false, rot);
    }
  }

  /*setSandColor(col: number) {
    this.use();
    if (this.unifCustomCol !== -1) {
      gl.uniform1i(this.unifCustomCol, col);
    }
  }*/

  setTime(t: number) {
    this.use();
    if(this.unifTime != -1) {
      gl.uniform1i(this.unifTime, t);
    }
  }

  /*setAnim(anim: number) {
    this.use();
    if(this.unifAnimBool != -1) {
      gl.uniform1i(this.unifAnimBool, anim);
    }
  }*/

  draw(d: Drawable) {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrCol != -1 && d.bindCol()) {
      gl.enableVertexAttribArray(this.attrCol);
      gl.vertexAttribPointer(this.attrCol, 4, gl.FLOAT, false, 0, 0);
      //gl.vertexAttribDivisor(this.attrTranslate, 1); // Advance 1 index in translate VBO for each drawn instance
    }

    if (this.attrTranslate != -1 && d.bindTranslate()) {
      gl.enableVertexAttribArray(this.attrTranslate);
      gl.vertexAttribPointer(this.attrTranslate, 3, gl.FLOAT, false, 0, 0);
      gl.vertexAttribDivisor(this.attrTranslate, 1); // Advance 1 index in translate VBO for each drawn instance
    }

    if (this.attrUV != -1 && d.bindUV()) {
      gl.enableVertexAttribArray(this.attrUV);
      gl.vertexAttribPointer(this.attrUV, 2, gl.FLOAT, false, 0, 0);
      gl.vertexAttribDivisor(this.attrUV, 0); // Advance 1 index in pos VBO for each vertex
    }
    if (this.attrTransform1 != -1 && d.bindTransform1()) {
      gl.enableVertexAttribArray(this.attrTransform1);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform1, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform1, 1);
    }
    if (this.attrTransform2 != -1 && d.bindTransform2()) {
      gl.enableVertexAttribArray(this.attrTransform2);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform2, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform2, 1);
    }
    if (this.attrTransform3 != -1 && d.bindTransform3()) {
      gl.enableVertexAttribArray(this.attrTransform3);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform3, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform3, 1);
    }
    if (this.attrTransform4 != -1 && d.bindTransform4()) {
      gl.enableVertexAttribArray(this.attrTransform4);
      // Passes in vec4s
      gl.vertexAttribPointer(this.attrTransform4, 4, gl.FLOAT, false, 0, 0);
      // Advances 1 index in transform VBO for each drawn instance
      gl.vertexAttribDivisor(this.attrTransform4, 1);
    }

    d.bindIdx();
    gl.drawElements(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0);
    //gl.drawElementsInstanced(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0, d.numInstances);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);

    if (this.attrCol != -1) gl.disableVertexAttribArray(this.attrCol);
    if (this.attrTranslate != -1) gl.disableVertexAttribArray(this.attrTranslate);
    if (this.attrTransform1 != -1) gl.disableVertexAttribArray(this.attrTransform1);
    if (this.attrTransform2 != -1) gl.disableVertexAttribArray(this.attrTransform2);
    if (this.attrTransform3 != -1) gl.disableVertexAttribArray(this.attrTransform3);
    if (this.attrTransform4 != -1) gl.disableVertexAttribArray(this.attrTransform4);
    if (this.attrUV != -1) gl.disableVertexAttribArray(this.attrUV);
  }
};

export default ShaderProgram;

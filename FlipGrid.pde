import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;
import java.util.*;

Grid grid;
PhotoLoader loader;

static final int VISIT_MODE = 0;
static final int WIDE_MODE = 1;
static final int CASCADE_MODE = 2;
static final int PAN_MODE = 3;
int mode = WIDE_MODE;

static final int ROWS = 20;
static final int COLS = 12;

PFont debugFont;

GLGraphics renderer;

void setup() {
  //size(1080/2, 1920/2, GLConstants.GLGRAPHICS);
  size(screen.width,screen.height-1, GLConstants.GLGRAPHICS);
  //smooth();
  frameRate(60);

  //grid = new Grid(this, 6, 10);
  grid = new Grid(this, ROWS, COLS);
  loader = new PhotoLoader(this);
  
  // Stop tearing
  GLGraphics pgl = (GLGraphics) g; //processing graphics object
  GL gl = pgl.beginGL(); //begin opengl
  gl.setSwapInterval(1); //set vertical sync on
  pgl.endGL(); //end opengl
  
  debugFont = createFont("Courier-Bold", 24);
  textFont(debugFont);
  
  //perspective(PI/6, width/(float)height, cameraZ/10.0, cameraZ*10.0);
}

void draw() {
  renderer = (GLGraphics)g;
  renderer.beginGL();
    //GL gl = renderer.gl;
    //println(frameRate);
    background(0);
    grid.update();
    loader.update();
    grid.draw();
  renderer.endGL();
  
  fill(0,0,0,80);
  rectMode(CORNER);
  rect(0,0,200,50);
  fill(255);
  text((int)frameRate, 20,20);
}

void keyPressed() {
  if(key == ' ') {
    //if(mode == WIDE_MODE) mode = VISIT_MODE;
    //else if(mode == VISIT_MODE) mode = WIDE_MODE;
    toggleVisit();
  }  
}

void toggleVisit() {
  if(mode != VISIT_MODE) {
    grid.startVisit = new PVector(grid.center.x, grid.center.y, grid.zoom);
    grid.visitStep = 0;
    mode = VISIT_MODE;
  }  
  else {
    grid.startVisit = new PVector(grid.center.x, grid.center.y, grid.zoom);
    grid.visitStep = 0;
    grid.nextVisit = new PVector(0,0,1);
    mode = WIDE_MODE;
  }
}

void mouseDragged() {
  if(mouseButton == LEFT) {
    grid.centerTarget.x -= (mouseX-pmouseX) / grid.zoom;
    grid.centerTarget.y -= (mouseY-pmouseY) / grid.zoom;
  }
  else if(mouseButton == RIGHT) {
    grid.zoomTarget += (mouseY-pmouseY)/10.*grid.zoom;  
  }
}

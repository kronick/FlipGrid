import processing.opengl.*;
import
codeanticode.glgraphics.*;
import javax.media.opengl.*;
import java.util.*;

Grid grid;
PhotoLoader loader;

static final int VISIT_MODE = 0;
static final int WIDE_MODE = 1;
static final int CASCADE_MODE = 2;
static final int PAN_MODE = 3;
int mode = WIDE_MODE;

static final int ROWS = 12;
static final int COLS = 20;

PFont debugFont;
PFont creatorsFont;

GLGraphics renderer;

boolean transitionSoon = false;
boolean transitioned = false;

int hashtagStep = 0;
static final int HASHTAG_FADE_TIME = 960;
int hashtagPosition = 0;

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
  creatorsFont = createFont("Helvetica-Bold", 200);
  textFont(debugFont);
  
  noCursor();
  
  //perspective(PI/6, width/(float)height, cameraZ/10.0, cameraZ*10.0);
}

void draw() {
  // UPDATE
  // ======================
  if(second() == 0 && !transitioned) {
    transitionSoon = true;
    transitioned = true;
  }
  if(second() > 0) {
    transitioned = false;
  }
  
  handleModes();
  
  // DRAW
  // ======================
  renderer = (GLGraphics)g;
  renderer.beginGL();
    //GL gl = renderer.gl;
    //println(frameRate);
    background(0);
    grid.update();
    loader.update();
    grid.draw();
  renderer.endGL();
  
  /*
  fill(0,0,0,80);
  rectMode(CORNER);
  rect(0,0,200,50);
  fill(255);
  text((int)frameRate, 20,20);
  */
 
  hashtagStep++;
  if(hashtagStep > HASHTAG_FADE_TIME*2) {
    hashtagStep = 0;
    hashtagPosition = (int)random(0,4); 
  }
  
  if(hashtagStep < HASHTAG_FADE_TIME) {
  
    //float alpha = (sin(frameCount/50.)+2)*60;
    float alpha = 0;
    if(hashtagStep < 360)
      alpha = tweenEaseInOut(hashtagStep, 360, 0, 200);
    else if(hashtagStep < HASHTAG_FADE_TIME-360)  
      alpha = 200;
    else
      alpha = tweenEaseInOut(HASHTAG_FADE_TIME-hashtagStep, 360, 0, 200);
      
    textFont(creatorsFont);
    
    pushMatrix();
    switch(hashtagPosition) {
      case 0:
        translate(150, height);
        rotate(radians(-90));
        break;
      case 1:
        translate(width, height);
        rotate(radians(-90));      
        break;
      case 2:
        translate(0,150);
        break;
      case 3:
      default:
        translate(width-textWidth(" #creators"), height);
        break;
    }
    
    fill(0,0,0, alpha);
    rectMode(CORNER);
    rect(0,150*.1, textWidth(" #creators"), -150*1.1);
    
    fill(255,255,255,alpha);
    text(" #creators", 0,0);
    popMatrix();
  }

}

void keyPressed() {
  if(key == ' ') {
    //if(mode == WIDE_MODE) mode = VISIT_MODE;
    //else if(mode == VISIT_MODE) mode = WIDE_MODE;
    transitionSoon = true;
  }  
  if(key == '1') hashtagPosition = 0;
  if(key == '2') hashtagPosition = 1;
  if(key == '3') hashtagPosition = 2;
  if(key == '4') hashtagPosition = 3;
}

void handleModes() {
  if(transitionSoon && !grid.inTransit) {
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
    transitionSoon = false;
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

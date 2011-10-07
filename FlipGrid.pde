import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;

Grid grid;

void setup() {
  //size(1080/2, 1920/2, GLConstants.GLGRAPHICS);
  size(1200,1920, GLConstants.GLGRAPHICS);
  //smooth();
  frameRate(60);
  
  grid = new Grid(this, 5 ,3);
  //perspective(PI/6, width/(float)height, cameraZ/10.0, cameraZ*10.0);
}

void draw() {
  //GLGraphics renderer = (GLGraphics)g;
  //renderer.beginGL();
  //GL gl = renderer.gl;
  
  background(0);
  grid.update();
  grid.draw();
  
  //renderer.endGL();
}

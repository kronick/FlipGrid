import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;

Grid grid;

void setup() {
  //size(1080/2, 1920/2, GLConstants.GLGRAPHICS);
  size(screen.width,screen.height-1, GLConstants.GLGRAPHICS);
  //smooth();
  frameRate(60);
  hint(ENABLE_ACCURATE_TEXTURES);
  
  
  grid = new Grid(this, 10 ,6);
  //perspective(PI/6, width/(float)height, cameraZ/10.0, cameraZ*10.0);
}

void draw() {
  //GLGraphics renderer = (GLGraphics)g;
  //renderer.beginGL();
  //GL gl = renderer.gl;
  //println(frameRate);
  background(0);
  grid.update();
  grid.draw();
  
  //renderer.endGL();
}

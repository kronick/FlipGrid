import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;


Grid grid;
PhotoLoader loader;

void setup() {
  //size(1080/2, 1920/2, GLConstants.GLGRAPHICS);
  size(screen.width,screen.height-1, GLConstants.GLGRAPHICS);
  //smooth();
  frameRate(60);

  grid = new Grid(this, 6, 10);
  loader = new PhotoLoader(this);
  
  //perspective(PI/6, width/(float)height, cameraZ/10.0, cameraZ*10.0);
}

void draw() {
  //GLGraphics renderer = (GLGraphics)g;
  //renderer.beginGL();
  //GL gl = renderer.gl;
  //println(frameRate);
  background(0);
  grid.update();
  loader.update();
  grid.draw();
  
  //renderer.endGL();
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

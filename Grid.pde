class Grid {
  int rows, cols;
  Photo photos[][];
  float gridSpace;
  PApplet parent;
  
  Grid(PApplet _parent, int _rows, int _cols) {
    this.parent = _parent;
    this.rows = _rows;
    this.cols = _cols;
    
    photos = new Photo[rows][cols];
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        photos[i][j] = new Photo(this, "");
      }
    }
    if(rows / (float)cols > height / (float)width) {
      // Limiting space is height  
      gridSpace = height/(float)rows;
    }
    else {
      // Limiting space is width
      gridSpace = width/(float)cols;
    }
    
  }
  
  void update() {
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        photos[i][j].update();
      }
    }
  }
  
  void draw() {
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        noFill();
        stroke(255,0,128);
        
        rectMode(CORNER);
        rect(j*gridSpace, i*gridSpace, gridSpace, gridSpace);
        
        pushMatrix();
          translate((j + .5) * gridSpace, (i + .5) * gridSpace);
          photos[i][j].draw();
        popMatrix();
      } 
    } 
  }
}

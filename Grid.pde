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
        if(!photos[i][j].zooming && !photos[i][j].flipping) {
          pushMatrix();
            translate((j + .5) * gridSpace, (i + .5) * gridSpace);
            photos[i][j].draw();
          popMatrix();
        }
      } 
    } 
    
    // Flipping
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        if(photos[i][j].flipping && !photos[i][j].zooming) {
          pushMatrix();
            translate((j + .5) * gridSpace, (i + .5) * gridSpace);
            photos[i][j].draw();
          popMatrix();
        }
      } 
    } 
    
    // Zooming
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        if(photos[i][j].zooming) {
          pushMatrix();
            translate((j + .5) * gridSpace, (i + .5) * gridSpace);
            photos[i][j].draw();
          popMatrix();
        }
      } 
    }     
  }
  
  int[] getPosition(Photo p) {
    int[] foundIndex = {-1,-1};
    boolean found = false;
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        if(!found && p == photos[i][j]) {
          foundIndex[0] = i;
          foundIndex[1] = j;
          found = true;
        }
      }
    }
    
    return foundIndex;
  }
  
  boolean canZoom(Photo p) {
    int[] index = getPosition(p);
    int row = index[0];
    int col = index[1];
    
    if(row == 0 || col == 0 || row == rows-1 || col == cols-1)  
      return false;
    
    boolean clear = true;
    int checked = 0;
    for(int i=row-2; i<=row+2; i++) {
      for(int j=row-2; j<=row+2; j++) {
        checked++;
        if(clear && i >= 0 && i < rows && j >=0 && j < cols) {
          
          if(photos[i][j].zooming) clear = false;
        }
      }
    }
      
      println(checked);
    return clear;
  }
}

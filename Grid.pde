class Grid {
  int rows, cols;
  GridPhoto photos[][];
  float gridSpace;
  FlipGrid parent;
  
  PVector center;
  PVector centerTarget;
  float zoom;
  float zoomTarget;
  float zoomK = 0.02;
  float centerK = 0.02;
  
  Grid(FlipGrid _parent, int _rows, int _cols) {
    this.parent = _parent;
    this.rows = _rows;
    this.cols = _cols;
    
    center = new PVector(0,0);
    centerTarget = new PVector(0,0);
    zoom = 2;
    zoomTarget = 1;
    
    photos = new GridPhoto[rows][cols];
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        photos[i][j] = new GridPhoto(this, "");
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
    
    if(zoomTarget < 0.1) zoomTarget = 0.1;
    zoom += (zoomTarget - zoom) * zoomK;
    center.x += (centerTarget.x - center.x) * centerK;
    center.y += (centerTarget.y - center.y) * centerK;
  }
  
  void draw() {
    //zoom = cos(radians(frameCount))+2;
    //zoom = 2;
    //center = new PVector(100*cos(radians(frameCount)), 100*sin(radians(frameCount)));
    
    pushMatrix();
      translate(width/2, height/2);
      scale(zoom);
      translate(-width/2, -height/2);
      translate(-center.x, -center.y);
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
    
    popMatrix();
  }
  
  int[] getPosition(GridPhoto p) {
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
  
  GridPhoto randomPhoto() { return randomPhoto(0, false); }
  GridPhoto randomPhoto(int ageThreshold, boolean zoomableOnly) {
    // Build a list of photos that are old enough
    ArrayList<GridPhoto> elligiblePhotos = new ArrayList<GridPhoto>();
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        if(photos[i][j].age > ageThreshold && (!zoomableOnly || canZoom(photos[i][j])))
          elligiblePhotos.add(photos[i][j]);
      }
    }
    
    if(elligiblePhotos.size() > 0)
      return elligiblePhotos.get((int)random(0,elligiblePhotos.size()));
    else return null;
  }
  
  PVector getCenter(GridPhoto p) {
    int[] index = getPosition(p);
    return new PVector((index[1]+0.5)*gridSpace-width/2, (index[0]+0.5)*gridSpace-height/2);
  }
  
  boolean canZoom(GridPhoto p) {
    int[] index = getPosition(p);
    int row = index[0];
    int col = index[1];
    
    if(row == 0 || col == 0 || row == rows-1 || col == cols-1)  
      return false;
    
    boolean clear = true;
    for(int i=row-2; i<=row+2; i++) {
      for(int j=col-2; j<=col+2; j++) {
        if(clear && i >= 0 && i < rows && j >=0 && j < cols) {
          if(photos[i][j].zooming) { clear = false; }
        }
      }
    }
    
    return clear;
  }
}

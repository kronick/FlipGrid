class Grid {
  int rows, cols;
  GridPhoto photos[][];
  float gridSpace;
  FlipGrid parent;
  
  PVector center;
  PVector centerTarget;
  PVector velocity;
  static final float MAX_SPEED = 5;
  float zoom;
  float zoomTarget;
  float zoomK = 0.1;//0.002;
  float centerK = 0.1;//0.002;
  float linearDamping = 0.85;
  
  PVector focusTarget;
  float focusZoom;
  
  int cascadePhase = 0;
  
  Stack<PVector> visitQueue;
  Stack<PVector> visitPriorityQueue;
  PVector nextVisit;
  PVector startVisit;
  int visitStep = 0;
  int visitTimer = 0;
  static final int VISIT_DURATION = 300;  // Time between photo visits
  static final int VISIT_LENGTH = 500;  // Amount to dwell on visited photo within threshold  
  boolean inTransit = false;  // Set to true while moving to the next photo to visit
  static final float VISIT_THRESH = 10;  // Max distance from visiting photo to start timer
  
  Grid(FlipGrid _parent, int _rows, int _cols) {
    this.parent = _parent;
    this.rows = _rows;
    this.cols = _cols;
    
    center = new PVector(0,0);
    centerTarget = new PVector(0,0);
    velocity = new PVector(0,0,0);
    focusTarget = centerTarget.get();
    zoom = 2;
    zoomTarget = 1;
    focusZoom = zoomTarget;
    
    visitQueue = new Stack<PVector>();
    visitPriorityQueue = new Stack<PVector>();
    nextVisit = null;
    startVisit = centerTarget.get();
    
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
    if(frameCount % 10 == 0)
      cascadePhase++;
    if(cascadePhase >= rows*cols) cascadePhase = 0;
    
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        /*if(parent.mode == CASCADE_MODE && cascadePhase%cols == j &&
           (int)cascadePhase/cols == i) {
          String u = parent.loader.randomPhoto();
          if(u != null && !photos[i][j].flipping && !photos[i][j].backLoading &&
             !photos[i][j].frontLoading)
            photos[i][j].changeImage(u);     
        }*/
        photos[i][j].update();
      }
    }
    
    if(parent.mode == VISIT_MODE || parent.mode == WIDE_MODE) {
      if(nextVisit != null) {
        centerTarget = new PVector(tweenEaseInOutBack(visitStep, VISIT_DURATION, startVisit.x, nextVisit.x, 0.4),
                                   tweenEaseInOutBack(visitStep, VISIT_DURATION, startVisit.y, nextVisit.y,0.4));
        zoomTarget = tweenEaseInOutBack(visitStep, VISIT_DURATION, startVisit.z, nextVisit.z);
        
        if(visitStep >= VISIT_DURATION) {
          // Pausing on one photo
          visitTimer++;
          inTransit = false;          
        }
        else {
          // Moving to the next photo
          visitStep++;
          inTransit = true;
        }
      }
      if(nextVisit == null || visitTimer > VISIT_LENGTH) {
        // Grab the next target from the queue
        if(mode == VISIT_MODE) {
          PVector _next = visitPriorityQueue.size() > 0 ? visitPriorityQueue.pop() : 
                          visitQueue.size() > 0 ? visitQueue.pop() : null;         
          if(_next != null) {
            if(nextVisit != null) startVisit = nextVisit.get();
            nextVisit = _next.get();
            visitStep = 0;
            visitTimer = 0;  
          } 
        }
      }
      
    }
    else if(parent.mode == WIDE_MODE) {
      zoomTarget = 1;
      centerTarget = new PVector(0,0);
    }
    
    if(zoomTarget < 0.1) zoomTarget = 0.1;
    
    center.x += (centerTarget.x - center.x) * centerK;
    center.y += (centerTarget.y - center.y) * centerK;    
    zoom += (zoomTarget - zoom) * zoomK;
  }
  
  void draw() {    
    pushMatrix();
      translate(width/2, height/2);
      scale(zoom);
      translate(-width/2, -height/2);
      translate(-center.x, -center.y);
      for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
          if(!photos[i][j].zooming && !photos[i][j].flipping) {
            drawPhoto(i, j);
          }
        } 
      } 
      
      // Flipping
      for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
          if(photos[i][j].flipping && !photos[i][j].zooming) {
            drawPhoto(i, j);
          }
        } 
      } 
      
      // Zooming
      for(int i=0; i<rows; i++) {
        for(int j=0; j<cols; j++) {
          if(photos[i][j].zooming) {
            drawPhoto(i, j);
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
  
  GridPhoto emptyPhoto() {
    ArrayList<GridPhoto> elligible = new ArrayList<GridPhoto>();
    for(int i=0; i<rows; i++) {
      for(int j=0; j<cols; j++) {
        if(photos[i][j].backImage == null || photos[i][j].frontImage == null)
          elligible.add(photos[i][j]);
      }
    }
    
    if(elligible.size() > 0)
      return elligible.get((int)random(0,elligible.size()));
    else return null;
  }
  
  PVector getCenter(GridPhoto p) {
    int[] index = getPosition(p);
    return new PVector((index[1]+0.5)*gridSpace-width/2, (index[0]+0.5)*gridSpace-height/2);
  }
  
  PVector[] viewportCorners() {
    PVector[] out = {new PVector(0,0), new PVector(width,height) };
    
    for(int i=0; i<2; i++) {
      out[i].sub(new PVector(width/2,height/2));
      out[i].div(zoom);
      out[i].add(new PVector(width/2, height/2));
      out[i].add(center);
    }
    
    return out;  
  }

  void drawPhoto(int i, int j) {
    for(int tileX = -1; tileX <= 1; tileX++) {
      for(int tileY = -1; tileY <= 1; tileY++) {
        int row = i+tileY*rows;
        int col = j+tileX*cols;
        
        pushMatrix();
          if(isVisible(row,col)) {
            translate((col + .5) * gridSpace, (row + .5) * gridSpace);
            photos[i][j].draw();
          }
        popMatrix();        
      }
    }
  }
  
  boolean isVisible(int row, int col) {
    int i = row;
    int j = col;
    while(i < 0) i += rows;
    while(j < 0) j += cols;
    while(i >= rows) i -= rows;
    while(j >= cols) j -= cols;
    
    //if(row >= rows || col >= cols || row < 0 || col < 0) return false;
    
    GridPhoto p = photos[i][j];
    float size = (p.zooming ? GridPhoto.MAX_ZOOM : 1) / 2;
    PVector[] corners = {new PVector((col+0.5-size)*gridSpace, (row+0.5-size)*gridSpace),
                         new PVector((col+0.5+size)*gridSpace, (row+0.5-size)*gridSpace),
                         new PVector((col+0.5+size)*gridSpace, (row+0.5+size)*gridSpace),
                         new PVector((col+0.5-size)*gridSpace, (row+0.5+size)*gridSpace),
                         new PVector((col+0.5)*gridSpace, (row+0.5)*gridSpace)};
                         
    boolean result = false;
    
    for(int idx=0; idx<corners.length; idx++) {
      if(isVisible(corners[idx])) result = true;
    }
    
    return result;
  }
  
  boolean isVisible(PVector p) {
    PVector[] corners = viewportCorners();
    return p.x >= corners[0].x && p.x <= corners[1].x &&
           p.y >= corners[0].y && p.y <= corners[1].y;
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

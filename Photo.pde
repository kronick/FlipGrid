class GridPhoto implements Runnable {
  String frontURL, backURL;
  String nextURL;
  GLTexture frontTexture, backTexture;
  PImage frontImage, backImage;
  boolean backWaiting, frontWaiting;
  
  boolean frontLoaded = false;
  boolean backLoaded = false;
  boolean backLoading = false;
  boolean frontLoading = false;
  
  int side = 1;
  
  Grid parent;

  int age = 1;
  int flipStep = 0;
  float angleY = 0;
  float angleX = 0;
  boolean flipping = false;
  boolean flipSoon = false;  // If true, will flip at next possible chance (after other side is loaded)
  int flipDirection;
  
  boolean zooming = false;
  boolean zoomOnLoad = false;
  boolean zoomSoon = false;  // If true, will zoom at the next possible chance.
  int zoomStep = 0;
  float zoomLevel = 1;
  int zoomDirection = 1;
  static final float MAX_ZOOM = 3;
  static final int ZOOM_TIME = 1440;
  
  static final float PERSPECTIVE_FACTOR = 0.2;
  
  static final float RANDOM_ZOOM_CHANCE = -1;
  static final float RANDOM_FLIP_CHANCE = -1;
  
  GridPhoto(Grid _parent, String _url) {
     this.parent = _parent;
     this.frontURL = _url;
     
     frontTexture = new GLTexture(parent.parent, "default.jpg");
     frontLoaded = true;
     backTexture = new GLTexture(parent.parent);
     
     frontWaiting = false;
     backWaiting = false;
     
     
  } 
  
  void update() {
    // TRANSFER TEXTURE
    // ----------------
    if(frontWaiting) {
      frontTexture.init(frontImage.width, frontImage.height);
      frontTexture.putImage(frontImage);
      frontWaiting = false;
    }
    if(backWaiting) {
      backTexture.init(backImage.width, backImage.height);
      backTexture.putImage(backImage);
      backWaiting = false;
    }
    
    age++;    

    if(!flipping && !zooming && (random(0,1) < RANDOM_FLIP_CHANCE || flipSoon))
      triggerFlip();

    if(!flipping && !zooming && (random(0,1) < RANDOM_ZOOM_CHANCE || zoomSoon))
      triggerZoom();
    
    // FLIP STUFF
    // ----------
    if(flipping) {
      flipStep += flipDirection*3;
      zoomDirection = zoomLevel >= MAX_ZOOM ? -1 : 1;
    }
    if(flipStep >= 180 || flipStep <= 0) {
      // Stop flipping if at 180 or 0 degrees
      flipping = false;
    }
    
    // Figure out which side is showing
    if(flipStep >= 90) side = -1;
    else side = 1;
    
    angleY = (cos(radians(flipStep))+1)/2*180 - 180;  // Ease in-out
    
    // ZOOM STUFF
    // ----------
    if(zooming) {
      zoomStep += zoomDirection * 3;
    }
    if(zoomLevel <= MAX_ZOOM && zoomStep <= 180)
      zoomLevel = (-cos(radians(zoomStep))+1)/2 * (MAX_ZOOM-1) + 1;
    else zoomLevel = MAX_ZOOM;
    
    if(zoomStep > ZOOM_TIME) {
      zoomDirection = -1;
      zoomStep = 180;
    }
    if(zoomLevel <= 1) {
      zooming = false;
      zoomLevel = 1;
      zoomStep = 0;
      zoomDirection = 1;
    }
    
    //println(zoomLevel);
  }
  
  void draw() {
    textureMode(NORMALIZED);
    
    noStroke();
    //stroke(255);
    fill(255,255,255,100);
    float a = cos(radians(angleY));
    float b = sin(radians(angleY));
    
    //scale(zoomLevel);
    
    beginShape(TRIANGLE_FAN);
    
    texture(side > 0 ? frontTexture : backTexture);
    float g = -parent.gridSpace/2 * zoomLevel;
    
    int X1 = side > 0 ? 0 : 1;
    int X2 = side > 0 ? 1 : 0;
    
    vertex(0,0, 0.5, 0.5);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, X1,0);
    vertex( g*a, -g + b*g*PERSPECTIVE_FACTOR, X1,1);
    vertex(-g*a, -g - b*g*PERSPECTIVE_FACTOR, X2,1);
    vertex(-g*a,  g + b*g*PERSPECTIVE_FACTOR, X2,0);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, X1,0);
    
    endShape(CLOSE);
    
    //if(zoomSoon) {
    //  fill(0,255,0);
    //  ellipse(0,0, 10,10);
    //}
  }
  
  void triggerFlip() { triggerFlip(false); }
  void triggerFlip(boolean force) {
    if(force || (side > 0 && backLoaded) || (side < 0 && frontLoaded)) {  // Only trigger a flip if the other side is available
      flipping = true; 
      flipDirection = flipStep > 0 ? -1 : 1;
      flipSoon = false;
    }
  }
  
  void triggerZoom() { triggerZoom(false); }
  void triggerZoom(boolean force) {
    if(force || parent.canZoom(this)) {
      zooming = true;
      zoomSoon = false;  // Reset
    }
  }
  
  void downloadNextImage(String _url) {
    this.nextURL = _url;
    Thread t = new Thread(this);
    t.start();
  }
  
  void changeImage(String _url, boolean _zoomOnLoad) {
    flipSoon = true;
    zoomOnLoad = _zoomOnLoad;
    downloadNextImage(_url);
    if(zoomSoon) println("Zooming now.");
    age = 0;
    
    grid.centerTarget = grid.getCenter(this);
    grid.zoomTarget = random(.75,2);
  }
  
  void run() {
    if(side > 0 && !backLoading) {
      backLoaded = false;
      backLoading = true;
      backImage = loadImage(nextURL);
      backWaiting = true;  // Ready to be transfered to GLTexture on main thread
      backLoaded = true; 
      backLoading = false;  
      if(zoomOnLoad) zoomSoon = true;
      zoomOnLoad = false; 
    }
    else if(side < 0 && !frontLoading) {
      frontLoaded = false;
      frontLoading = true;
      frontImage = loadImage(nextURL);
      frontWaiting = true; // Ready to be transfered to GLTexture on main thread
      frontLoaded = true; 
      frontLoading = false; 
      
      if(zoomOnLoad) zoomSoon = true;
      zoomOnLoad = false; 
    }
  }
  
}


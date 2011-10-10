class GridPhoto implements Runnable {
  String frontURL, backURL;
  String nextURL;
  GLTexture frontTexture, backTexture;
  GLModel texturedQuad;
  
  PImage frontImage, backImage;
  boolean backWaiting, frontWaiting;
  
  boolean frontLoaded = false;
  boolean backLoaded = false;
  boolean backLoading = false;
  boolean frontLoading = false;
  
  int side = 1;
  int lastSide = 1;
  
  Grid parent;

  int age = 1;
  int flipStep = 0;
  float angleY = 0;
  float angleX = 0;
  boolean flipping = false;
  boolean flipSoon = false;  // If true, will flip at next possible chance (after other side is loaded)
  int flipDirection;
  static final float FLIP_SPEED = 2;
  
  boolean zooming = false;
  boolean zoomOnLoad = false;
  boolean zoomSoon = false;  // If true, will zoom at the next possible chance.
  int zoomStep = 0;
  float zoomLevel = 1;
  int zoomDirection = 1;
  static final float MAX_ZOOM = 3;
  static final int ZOOM_TIME = 3000;
  
  static final float PERSPECTIVE_FACTOR = 0.2;
  
  static final float RANDOM_ZOOM_CHANCE = 0.0001;
  static final float RANDOM_FLIP_CHANCE = -1;
  static final float RANDOM_RELOAD_CHANCE = 0.0001;
  static final float RANDOM_VISIT_CHANCE = 0.5;
  
  static final float VISIT_ZOOM_MIN = 1;
  final float VISIT_ZOOM_MAX = ROWS/3.;
  
  GridPhoto(Grid _parent, String _url) {
     this.parent = _parent;
     this.frontURL = _url;
     
     texturedQuad = new GLModel(parent.parent, 6, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC);
     setVertices();
     texturedQuad.initTextures(1);  // Reserve room for 1 texture on the graphics card
     
     GLTextureParameters texParam = new GLTextureParameters();
     texParam.magFilter = GLTextureParameters.LINEAR;
     texParam.minFilter = GLTextureParameters.LINEAR;
     
     frontTexture = new GLTexture(parent.parent, "default.jpg", texParam);
     //println(frontTexture.usingMipmaps() + " using mipmaps");
     frontLoaded = true;
     backTexture = new GLTexture(parent.parent, "default.jpg", texParam);
     texturedQuad.setTexture(0, frontTexture);
     
     setTexCoords();  
     
     /*
     texturedQuad.initColors();
     texturedQuad.beginUpdateColors();
     for (int i = 0; i < 6; i++) {
       texturedQuad.updateColor(i, random(0, 255), random(0, 255), random(0, 255), 225);
     }
     texturedQuad.endUpdateColors();        
     */
     
     frontWaiting = false;
     backWaiting = false;
     
     update();
     setVertices();
     
  } 
  
  void update() {
    // TRANSFER TEXTURE
    // ----------------
    if(frontWaiting) {
      try {
        frontTexture.init(frontImage.width, frontImage.height);
        frontTexture.putImage(frontImage);
        frontWaiting = false;
      }
      catch(Exception e) {
        println(e); 
      }
    }
    if(backWaiting) {
      try {
        backTexture.init(backImage.width, backImage.height);
        backTexture.putImage(backImage);
        backWaiting = false;
      
      }
      catch(Exception e) {
        println(e); 
      }      
    }
    
    age++;    

    if(!flipping && !zooming && (random(0,1) < RANDOM_FLIP_CHANCE || flipSoon))
      triggerFlip();

    if(!flipping && !zooming && (random(0,1) < RANDOM_ZOOM_CHANCE || zoomSoon))
      triggerZoom();
    
    if(!flipping && random(0,1) < RANDOM_RELOAD_CHANCE) {
      String u = parent.parent.loader.randomPhoto();
      if(u != null)
        changeImage(u);  
    }    
    
    // FLIP STUFF
    // ----------
    // Try to flip if the other side is loaded
    if(flipping && !(flipDirection < 0 && backLoading) &&
                   !(flipDirection > 0 && frontLoading)) {
      flipStep += flipDirection*FLIP_SPEED;
      zoomDirection = zoomLevel >= MAX_ZOOM ? -1 : 1;
    }
    if(flipStep >= 180 || flipStep <= 0) {
      // Stop flipping if at 180 or 0 degrees
      flipping = false;
    }
    
    // Figure out which side is showing
    // --------------------------------
    if(flipStep >= 90) side = -1;
    else side = 1;
    
    if(side != lastSide)
      // Update texture coordinates to flip if necessary
      setTexCoords();    
 
    lastSide = side;
    
    //angleY = (cos(radians(flipStep))+1)/2*180 - 180;  // Ease in-out
    angleY = tweenEaseInOutBack(flipStep, 180, 0, 180, 0.5);
    
    // ZOOM STUFF
    // ----------
    if(zooming) {
      zoomStep += zoomDirection * 3;
    }
    if(zoomStep <= 180)
      //zoomLevel = (-cos(radians(zoomStep))+1)/2 * (MAX_ZOOM-1) + 1;
      zoomLevel = tweenEaseInOutBack(zoomStep, 180, 1, MAX_ZOOM, 0.5);
    else zoomLevel = MAX_ZOOM;
    
    if(zoomStep > ZOOM_TIME) {
      zoomDirection = -1;
      zoomStep = 180;
    }
    if(zoomStep <= 0) {
      zooming = false;
      zoomLevel = 1;
      zoomStep = 0;
      zoomDirection = 1;
    }
    
    if(flipping || zooming)
      setVertices();
  }
  
  void setTexCoords() {
    // Choose texture
    texturedQuad.setTexture(0, side > 0 ? frontTexture : backTexture);
    
    int X1 = side > 0 ? 0 : 1;
    int X2 = side > 0 ? 1 : 0;
    texturedQuad.beginUpdateTexCoords(0);
      texturedQuad.updateTexCoord(0, 0.5,0.5);
      texturedQuad.updateTexCoord(1, X1,0);
      texturedQuad.updateTexCoord(2, X1,1);
      texturedQuad.updateTexCoord(3, X2,1);
      texturedQuad.updateTexCoord(4, X2,0);
      texturedQuad.updateTexCoord(5, X1,0);
    texturedQuad.endUpdateTexCoords();  
  }
  
  void setVertices() {
    float a = cos(radians(angleY));
    float b = sin(radians(angleY)); 
    float g = -parent.gridSpace/2 * zoomLevel;
    
    texturedQuad.beginUpdateVertices();
      texturedQuad.updateVertex(0, 0,0);  // Center point
      texturedQuad.updateVertex(1, g*a,  g - b*g*PERSPECTIVE_FACTOR);
      texturedQuad.updateVertex(2, g*a, -g + b*g*PERSPECTIVE_FACTOR);
      texturedQuad.updateVertex(3, -g*a, -g - b*g*PERSPECTIVE_FACTOR);
      texturedQuad.updateVertex(4, -g*a,  g + b*g*PERSPECTIVE_FACTOR);
      texturedQuad.updateVertex(5, g*a,  g - b*g*PERSPECTIVE_FACTOR); 
    texturedQuad.endUpdateVertices();
  }
  
  void draw() {
    textureMode(NORMALIZED);
    
    noStroke();
    //stroke(255);
    fill(255,255,255,100);
    
    texturedQuad.render();
    //parent.parent.renderer.model(texturedQuad);
    
    /*
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
    */
    
      
    //if(zoomSoon) {
    //  fill(0,255,0);
    //  ellipse(0,0, 10,10);
    //}
  }
  
  void triggerFlip() { triggerFlip(false); }
  void triggerFlip(boolean force) {
    //if(force || (side > 0 && backLoaded) || (side < 0 && frontLoaded)) {  // Only trigger a flip if the other side is available
    if(force || (backLoaded && frontLoaded)) {
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
      
      if(random(0,1) < RANDOM_VISIT_CHANCE)
        visitMe();
    }
  }
  
  void downloadNextImage(String _url) {
    this.nextURL = _url;
    Thread t = new Thread(this);
    t.start();
  }
  
  void changeImage(String _url) {
    changeImage(_url, false);
  }
  
  void changeImage(String _url, boolean _zoomOnLoad) {
    flipSoon = true;
    zoomOnLoad = _zoomOnLoad;
    
    downloadNextImage(_url);
    age = 0;
    
    if(zoomOnLoad) visitMe();
    
    //parent.focusTarget = grid.getCenter(this);
    //parent.focusZoom = random(.75,2);
  }
  
  void visitMe() {
    parent.visitQueue.push(new PVector(parent.getCenter(this).x,
                                        parent.getCenter(this).y,
                                        random(VISIT_ZOOM_MIN, VISIT_ZOOM_MAX)));
  }
  
  void run() {
    try {
      while(flipping) Thread.sleep(10);  // Wait until flipping is done
    }
    catch(InterruptedException e) { }
    
    // Reserve the next photo to be loaded
    int newIndex = parent.parent.loader.photoStack.indexOf(nextURL);
    if(newIndex > -1)
      parent.parent.loader.availability.set(newIndex, false);// = Boolean.FALSE;

    if(side > 0 && !backLoading) {
      // Currently on front, transition to back
      backLoaded = false;
      backLoading = true;
      backImage = loadImage(nextURL);
      backWaiting = true;  // Ready to be transfered to GLTexture on main thread
      backLoaded = true; 
      backLoading = false;  
      if(zoomOnLoad) zoomSoon = true;
      zoomOnLoad = false; 
      
      // Free up the old photo so another space can use it
      int oldIndex = parent.parent.loader.photoStack.indexOf(frontURL);
      if(oldIndex > -1)
        parent.parent.loader.availability.set(oldIndex, true);
        
      backURL = nextURL;
    }
    else if(side < 0 && !frontLoading) {
      // Currently on back, transition to front
      frontLoaded = false;
      frontLoading = true;
      frontImage = loadImage(nextURL);
      frontWaiting = true; // Ready to be transfered to GLTexture on main thread
      frontLoaded = true; 
      frontLoading = false; 
      
      if(zoomOnLoad) zoomSoon = true;
      zoomOnLoad = false; 
      
      // Free up the old photo so another space can use it
      int oldIndex = parent.parent.loader.photoStack.indexOf(backURL);
      if(oldIndex > -1)
        parent.parent.loader.availability.set(oldIndex, true);
        
      frontURL = nextURL;
    }
  }
  
}


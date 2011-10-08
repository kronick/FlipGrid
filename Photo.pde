class Photo implements Runnable {
  String url;
  GLTexture tex;
  //PImage tex;
  boolean loaded = false;
  
  Grid parent;

  int age = 0;
  int flipStep = 0;
  float angleY = 0;
  float angleX = 0;
  boolean flipping = false;
  int flipDirection;
  
  boolean zooming = false;
  int zoomStep = 0;
  float zoomLevel = 1;
  int zoomDirection = 1;
  static final float MAX_ZOOM = 3;
  
  static final float PERSPECTIVE_FACTOR = 0.2;
  
  Photo(Grid _parent, String _url) {
     this.parent = _parent;
     this.url = _url;
     
     tex = new GLTexture(parent.parent, "default.jpg");
     downloadImage(url);
  } 
  
  void update() {
    age++;    
    if(!flipping && !zooming && random(0,1) < 0.001)  {
      flipping = true; 
      flipDirection = flipStep > 0 ? -1 : 1;
      //direction = 1;
    }
    else if(parent.canZoom(this) && !zooming && random(0,1) < 0.001) {
      zooming = true;
    }
    
    // FLIP STUFF
    // ----------
    if(flipping) {
      flipStep += flipDirection*3;
      zoomDirection = zoomLevel >= MAX_ZOOM ? -1 : 1;
    }
    if(flipStep >= 180 || flipStep <= 0) {
      flipping = false;
    }
    
    angleY = (cos(radians(flipStep))+1)/2*180 - 180;  // Ease in-out
    
    // ZOOM STUFF
    // ----------
    if(zooming) {
      zoomStep += zoomDirection * 3;
    }
    if(zoomLevel <= MAX_ZOOM && zoomStep <= 180)
      zoomLevel = (-cos(radians(zoomStep))+1)/2 * (MAX_ZOOM-1) + 1;
    else zoomLevel = MAX_ZOOM;
    
    if(zoomStep > 720) {
      zoomDirection = -1;
      zoomStep = 180;
    }
    if(zoomLevel <= 1) {
      zooming = false;
      zoomLevel = 1;
      zoomStep = 0;
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
    texture(tex);
    float g = -parent.gridSpace/2 * zoomLevel;
    
    
    vertex(0,0, 0.5, 0.5);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, 0,0);
    vertex( g*a, -g + b*g*PERSPECTIVE_FACTOR, 0,1);
    vertex(-g*a, -g - b*g*PERSPECTIVE_FACTOR, 1,1);
    vertex(-g*a,  g + b*g*PERSPECTIVE_FACTOR, 1,0);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, 0,0);
    
    endShape(CLOSE);
  }
  
  void downloadImage(String _url) {
    this.url = _url;
    loaded = false;
    Thread t = new Thread(this);
    t.start();
  }
  
  void run() {
    //PImage img = loadImage("http://www.independent.co.uk/multimedia/archive/00044/vice_magazine_44521s.jpg");
    PImage img = loadImage("http://profile.ak.fbcdn.net/hprofile-ak-snc4/260998_3308347_1720958231_n.jpg");
    //texture.init(img.width, img.height);
    //tex.init(500,500);
    //tex.putImage(img);
    
    loaded = true;    
  }
  
}


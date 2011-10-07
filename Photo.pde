class Photo implements Runnable {
  String url;
  GLTexture tex;
  //PImage tex;
  boolean loaded = false;
  
  Grid parent;

  int age = 0;
  int flipPhase = 0;
  boolean flipping = false;
  int direction;
  static final float PERSPECTIVE_FACTOR = 0.2;
  
  Photo(Grid _parent, String _url) {
     this.parent = _parent;
     this.url = _url;
     
     tex = new GLTexture(parent.parent, "default.jpg");
     downloadImage(url);
  } 
  
  void update() {
    age++;    
    if(!flipping && random(0,1) < 0.001)  {
      flipping = true; 
      direction = random(0,1) < 0.5 ? -1 : 1;
    }
    if(flipping) flipPhase += direction * 2;
    if(abs(flipPhase) >= 180) {
      //flipPhase = 0;
      flipping = false;
    }
  }
  
  void draw() {
    textureMode(NORMALIZED);
    
    noStroke();
    //stroke(255);
    fill(255,255,255,100);
    float a = cos(radians(flipPhase));
    float b = sin(radians(flipPhase));
    
    beginShape(TRIANGLE_FAN);
    texture(tex);
    float g = -parent.gridSpace/2;
    
    
    vertex(0,0, 0.5, 0.5);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, 0,0);
    vertex( g*a, -g + b*g*PERSPECTIVE_FACTOR, 0,1);
    vertex(-g*a, -g - b*g*PERSPECTIVE_FACTOR, 1,1);
    vertex(-g*a,  g + b*g*PERSPECTIVE_FACTOR, 1,0);
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, 0,0);
    
    /*
    vertex( g*a,  g - b*g*PERSPECTIVE_FACTOR, 0,0);
    vertex( g*a, -g + b*g*PERSPECTIVE_FACTOR, 0,1);
    vertex(-g*a, -g - b*g*PERSPECTIVE_FACTOR, 1,1);
    vertex(-g*a,  g + b*g*PERSPECTIVE_FACTOR, 1,0);
    */
    
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

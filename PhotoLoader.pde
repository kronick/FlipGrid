import org.json.*;
import java.util.*;

class PhotoLoader implements Runnable {
  String creatorsFeed = "https://api.instagram.com/v1/tags/occupywallstreet/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  String occupyFeed = "https://api.instagram.com/v1/tags/occupywallstreet/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  
  Stack<String> photoStack;
  Stack<Boolean> availability;
  
  boolean loading;
  
  float lastUpdateTime = 0;
  static final int UPDATE_FREQUENCY = 1000;  // milliseconds
  
  boolean initialLoad = true;
  
  FlipGrid parent;
  
  PhotoLoader(FlipGrid _parent) {
    this.parent = _parent;
    
    photoStack = new Stack<String>();
    availability = new Stack<Boolean>();
  }
  
  void update() {
    if(millis() - lastUpdateTime > UPDATE_FREQUENCY)
      reloadFeed();
  }
  
  String randomPhoto() {
    // Build a list of available ones
    ArrayList<String> elligible = new ArrayList<String>();
    for(int i=0; i<availability.size(); i++) {
      if(availability.get(i) && i < photoStack.size())
        elligible.add(photoStack.get(i));
    }
      
    if(elligible.size() > 0)
      return elligible.get((int)random(0,elligible.size()));  
    else return null;
  }
  
  void reloadFeed() {
    if(!loading) {
      loading = true;
      Thread t = new Thread(this);
      t.start();
    }
  }
  
  void run() {
    println("Reloading feed...");
    int limit = initialLoad ? 500 : 20;
    int retrieved = 0;
    int newPhotos = 0;
    String max_id = "";
    
    try {
      while(retrieved < limit) {
        String lines[] = loadStrings(creatorsFeed + (max_id.equals("") ? "" : ("&max_id=" + max_id)));
        String json = join(lines, "\n");
        
        JSONObject jsonObj = new JSONObject(json);
        JSONArray photosArray = jsonObj.getJSONArray("data");
        max_id = jsonObj.getJSONObject("pagination").getString("next_max_id");
        
        if(photosArray.length() == 0) break;
        
        for(int i=0; i<photosArray.length(); i++) {
          JSONObject obj = photosArray.getJSONObject(i);
          String url = obj.getJSONObject("images").getJSONObject("low_resolution").getString("url");
          
          retrieved++;
          
          if(!photoStack.contains(url)) {
            photoStack.push(url);
            availability.push(true);
            GridPhoto p;
            // Grab an empty (if this is the initial load) or random photo space
            if(initialLoad)
              p = parent.grid.emptyPhoto();
            else
              p = parent.grid.randomPhoto(10, true);
              
            if(p != null) {  // Ok, this is a good new photo
              // If this is the first on this round, clear the visit queue so these
              // ones pop to the top
              //if(newPhotos == 0)
              //  parent.grid.visitQueue.clear();
              
              // Tell the selected grid space to change its image
              p.changeImage(url, !initialLoad);
              newPhotos++;
              print(".");
            }
            
          }
        }
      }
      
      //if(initialLoad)
      //  parent.grid.visitQueue.clear();
        
      println("\n" + newPhotos + " new photos added to the stack.");
      
    }
    catch (Exception e) {
      println(e);
    }
    
    lastUpdateTime = millis();
    loading = false;
    
    initialLoad = false;
  } 
}

import org.json.*;
import java.util.*;

class PhotoLoader implements Runnable {
  String creatorsFeed = "https://api.instagram.com/v1/tags/sandiego/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  String occupyFeed = "https://api.instagram.com/v1/tags/occupywallstreet/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  
  Stack<String> photoStack;
  
  boolean loading;
  
  float lastUpdateTime = 0;
  static final int UPDATE_FREQUENCY = 1000;  // milliseconds
  
  boolean initialLoad = true;
  
  FlipGrid parent;
  
  PhotoLoader(FlipGrid _parent) {
    this.parent = _parent;
    
    photoStack = new Stack<String>();
  }
  
  void update() {
    if(millis() - lastUpdateTime > UPDATE_FREQUENCY)
      reloadFeed();
  }
  
  void reloadFeed() {
    if(!loading) {
      loading = true;
      Thread t = new Thread(this);
      t.start();
    }
  }
  
  void run() {
    
    int limit = 100;
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
          String url = obj.getJSONObject("images").getJSONObject("standard_resolution").getString("url");
          
          retrieved++;
          
          if(!photoStack.contains(url)) {
            photoStack.push(url);
            GridPhoto p = parent.grid.randomPhoto(1, !initialLoad);
            if(p != null) {
              p.changeImage(url, !initialLoad);
              newPhotos++;
            }
            
          }
        }
      }
      
      println(newPhotos + " new photos added to the stack.");
      
    }
    catch (Exception e) {
      println(e);
    }
    
    lastUpdateTime = millis();
    loading = false;
    
    initialLoad = false;
  }
  
}

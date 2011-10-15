import org.json.*;
import java.util.*;

class PhotoLoader implements Runnable {
  //String creatorsFeed = "https://api.instagram.com/v1/tags/creators/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  //String occupyFeed = "https://api.instagram.com/v1/tags/creatorsproject/media/recent?access_token=1273119.e3ef9b3.b5475046fcf948cc9b766869cbe6e551";
  //String creatorsFeed = "https://api.instagram.com/v1/tags/creators/media/recent?client_id=29ac6223c4b74d86897c0476c5d4f9b9
  //String occupyFeed = "https://api.instagram.com/v1/tags/creatorsproject/media/recent?client_id=29ac6223c4b74d86897c0476c5d4f9b9
  String creatorsFeed = "https://api.instagram.com/v1/tags/creators/media/recent?client_id=11444eddaf6a450ab199d2b5a27665db
  String occupyFeed = "https://api.instagram.com/v1/tags/creatorsproject/media/recent?client_id=11444eddaf6a450ab199d2b5a27665db
  
  Stack<String> photoStack;
  Stack<Boolean> availability;
  Stack<String> captions;
  
  static final int MIN_STACK_SIZE = 305;
  static final float OCCUPIED_PERCENT = 0.02;
  int occupiedPhotos = 0;
  
  boolean loading;
  
  float lastUpdateTime = 0;
  static final int UPDATE_FREQUENCY = 1000;  // milliseconds
  
  boolean initialLoad = true;
  
  FlipGrid parent;
  
  PhotoLoader(FlipGrid _parent) {
    this.parent = _parent;
    
    photoStack =   new Stack<String>();
    availability = new Stack<Boolean>();
    captions =     new Stack<String>();
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
    int retrieved = 0;
    String max_id = "";
    
    int newPhotos = loadPhotos(creatorsFeed, 20, MIN_STACK_SIZE);
    println("\n" + newPhotos + " new photos added to the stack (total: " + photoStack.size() + ")");
    while(occupiedPhotos / (float)photoStack.size() < OCCUPIED_PERCENT) {
      int newOccupations = loadPhotos(occupyFeed, 100, 0, 5);
      occupiedPhotos += newOccupations;
      println("New occupied photos: " + newOccupations + " (total: " + occupiedPhotos + " out of " + photoStack.size() + ")");
      if(newOccupations == 0) break;
    }

    
    lastUpdateTime = millis();
    loading = false;
    
    initialLoad = false;
  } 
  
  int loadPhotos(String feed, int atATime, int keepFull) {
    return loadPhotos(feed, atATime, keepFull, Integer.MAX_VALUE);
  }
  int loadPhotos(String feed, int atATime, int keepFull, int limit) {
    int newPhotos = 0;    
    int retrieved = 0;
    String max_id = "";
    while((photoStack.size() < keepFull || retrieved < atATime) && newPhotos < limit) {
      print(".");
      try {
        String lines[] = loadStrings(feed + (max_id.equals("") ? "" : ("&max_id=" + max_id)));
        String json = join(lines, "\n");    
        JSONObject jsonObj = new JSONObject(json);
        JSONArray photosArray = jsonObj.getJSONArray("data");
        try {
          max_id = jsonObj.getJSONObject("pagination").getString("next_max_id");
        }
        catch (JSONException e) { break; }
        
        if(photosArray.length() == 0) break;
        
        for(int i=0; i<photosArray.length(); i++) {
          if(newPhotos >= limit) break;  // Stop if enough have been loaded
          
          JSONObject obj = photosArray.getJSONObject(i);
          
          String url = obj.getJSONObject("images").getJSONObject("low_resolution").getString("url");
          
          String caption = "";
          if(obj.has("caption")) {
            try {
              caption = obj.getJSONObject("caption").getString("text");
            }
            catch (JSONException e) { }
          }
          
          //println(caption);
          
          retrieved++;
          
          if(!photoStack.contains(url)) {
            photoStack.push(url);
            availability.push(true);
            captions.push(caption);
            GridPhoto p;
            // Grab an empty (if this is the initial load) or random photo space
            if(initialLoad)
              p = parent.grid.emptyPhoto();
            else
              p = parent.grid.randomPhoto(10, true);
              
            if(p != null) {  // Ok, this is a good new photo
              // Tell the selected grid space to change its image
              p.changeImage(url, !initialLoad, !initialLoad);
              //print(".");
            }
            
            newPhotos++;
            
          }
        }
      }
      catch (Exception e) {
        println("Problem with Instagram API: " + e);
      }
    }

    // done    
    return newPhotos;
  }  
}

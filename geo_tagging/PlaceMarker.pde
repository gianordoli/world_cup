class PlaceMarker {

  String name;
  float lat;
  float lng;

  PlaceMarker(String name, float lat, float lng) {
    this.name = name;
    this.lat = lat;
    this.lng = lng;
  }

  void display() {
    // Equirectangular projection
    float x = map(lng, -180, 180, 0, width); 
    float y = map(lat, 90, -90, 0, height);
    
    noStroke();
    fill(255, 0, 0, 50);
    ellipse(x, y, 15, 15);
    fill(255, 0, 0, 200);
    ellipse(x, y, 5, 5);
    
    fill(255);
    text(name, x, y);
  }

  String toString() {
    return name + " (" + lat + ", " + lng + ")";
  }
}


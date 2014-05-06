class Country {

  String name;
  float lat;
  float lng;

  Country(String _name, float _lat, float _lng) {
    name = _name;
    lat = _lat;
    lng = _lng;
  }

  void display() {
    // Equirectangular projection
    float x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    float y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);
    
    noStroke();
    fill(240, 255, 255);
    ellipse(x, y, 5, 5);
    
    text(name, x, y);
  }
}


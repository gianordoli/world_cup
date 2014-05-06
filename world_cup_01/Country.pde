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
    float x = map(lng, -180, 180, mapPos.x, mapPos.x + mapSize.x); 
    float y = map(lat, 90, -90, mapPos.y, mapPos.y + mapSize.y);
    
    noStroke();
    fill(255, 0, 0, 50);
    ellipse(x, y, 15, 15);
    fill(255, 0, 0, 200);
    ellipse(x, y, 5, 5);
    
    fill(255);
    text(name, x, y);
  }
}


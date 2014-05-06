class Country {

  String name;
  PVector pos;

  Country(String _name, float lat, float lng) {
    name = _name;
    pos = new PVector();
    setPos(lat, lng);
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);       
  }

  void display() {
    
    noStroke();
    fill(240, 255, 255);
    ellipse(pos.x, pos.y, 5, 5);
    
    text(name, pos.x, pos.y);
  }
}


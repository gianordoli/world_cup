class Country {

  String name;
  PVector pos;
  color myColor;

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
  
  void setColor(float h, float s, float b){
    myColor = color(h, s, b);
  }

  void display() {
    
    noStroke();
    fill(myColor);
    ellipse(pos.x, pos.y, 5, 5);
    
    float boxWidth = textWidth(name) + 4;
    fill(myColor, 150);
    rect(pos.x, pos.y, boxWidth, - 12);
    fill(255);
    textSize(10);
    textAlign(LEFT, BOTTOM);
    text(name, pos.x + 2, pos.y);
  }
}


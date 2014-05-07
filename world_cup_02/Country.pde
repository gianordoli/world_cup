class Country {

  String name;
  PVector pos;
  float radius;
  float final_radius;
  int totalPlayers;  
  color myColor;

  Country(String _name, float lat, float lng) {
    name = _name;
    pos = new PVector();
    setPos(lat, lng);
    radius = 1;
    final_radius = random(10, 20);
    totalPlayers = 0;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);       
  }
  
  void setColor(float h, float s, float b){
    myColor = color(h, s, b);
  }
  
  void setRadius(int max){
    final_radius = map(totalPlayers, 0, max, 10, 40);
  }
  
  void update(){
    float padding = 2*mm; //space in between the circles
    for(Country c : allCountries){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.2;
        pos.y += escape.y * 1.2;
      }    
    }  
  }  

  void display() {
    
    if(radius < final_radius * 0.99){
      radius += (final_radius - radius) * 0.1;
    }
    
    noStroke();
    fill(myColor, 150);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
//    float boxWidth = textWidth(name) + 4;
//    fill(myColor, 150);
//    rect(pos.x, pos.y, boxWidth, - 12);
//    fill(255);
    fill(0);
    textSize(10);
    textAlign(CENTER, TOP);
    text(name, pos.x + 2, pos.y);
  }
}


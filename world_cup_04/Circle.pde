//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector controlPoint;
  float radius;
  float final_radius;
  int totalPlayers;
  
  Country thisCountry;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0;
    final_radius = 5*mm;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);
    setControlPoint();    
  }
  
  void setControlPoint(){
      float offset = 20*mm;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + final_radius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + final_radius + offset);  
  }
  
//  void setColor(float h, float s, float b){
//    myColor = color(h, s, b);
//  }  
  
  void setRadius(int max){
    final_radius = map(totalPlayers, 0, max, 2*mm, 10*mm);
  }
  
  void update(){
    float padding = 3*mm; //space in between the circles
    for(Circle c : allCircles){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.1;
        pos.y += escape.y * 1.1;
        
        setControlPoint();        
      }    
    }  
  }  

  void display() {
    
    if(radius < final_radius * 0.99){
      radius += (final_radius - radius) * 0.1;
    }
    
    noStroke();
    fill(thisCountry.myColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    PVector boxSize = new PVector(20*mm, 4*mm);    
    fill(0);
    textSize(8);
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textLeading(8);
    text(thisCountry.name, pos.x - boxSize.x/2, pos.y - boxSize.x/2, boxSize.x, boxSize.x);
  }
}


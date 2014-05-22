//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;
  color currColor;
  
  Country thisCountry;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    currColor = thisCountry.myColor;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0;  
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);    
  }
  
  void setControlPoint(){
      float offset = 30*mm;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + finalRadius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + finalRadius + offset);  
  }
  
//  void setColor(float h, float s, float b){
//    myColor = color(h, s, b);
//  }  
  
  void setRadius(int max){
    finalRadius = map(totalPlayers, 0, max, 2*mm, 20*mm);
    setControlPoint();    
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
        pos.x += escape.x * 1.2;
        pos.y += escape.y * 1.2;
        
        setControlPoint();        
      }    
    }  
  }  
  
  boolean isHovering(){
    if(dist(mouseX, mouseY, pos.x, pos.y) < radius){
      return true;
    }else{
      return false;
    }
  }

  void display() {
    
    if(radius < finalRadius * 0.99){
      radius += (finalRadius - radius) * 0.2;
    }else{
      radius = finalRadius;
    }
    
    noStroke();
//    fill(thisCountry.myColor);
    fill(currColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    PVector boxSize = new PVector(14*mm, 4*mm);    
    fill(0);
    textFont(glober);
    textSize(8);
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textLeading(8);
    text(thisCountry.name, pos.x - boxSize.x/2, pos.y - boxSize.x/2, boxSize.x, boxSize.x);
  }
}


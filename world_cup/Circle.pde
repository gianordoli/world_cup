//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> clubPlayers;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0; 
    clubPlayers = new ArrayList<Player>();
   
    isOver = false;
    isActive = true;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);    
  }
  
  void setControlPoint(){
      float offset = 90;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + finalRadius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + finalRadius + offset);  
  }
  
  void setRadius(int max){
    finalRadius = map(totalPlayers, 1, max, 6, 50);
    setControlPoint();    
  }
  
  void update(){
    float padding = 16; //space in between the circles
    for(Circle c : allCircles){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.3;
        pos.y += escape.y * 1.3;
        
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
    //TRANSITION
    if(radius < finalRadius * 0.99){
      radius += (finalRadius - radius) * 1.3;
    }else{
      radius = finalRadius;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      //If it's NOT one of the "gray" countries...
      if(saturation(newColor) > 100){
        newColor = color(hue(newColor), saturation(newColor), 255);
      }else{
        newColor = color(hue(newColor), saturation(newColor), brightness(newColor) + 20);
      }
    }
    if(!isActive){
      newColor = inactiveColor;
    }    
    
    noStroke();  
    fill(newColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    if(isOver || isActive){
      float maxTextWidth = 42;
      float leading = 9;
      fill(255);
      textFont(archivoNarrow);
      textSize(11);
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      if(textWidth(thisCountry.name) < maxTextWidth){
        text(thisCountry.name, pos.x, pos.y);
      }else{
        String[] words = split(thisCountry.name, " ");
        String msg = "";
        for(int i = 0; i < words.length - 1; i++){
          msg += words[i] + " ";
        }
        text(msg, pos.x, pos.y - leading);
        msg = words[words.length - 1];
        text(msg, pos.x, pos.y);
      }
      
      //NUMBER
      if(!selectedType.equals("") && isActive){
        textFont(archivoNarrowBold);
        textSize(12);
        int nPlayers = 0;
        if(selectedType.equals("circle")){
          nPlayers = clubPlayers.size();
        
        }else if(selectedType.equals("arc")){
          for(Player p : clubPlayers){
            if(p.isActive){
              nPlayers ++;
            }
          }
        }
        text(nPlayers, pos.x, pos.y + leading + 2);
      }
    }
  }
}


//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  color currColor;
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    currColor = thisCountry.myColor;
    teamPlayers = _teamPlayers;
  }

  void setArcParam(float _x, float _y, float _r, float _startAngle, float _endAngle){
    pos = new PVector(_x, _y);
    radius = _r;
    startAngle = _startAngle;
    endAngle = _endAngle;
  }  
  
  void linkCircles(){
    //Club country
    for (Circle c : allCircles) {
      for (Player p : teamPlayers) {
        if (p.current.name.equals(c.thisCountry.name)) {
          p.currCountry = c;
          c.totalPlayers ++;
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle, endAngle);   
      float offset = 20*mm;  //distance from arc to control point
      float x1 = pos.x + cos(angle) * (radius - 4*mm);
      float y1 = pos.y + sin(angle) * (radius - 4*mm);
      float x2 = pos.x + cos(angle) * (radius - 4*mm - offset);
      float y2 = pos.y + sin(angle) * (radius - 4*mm - offset);    
  
      p.setPos(x1, y1, x2, y2);
      p.setAngle(angle);
    }
  }  
  
  boolean isHovering(){
    float mouseAngle = atan2(mouseY - center.y, mouseX - center.x);
    if(mouseAngle < 0) {
      mouseAngle = TWO_PI - abs(mouseAngle); 
    }
    float distance = dist(mouseX, mouseY, center.x, center.y); 
    if(startAngle < mouseAngle && mouseAngle < endAngle &&
       radius - 4*mm < distance && distance < radius + 4*mm){
      return true;
    }else{
      return false;
    }
  }
  
  void display(){
    float currAngle = 0;
    float alpha = 0;
    if(millis() < transition2){
      currAngle = map(transition2 - millis(), interval, 0, startAngle, endAngle);
      currAngle = constrain(currAngle, 0, endAngle);
      alpha = map(transition2 - millis(), interval, 0, 0, 255);
      alpha = constrain(alpha, 0, 255);
    }else{
      currAngle = endAngle;
      alpha = 255;
    }
    
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(currColor);
      strokeWeight(8*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      PVector boxSize = new PVector(15*mm, 4*mm);  
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      textFont(glober);      
//      textSize(10);    
      textLeading(10);  
      fill(0, alpha);      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
        if(angle < PI){
          rotate(angle - PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
        }else{
          rotate(angle + PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
        }
    popMatrix();
  }
}

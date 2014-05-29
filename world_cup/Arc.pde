//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    teamPlayers = _teamPlayers;
    
    isOver = false;
    isActive = true;
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
          c.clubPlayers.add(p);
          
          p.originCountry = this;
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle, endAngle);   
      float offset = 40*mm;  //distance from arc to control point
      PVector p1 = new PVector(0,0);
      PVector p2 = new PVector(0,0);
      p1.x = pos.x + cos(angle) * (radius - 4*mm);
      p1.y = pos.y + sin(angle) * (radius - 4*mm);
      p2.x = pos.x + cos(angle) * (radius - 4*mm - offset);
      p2.y = pos.y + sin(angle) * (radius - 4*mm - offset);
      
      PVector p4 = p.currCountry.pos;
//      PVector p3 = PVector.lerp(p2, p4, 0.5);
      //lerp on a vector doesn't work in javaScript mode
      PVector p3 = new PVector(p2.x, p2.y);
      p3.x = lerp(p2.x, p4.x, 0.5);
      p3.y = lerp(p2.y, p4.y, 0.5);
  
      p.setPos(p1, p2, p3, p4);
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
    //TRANSITION
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
    
    color newColor = thisCountry.myColor;
    if(isOver){
      newColor = color(hue(newColor), saturation(newColor) - 100, brightness(newColor));
    }
    if(!isActive){
      newColor = color(0, 0, 0, 30);
    }
    
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(newColor);
      strokeWeight(8*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      PVector boxSize = new PVector(15*mm, 4*mm);  
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
//      textFont(glober);      
//      textSize(10);    
      textLeading(16);  
      fill(0, alpha);      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
        if(angle < PI){
          rotate(angle - PI/2);
          text(thisCountry.abbreviation, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);
        }else{
          rotate(angle + PI/2);
          text(thisCountry.abbreviation, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
        }
    popMatrix();
  }
}

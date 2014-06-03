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
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle + 0.003*PI, endAngle - 0.003*PI);   
      float offset = 120;  //distance from arc to control point
      PVector p1 = new PVector(0,0);
      PVector p2 = new PVector(0,0);
      p1.x = pos.x + cos(angle) * (radius - 12);
      p1.y = pos.y + sin(angle) * (radius - 12);
      p2.x = pos.x + cos(angle) * (radius - 12 - offset);
      p2.y = pos.y + sin(angle) * (radius - 12 - offset);
      
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
       radius - 12 < distance && distance < radius + 12){
      return true;
    }else{
      return false;
    }
  }
  
  void display(int i){
    //TRANSITION
    float currAngle = 0;
    float alpha = 0;
    if(millis() < transition2){
      currAngle = map(transition2 - millis(), interval, 0, startAngle, endAngle);
      currAngle = constrain(currAngle, 0, endAngle);
      alpha = map(transition1 - millis(), interval, 0, 0, 255);
      alpha = constrain(alpha, 0, 255);
    }else{
      currAngle = endAngle;
      alpha = 255;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      newColor = color(hue(newColor), saturation(newColor), brightness(newColor)*1.2);
    }
    if(!isActive){
      newColor = inactiveColor;
    }
    
    pushMatrix();
      translate(pos.x, pos.y);
      float arcWeight = 24;
      noFill();
      stroke(newColor);
      strokeWeight(arcWeight);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      float angle = (endAngle + startAngle)/2;
      float direction = 1;
      if(angle < PI){
        direction *= -1;
      }      
      
      if(i % 4 == 0){
        float titleAngle = 0;
        Arc lastArc = allArcs.get(i + 3);
        strokeWeight(1);
        stroke(thisCountry.myColor);
        if(direction > 0){
          arc(0, 0, radius*2 + arcWeight + 6, radius*2 + arcWeight + 6, startAngle, lastArc.endAngle);
          titleAngle = (startAngle + lastArc.endAngle)/2;
        }else{
          arc(0, 0, radius*2 + arcWeight + 6, radius*2 + arcWeight + 6, lastArc.startAngle, endAngle);
          titleAngle = (endAngle + lastArc.startAngle)/2;
        }
        translate(cos(titleAngle) * (radius + arcWeight), sin(titleAngle) * (radius + arcWeight));
        rotate(titleAngle + PI/2 * direction);
        fill(labelColor);
        textAlign(CENTER, CENTER);
        textFont(bitter);
        textSize(10);
        text("GRUPO " + thisCountry.group.toUpperCase(), 0, 0);
        
        //Undo!
        rotate(- (titleAngle + PI/2 * direction));        
        translate(-(cos(titleAngle) * (radius + arcWeight)), -(sin(titleAngle) * (radius + arcWeight)));
      }
      
      translate(cos(angle) * radius, sin(angle) * radius);
        
        rotate(angle + PI/2 * direction);
      
        rectMode(CORNER);
        textAlign(CENTER, CENTER);
        textFont(archivoNarrow);
        textSize(14);      
        fill(0, alpha);
        text(thisCountry.abbreviation.toUpperCase(), 0, 0);
        
        //NUMBER
        if(selectedType.equals("circle") && isActive){
          int nPlayers = 0;
          for(Player p : teamPlayers){
            if(p.isActive){
              nPlayers ++;
            }
          }
          
          noStroke();
          fill(newColor);
          rectMode(CENTER);
          rect(0, arcWeight * 0.8 * direction, 17, 20, 5);
          fill(0);
          textAlign(CENTER, CENTER);
          text(nPlayers, 0, (arcWeight - 5)*direction);
        }        
        
    popMatrix();
  }
}

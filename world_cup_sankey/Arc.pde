//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
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
      float x1 = pos.x + cos(angle) * radius;
      float y1 = pos.y + sin(angle) * radius;
      float x2 = pos.x + cos(angle) * (radius - offset);
      float y2 = pos.y + sin(angle) * (radius - offset);    
  
      p.setPos(x1, y1, x2, y2);
      p.setAngle(angle);
    }
  }  
  
  void display(){
    
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(thisCountry.myColor);
      strokeWeight(8*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2 + 5*mm, radius*2 + 5*mm, startAngle, endAngle);
      
      PVector boxSize = new PVector(15*mm, 4*mm);  
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      textFont(glober);      
      textSize(10);    
      textLeading(10);  
      fill(0);      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
        if(angle < PI){
          rotate(angle - PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2 + 3*mm, boxSize.x, boxSize.x);      
        }else{
          rotate(angle + PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2 - 3*mm, boxSize.x, boxSize.x);      
        }
    popMatrix();
  }
}

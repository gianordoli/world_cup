//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector size;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;

  ArrayList<Player> teamPlayers;
  
  float start, barLength;
  
  Country thisCountry;

  Circle(Country _thisCountry) {
    thisCountry = _thisCountry;
    pos = new PVector();
    size = new PVector();
    controlPoint = new PVector();
    totalPlayers = 0;  
    
    teamPlayers = new ArrayList<Player>();
  }
  
  void setCircleParam(float _start, float _barLength){
    pos = new PVector(_start, 50*mm);
    size = new PVector(_barLength, 5*mm); 

    float offset = 100*mm;
    controlPoint.x = pos.x;
    controlPoint.y = pos.y + offset;        
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float x = map(i, -1, teamPlayers.size(), pos.x, pos.x + size.x);
      
      float offset = 100*mm;  //distance from arc to control point
      float x1 = x;
      float y1 = pos.y + offset;
      float x2 = x;
      float y2 = pos.y;
  
      p.setPos(x1, y1, x2, y2);
    }
  }  

  void display(int i) {
    
    noStroke();
    fill(thisCountry.myColor);
    rect(pos.x, pos.y, size.x, -size.y);
    
   textSize(10);
   rectMode(CORNER);
    textAlign(CENTER, BOTTOM);
    textFont(glober);      
 
   textSize(7.5);    
    fill(0); 
    float offset = (i % 6) * 5*mm;    
    text(thisCountry.name, pos.x + size.x/2, pos.y - size.y - offset);     
  }
}


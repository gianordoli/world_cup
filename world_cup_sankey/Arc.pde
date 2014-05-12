//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{

  PVector pos;
  PVector size;
  float start;
  float barLength;
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    teamPlayers = _teamPlayers;
  }

  void setArcParam(float _start, float _barLength){
    pos = new PVector(_start, height - 40*mm);
    size = new PVector(_barLength, 10*mm);    
  }  
  
  void linkCircles(){
    //Club country
    for (Circle c : allCircles) {
      for (Player p : teamPlayers) {
        if (p.current.name.equals(c.thisCountry.name)) {
          p.currCountry = c;
          c.totalPlayers ++;
          
          c.teamPlayers.add(p);
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float x = map(i, 0, teamPlayers.size() - 1, pos.x, pos.x + size.x);
      
      float offset = 100*mm;  //distance from arc to control point
      float x1 = x;
      float y1 = pos.y;
      float x2 = x;
      float y2 = pos.y - offset;    
  
      p.setPos(x1, y1, x2, y2);
    }
  }  
  
  void display(){
    noStroke();
    fill(thisCountry.myColor);
    rect(pos.x, pos.y, size.x, size.y);
      
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textFont(glober);      
    textSize(10);    
    textLeading(10);  
    fill(0);     
    text(thisCountry.name, pos.x - size.x/2, pos.y - size.y/2, size.x, -size.y); 
  }
}

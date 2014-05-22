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
    size = new PVector(_barLength, 5*mm);    
  }  
  
  void linkCircles(){
    //Club country
    for (Circle c : allCircles) {
      for (Player p : teamPlayers) {
        if (p.current.name.equals(c.thisCountry.name)) {
          p.currCountry = c;
          
          c.teamPlayers.add(p);
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
         
      float x = map(i, -1, teamPlayers.size(), pos.x, pos.x + size.x);
      
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
    textAlign(CENTER, TOP);
    textFont(glober);      
    textSize(7);    
    textLeading(7.5);  
    fill(0);     
    text(thisCountry.name, pos.x - 1*mm, pos.y + size.y, size.x + 2*mm, size.y + 20*mm); 
  }
}

//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{

  float start;
  float barLength;
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    teamPlayers = _teamPlayers;
  }

  void setArcParam(float _start, float _barLength){
    
    start = _start;
    barLength = _barLength;
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
      
      float x = map(i, 0, teamPlayers.size() - 1, start, barLength);
      
      float offset = 20*mm;  //distance from arc to control point
      float x1 = x;
      float y1 = height/2;
      float x2 = x;
      float y2 = y1 - offset;    
  
      p.setPos(x1, y1, x2, y2);
    }
  }  
  
  void display(){
    noStroke();
    fill(thisCountry.myColor);
    rect(start, height/2, barLength, 10*mm);
    
    PVector boxSize = new PVector(15*mm, 4*mm);  
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textFont(glober);      
    textSize(10);    
    textLeading(10);  
    fill(0);     
    text(thisCountry.name, start - boxSize.x/2, height/2 - boxSize.x/2 + 3*mm, boxSize.x, boxSize.x); 
  }
}

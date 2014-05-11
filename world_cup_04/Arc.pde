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
  
//  Arc(String _name, ArrayList<Player> _teamPlayers, float _rX, float _rY, float _radius, float _startAngle, float _endAngle){
//    name = _name;
//    teamPlayers = _teamPlayers;
//    pos = new PVector(_rX, _rY);
//    radius = _radius;
//    startAngle = _startAngle;
//    endAngle = _endAngle;
//  }
  
  void display(){
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(thisCountry.myColor, 100);
      strokeWeight(5*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, endAngle);
      
      rotate(startAngle);
      text(thisCountry.name, radius, 0);
    popMatrix();
  }
}

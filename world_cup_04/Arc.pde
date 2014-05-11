//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  String name;
  ArrayList<Player> teamPlayers;
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  
  Arc(String _name, ArrayList<Player> _teamPlayers, float _rX, float _rY, float _radius, float _startAngle, float _endAngle){
    name = _name;
    teamPlayers = _teamPlayers;
    pos = new PVector(_rX, _rY);
    radius = _radius;
    startAngle = _startAngle;
    endAngle = _endAngle;
  }
  
  void display(){
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
//      stroke(teamPlayers.get(0).currCountry.thisCountry.myColor);
      strokeWeight(5*mm);
      arc(0, 0, radius*2, radius*2, startAngle, endAngle);
    popMatrix();
  }
}

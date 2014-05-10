//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Team{
  String name;
  ArrayList<Player> teamPlayers;
  float startAngle;
  float endAngle;
  
  Team(String _name, ArrayList<Player> _teamPlayers, float _startAngle, float _endAngle){
    name = _name;
    teamPlayers = _teamPlayers;
    startAngle = _startAngle;
    endAngle = _endAngle;
  }
}

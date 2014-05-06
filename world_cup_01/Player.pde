class Player{
  String name, country, club, clubCountry;
  PVector start, end;
  
  Player(String _name, String _team, String _club, String _clubCountry){
    name = _name;
    country = _clubCountry;
    club = _club;
    clubCountry = _clubCountry;
    start = new PVector();
    end = new PVector();
  }
  
  void setPos(float x1, float y1, float x2, float y2){
    start.x = x1;
    start.y = y1;
    end.x = x2;
    end.y = y2;
  }
  
  void display(){
    noFill();
    stroke(0, 100);
    line(start.x, start.y, end.x, end.y);
  }

}

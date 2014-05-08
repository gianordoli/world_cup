class Player {
  String name, country, club, clubCountry;
  PVector arcPos;
  float angle;
  
  Country originCountry;
  Country currCountry;

  Player(String _name, String _country, String _club, String _clubCountry) {
    name = _name;
    country = _country;
    club = _club;
    clubCountry = _clubCountry;
    arcPos = new PVector();
  }

  void setPos(float x1, float y1) {
    arcPos.x = x1;
    arcPos.y = y1;
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display(ArrayList<Player> myList, int index) {
    //Line
    noFill();
    stroke(currCountry.myColor, 100);
    line(arcPos.x, arcPos.y, currCountry.pos.x, currCountry.pos.y);

    //Ellipse
    fill(originCountry.myColor);
    noStroke();
    ellipse(arcPos.x, arcPos.y, 5, 5);
    
    //Contry name
    if(index > 0 && !myList.get(index - 1).country.equals(country)){
      pushMatrix();
        translate(arcPos.x, arcPos.y);
        
        if(PI/2 < angle && angle < 1.5 * PI ){
          rotate(angle - PI);
          fill(0);
          textAlign(RIGHT, CENTER);
          text(country, -2*mm, 0);
        }else{
          rotate(angle);
          fill(0);
          textAlign(LEFT, CENTER);
          text(country, 2*mm, 0);
        }
      popMatrix();    
    }
  }
}


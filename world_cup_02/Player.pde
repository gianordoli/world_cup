class Player {
  String name, country, club, clubCountry;
  PVector start, end;
  float angle;
  color countryColor;
  color clubCountryColor;

  Player(String _name, String _country, String _club, String _clubCountry) {
    name = _name;
    country = _country;
    club = _club;
    clubCountry = _clubCountry;
    start = new PVector();
    end = new PVector();
  }

  void setPos(float x1, float y1, float x2, float y2) {
    start.x = x1;
    start.y = y1;
    end.x = x2;
    end.y = y2;
  }

  void setColor(color _countryColor, color _clubCountryColor) {
    countryColor = _countryColor;
    clubCountryColor = _clubCountryColor;
//    println(countryColor + ", " + clubCountryColor);
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display(ArrayList<Player> myList, int index) {
    noFill();
    stroke(clubCountryColor, 100);
    line(start.x, start.y, end.x, end.y);

    fill(countryColor);
    noStroke();
    ellipse(start.x, start.y, 5, 5);
    
    //Contry name
    if(index > 0 && !myList.get(index - 1).country.equals(country)){
      pushMatrix();
        translate(start.x, start.y);
        
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


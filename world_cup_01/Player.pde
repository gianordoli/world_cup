class Player {
  String name, country, club, clubCountry;
  PVector start, end;
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

  void display() {
    noFill();
    stroke(clubCountryColor, 100);
    line(start.x, start.y, end.x, end.y);

    fill(countryColor);
    noStroke();
    ellipse(start.x, start.y, 5, 5);
  }
}


//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;
PShape map;
ArrayList<Country> allCountries;

void setup(){
  size(1212, 798);
//  beginRecord(PDF, "world_cup.pdf");
  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();
  loadPlayers("players.tsv");
  loadCountries("coordinates.tsv");
  debug();
}

void draw(){
//  endRecord();
//  exit();
}

void loadPlayers(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    allPlayers.add(new Player(myLine[1], myLine[0], myLine[2], myLine[3]));
  }
}

void loadCountries(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    String name = myLine[0];
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    Country myCountry = new Country(name, lat, lng);
    allCountries.add(myCountry);
  } 
}

void debug(){
  for(Player p : allPlayers){
    println(p.name + ", " + p.country + ", " + p.club + ", " + p.clubCountry);
  }
  for(Country c : allCountries){
    println(c.name + ", " + c.lat + ", " + c.lng);
  }  
}
class Country {

  String name;
  float lat;
  float lng;

  PlaceMarker(String _name, float _lat, float _lng) {
    name = _name;
    lat = _lat;
    lng = _lng;
  }

  void display() {
    // Equirectangular projection
    float x = map(lng, -180, 180, 0, width); 
    float y = map(lat, 90, -90, 0, height);
    
    noStroke();
    fill(255, 0, 0, 50);
    ellipse(x, y, 15, 15);
    fill(255, 0, 0, 200);
    ellipse(x, y, 5, 5);
    
    fill(255);
    text(name, x, y);
  }
}

class Player{
  String name, country, club, clubCountry;
  
  Player(String _name, String _team, String _club, String _clubCountry){
    name = _name;
    country = _clubCountry;
    club = _club;
    clubCountry = _clubCountry;
  }

}


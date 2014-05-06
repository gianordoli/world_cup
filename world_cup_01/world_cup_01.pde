//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

PImage map;
//PShape map;
PVector mapPos;
PVector mapSize;

void setup(){
  size(1212, 798);
//  beginRecord(PDF, "world_cup.pdf");

  map = loadImage("worldmap-equirectangular-s.jpg");
  mapPos = new PVector(10*mm, 10*mm);
  mapSize = new PVector(width - 20*mm, height - 20*mm);

  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();
  loadPlayers("players.tsv");
  loadCountries("coordinates.tsv");
  debug();
}

void draw(){
  image(map, mapPos.x, mapPos.y, mapSize.x, mapSize.y);
  
  for (Country c : allCountries) {
    c.display();
  }  
  
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

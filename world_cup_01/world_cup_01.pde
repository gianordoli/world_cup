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
//  loadCountries("countries.tsv");
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

//void loadCountries(String filename){
//  String[] tableString = loadStrings(filename);
//  for(String lineString : tableString){
//    allCountries.add(new Country(myLine[0], myLine[2], myLine[3]));
//  }
//}


void debug(){
  for(Player p : allPlayers){
    println(p.name + ", " + p.country + ", " + p.club + ", " + p.clubCountry);
  }
}

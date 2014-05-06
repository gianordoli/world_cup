//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;

void setup(){
  size(1212, 798);
//  beginRecord(PDF, "world_cup.pdf");
  allPlayers = new ArrayList<Player>();
  processData("players.tsv");
  debug();
}

void draw(){
//  endRecord();
//  exit();
}

void processData(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    allPlayers.add(new Player(myLine[1], myLine[0], myLine[2], myLine[3]));
  }
}

void debug(){
  for(Player p : allPlayers){
    println(p.name + ", " + p.country + ", " + p.club + ", " + p.clubCountry);
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


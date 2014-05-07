//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

PShape worldMap;
PVector worldMapPos;
PVector worldMapSize;

void setup(){
  size(1212, 798);
  colorMode(HSB);
//  beginRecord(PDF, "world_cup.pdf");

  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapPos = new PVector(40*mm, 70*mm);
  worldMapSize = new PVector(width - 100*mm, height - 100*mm);

  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();
  loadPlayers("players.tsv");
  loadCountries("coordinates.tsv");
  setPlayersPositions();
//  debug();
}

void draw(){
  background(255);
  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);
  
  for (Country c : allCountries) {
    c.display();
  }
  
  for (Player p : allPlayers) {
    p.display();
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

void setPlayersPositions(){
  PVector center = new PVector(width/2, height/2);
  float radius = 150*mm;
  
  for(int i = 0; i < allPlayers.size(); i++){
    
    Player thisPlayer = allPlayers.get(i);
    float angle = map(i, 0, allPlayers.size() - 1, 0.75 * PI, 1.75 * PI);
    if(angle > 1.25 * PI){
      angle += 0.5 * PI;
    }
    float x1 = center.x + cos(angle) * radius;
    float y1 = center.y + sin(angle) * radius;
    float x2 = 0;
    float y2 = 0;
    
    for(int j = 0; j < allCountries.size(); j++){
      Country thisCountry = allCountries.get(j);
      if(thisPlayer.clubCountry.equals(thisCountry.name)){
        x2 = thisCountry.pos.x;
        y2 = thisCountry.pos.y;
        break;
      }
    }
    thisPlayer.setPos(x1, y1, x2, y2);
  }
}

void debug(){
  for(Player p : allPlayers){
    println(p.name + "\t" + p.country + "\t" + p.club + "\t" + p.clubCountry + "\t" + p.start + "\t" + p.end); 
  }
}

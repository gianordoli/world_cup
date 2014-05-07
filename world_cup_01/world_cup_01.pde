//import processing.pdf.*;
int mm = 3;
ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;
String[] sortedCountries;

PShape worldMap;
PVector worldMapPos;
PVector worldMapSize;

void setup(){
//  JS:
  size(1212, 798);
//  size(404*mm, 266*mm);
  colorMode(HSB);
//  beginRecord(PDF, "world_cup.pdf");

  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapPos = new PVector(10*mm, 70*mm);
  worldMapSize = new PVector(width - 50*mm, height - 50*mm);

//  sortedCountries = loadStrings("countries_visual_sorting.txt");
  sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  for(int i =0; i < sortedCountries.length; i++){
    sortedCountries[i] = trim(sortedCountries[i]);
  }  
  
  allPlayers = new ArrayList<Player>();
  allCountries = new ArrayList<Country>();
  loadPlayers("players.tsv");
  loadCountriesCoordinates("coordinates_pt.tsv");
  setCountriesColors();  
  sortPlayersCountry();
  sortPlayersClub();
  setPlayersPositionsAndColors();
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
    allPlayers.add(new Player(trim(myLine[1]), trim(myLine[0]), trim(myLine[2]), trim(myLine[3])));
  }
}

void loadCountriesCoordinates(String filename){
  String[] tableString = loadStrings(filename);
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);
    Country myCountry = new Country(name, lat, lng);
    allCountries.add(myCountry);
  } 
}

void setCountriesColors(){
  for(int i = 0; i < allCountries.size(); i++){
    Country c = allCountries.get(i);
    float h = map(i, 0, allCountries.size() - 1, 0, 255);
    float s = 255;
    float b = (i % 2 == 0) ? (255) : (150);
    c.setColor(h, s, b);
  }
}

void sortPlayersCountry(){
  
  //This temporary ArrayList will store the objects sorted
  ArrayList<Player> tempList = new ArrayList<Player>();  
  
  //Looping through each sorted value
  for(int i = 0; i < sortedCountries.length; i++){
    
    //Looping through each object
    for(int j = 0; j < allPlayers.size(); j++){
      String thisValue = allPlayers.get(j).country;
//        println("\t" + thisValue);
      
      //If the sorted value is found...
      if(sortedCountries[i].equals(thisValue)){
        //Add the object to the temporary list
        tempList.add(allPlayers.get(j));
      }
    }
  }
  
  //Replace the original list with the sorted one
  allPlayers = tempList;
}

void sortPlayersClub(){
  //New list
  ArrayList<Player> tempList = new ArrayList<Player>();
  
  int a = 0;
  
  while(a < allPlayers.size() - 1){
    //Current country
    ArrayList<Player> tempListCountry = new ArrayList<Player>();
    int i = a;
    String currCountry = allPlayers.get(a).country;
    while(currCountry.equals(allPlayers.get(i).country) && i < allPlayers.size() - 1){
      tempListCountry.add(allPlayers.get(i));
      i++;
    }
    if(i == allPlayers.size() - 1){
      tempListCountry.add(allPlayers.get(i));
    }
//    i--;
  //  for(Player p : tempListCountry){
  //    println(p.country + "\t" + p.clubCountry);
  //  }  
  
    for(int j = 0; j < sortedCountries.length; j++){
      for(int k = 0; k < tempListCountry.size(); k++){
        Player p = tempListCountry.get(k);      
        if(sortedCountries[j].equals(p.clubCountry)){
          tempList.add(p);
//          allPlayers.remove(p);
        }
      }
    }   
    a = i;
//    println(a);
  }
  
  for(Player p : tempList){
    println(p.country + "\t" + p.clubCountry);
  } 
 allPlayers = tempList; 
}

void setPlayersPositionsAndColors(){
  PVector center = new PVector(width/2, height/2);
  float radius = 150*mm;
  
  for(int i = 0; i < allPlayers.size(); i++){
    
    Player thisPlayer = allPlayers.get(i);

    //ARC (team)
      //Position    
      float angle = map(i, 0, allPlayers.size() - 1, 0.75 * PI, 1.75 * PI);
      if(angle > 1.25 * PI){
        angle += 0.5 * PI;
      }
      float x1 = center.x + cos(angle) * radius;
      float y1 = center.y + sin(angle) * radius;
      color countryColor = 0;    
      
      //Color
      for(int j = 0; j < allCountries.size(); j++){
        Country thisCountry = allCountries.get(j);
        if(thisPlayer.country.equals(thisCountry.name)){
          countryColor = thisCountry.myColor;
//          println(thisCountry.name);
          break;
        }
      }

    //ORIGIN (club)
      //position and color
      float x2 = 0;
      float y2 = 0;
      color clubCountryColor = 0;
      
      for(int j = 0; j < allCountries.size(); j++){
        Country thisCountry = allCountries.get(j);
        if(thisPlayer.clubCountry.equals(thisCountry.name)){
          x2 = thisCountry.pos.x;
          y2 = thisCountry.pos.y;
          clubCountryColor = thisCountry.myColor;
          break;
        }
      }
    
//    println(countryColor + ", " + clubCountryColor);  
    thisPlayer.setPos(x1, y1, x2, y2);
    thisPlayer.setColor(countryColor, clubCountryColor);
  }
}

void debug(){
  for(Player p : allPlayers){
    println(p.name + "\t" + p.country + "\t" + p.club + "\t" + p.clubCountry + "\t" + p.start + "\t" + p.end); 
  }
}

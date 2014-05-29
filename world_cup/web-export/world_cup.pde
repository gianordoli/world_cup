/* @pjs preload="world_map_equirectangular.png"; */

/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com

 Geoplacement based on Till Nagel's tutorial: 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html 
--------------------------------------------------------------------------- */

int mm;

ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

ArrayList<Circle> allCircles;
ArrayList<Arc> allArcs;

PImage worldMap;
PVector worldMapPos;
PVector worldMapSize;
PVector center;

//animation
int interval;
int transition1;
int transition2;
int transition3;

PFont glober;

String selectedType; //"arc"/"circle"
Country selectedCountry;

void setup() {
  size(920, 1400);
  colorMode(HSB, 255, 255, 255);
  mm = 3;
//  glober = createFont("GloberBold", 8);
  textSize(8);
//  center = new PVector(600, height/2);
  center = new PVector(600, 350);

  //Loading and positioning map
  worldMap = loadImage("world_map_equirectangular.png");
//  worldMapSize = new PVector(worldMap.width * 2.5, worldMap.height * 3);
//  worldMapSize = new PVector(worldMap.width, worldMap.height);
  worldMapSize = new PVector(720, 420);
  worldMapPos = new PVector(center.x - worldMapSize.x/2 - 65, center.y - worldMapSize.y/2 + 65);
  
  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv");
  for(int i = 0; i < allCountries.size(); i++){
    Country c = allCountries.get(i);
    c.setColor(i);
  }
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");
  
  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  //Players' positions in the arc will be based on this sorted list
//  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  String[] sortedCountries = new String[allCountries.size()];
  for(int i = 0; i < allCountries.size(); i++){
    sortedCountries[i] = allCountries.get(i).name;
  } 
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");  //Sorting the arcs
  
  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
  for(Arc a : allArcs){
    //Sorting the list
    a.teamPlayers = sortPlayers(a.teamPlayers, sortedCountries, "current");
    //Linking to the circles
    a.linkCircles();
    a.setPlayersPositions();
  }

  //Now that we've linked players and circles,
  //let's calculate the circle radius based on the number
  //of players linked to it
  int maxPlayers = getMax(allCircles);
  for (Circle c : allCircles) {
    c.setRadius(maxPlayers);
  }  

  debug();
  
  selectedType = "";
  
  interval = 1000;
  transition1 = millis() + 3*interval;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
}

void draw() {  
  background(255);
  //Map
  if(millis() < transition2){
    float alpha = map(transition2 - millis(), interval, 0, 200, 0);
    alpha = constrain(alpha, 0, 200);
    tint(255, alpha);
    image(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);
  }
  
  PVector textPos = new PVector(20, 200);
  float leading = 10;  

  //Arcs
  if(millis() > transition1){
    for(Arc a : allArcs){  
      if(millis() > transition2){
        if(selectedType.equals("") ||
          (selectedType.equals("arc") && selectedCountry == a.thisCountry)){

          if(!selectedType.equals("")){
            fill(0);
            textAlign(LEFT);
            text(a.thisCountry.name.toUpperCase() + ": grupo " + a.thisCountry.group.toUpperCase(), textPos.x, textPos.y);
            textPos.y += leading;            
          }
          
          for(Player p : a.teamPlayers){
            p.display();
            
            if(!selectedType.equals("")){
              text(p.name, textPos.x, textPos.y);
              text(p.club + " (" + p.current.name + ")", textPos.x + 100, textPos.y);
              textPos.y += leading;            
            }
          }
        }
      }      
      a.display();
    }
  }
  
  
  
  //Circles
  textPos = new PVector(20, 200);
  for (Circle c : allCircles) {
    if(selectedType.equals("circle") && selectedCountry == c.thisCountry){
      
      fill(0);
      textAlign(LEFT);
      text(c.thisCountry.name.toUpperCase() + ": " + c.clubPlayers.size() + " jogadores", textPos.x, textPos.y);
      textPos.y += leading;
      
      for(Player p : c.clubPlayers){
        p.display();

        text(p.name, textPos.x, textPos.y);
        textAlign(CENTER);
        text(p.origin.abbreviation, textPos.x + 110, textPos.y);
        textAlign(LEFT);
        text(p.club, textPos.x + 130, textPos.y);
        textPos.y += leading;
      }
    }    
    c.update();
    c.display();    
  }  
}

void mousePressed(){
  selectedType = "";
  for (Arc a : allArcs) {
    if(a.isHovering()){
      if(!selectedType.equals("arc") && selectedCountry != a.thisCountry){
        selectedType = "arc";
        selectedCountry = a.thisCountry;
        dimColors();
        a.isActive = true;
        
        for(Player p : a.teamPlayers){
          p.currCountry.isActive = true;
        }
        
      }else{
        selectedType = "";
      }
    }
  }
  
  for (Circle c : allCircles) {
    if(c.isHovering()){
      //If it' not already selected... Select!
      if(!selectedType.equals("circle") && selectedCountry != c.thisCountry){
        selectedType = "circle";
        selectedCountry = c.thisCountry;
        dimColors();
        c.isActive = true;
        
        for(Player p : c.clubPlayers){
//          println(p.name + "\t" + p.originCountry);
          p.originCountry.isActive = true;
        }        
        
      }else{
        selectedType = "";
      }
    }
  }
  if(selectedType.equals("")){
    selectedCountry = null;
    restoreColors();
  }  
}

void mouseMoved(){
  boolean changeCursor = false;
  
  for (Arc a : allArcs) {
    if(a.isHovering()){
      changeCursor = true;
      a.isOver = true;
    }else{
      a.isOver = false;
    }
  }   
  
  for (Circle c : allCircles) {
    color newColor = c.thisCountry.myColor;
    if(c.isHovering()){
      changeCursor = true;
      c.isOver = true;
    }else{
      c.isOver = false;
    }
  }  

  if(changeCursor){
    cursor(HAND);
  }else{
    cursor(ARROW);
  }
}

void dimColors(){
  for(Arc a: allArcs){
    a.isActive = false;
  }  
  for(Circle c: allCircles){
    c.isActive = false;
  }
}

void restoreColors(){
  for(Arc a: allArcs){
    a.isActive = true;
  }   
  for(Circle c: allCircles){
    c.isActive = true;
  }
}

ArrayList<Country> initCountries(String filename){
  ArrayList<Country> tempList = new ArrayList<Country>();
  String[] tableString = loadStrings(filename);
    for (String lineString : tableString) {
      String[] myLine = split(lineString, "\t");
      String name = trim(myLine[0]);
      String abbreviation = trim(myLine[1]);
      String group = trim(myLine[2]);
      Country thisCountry = new Country(name, abbreviation, group);
//      thisCountry.setColor();
      tempList.add(thisCountry);
//      println(name + "\t" + abbreviation + "\t" + group);
    }
    return tempList;
}

ArrayList<Circle> loadCirclesCoordinates(String filename) {
  ArrayList<Circle> tempList = new ArrayList<Circle>();
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[0]);
    float lat = parseFloat(myLine[1]);
    float lng = parseFloat(myLine[2]);

    for (Country c : allCountries) {
      if(name.equals(c.name)){
        Circle myCircle = new Circle(c, lat, lng);
        tempList.add(myCircle);
//        println(name);
        break;
      }
    }
  }
  return tempList;
}

ArrayList<Player> loadPlayers(String filename) {
  ArrayList<Player> tempList = new ArrayList<Player>();  
  
  String[] tableString = loadStrings(filename);
  for (String lineString : tableString) {
    String[] myLine = split(lineString, "\t");
    String name = trim(myLine[1]);
    String originString = trim(myLine[0]);
    String club = trim(myLine[2]);
    String currentString = trim(myLine[3]);
    
    Country origin = new Country("", "", "");
    for (Country c : allCountries) {
      if(originString.equals(c.name)){
        origin = c;
        break;
      }
    }
    Country current = new Country("", "", "");
    for (Country c : allCountries) {
      if(currentString.equals(c.name)){
        current = c;
        break;
      }
    }
    Player p = new Player(name, origin, club, current);
    tempList.add(p);    
  }
  return tempList;
}

ArrayList<Player> sortPlayers(ArrayList<Player> thesePlayers, String[] sortedCountries, String criteria) {
  ArrayList<Player> tempList = new ArrayList<Player>();
  for(String s : sortedCountries){
    s = trim(s);
  }  
  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {
    //Looping through each object
    for (int j = 0; j < thesePlayers.size(); j++) {
      String thisValue = "";
      if(criteria.equals("origin")){
        thisValue = thesePlayers.get(j).origin.name;
      }else if(criteria.equals("current")){
        thisValue = thesePlayers.get(j).current.name;
      }
      //If the sorted value is found...
      if (sortedCountries[i].equals(thisValue)) {
        //Add the object to the temporary list
        tempList.add(thesePlayers.get(j));
      }
    }
  }
  return tempList;
}

ArrayList<Arc> createArcs(ArrayList<Player> thesePlayers){
  
  ArrayList<Arc> tempList = new ArrayList<Arc>();
  
  Country prevCountry = new Country("", "", "");
  ArrayList<Player> tempPlayers = new ArrayList<Player>();
  
  for(int i = 0; i < thesePlayers.size(); i++){
    
    Player p = thesePlayers.get(i);
    
    //If the current player's country is different from the previous...
    if(!p.origin.name.equals(prevCountry.name)){
      //If it is not the first player...
      if(i != 0){
        //Create a new team based on the previous information
        tempList.add(new Arc(prevCountry, tempPlayers));      
      } 
      //Cleaned the list up
      tempPlayers = new ArrayList();
    }
//    if(p.origin.name.equals("Uruguai")){
//      println(p.name + "\t" + p.current.name);
//    }
    tempPlayers.add(p);
    
    //Wait! Was it the last player?
    if(i == thesePlayers.size() - 1){
      tempList.add(new Arc(prevCountry, tempPlayers));   
    }    
    
    prevCountry = p.origin;    
  }
  return tempList;
}

ArrayList<Arc> setArcs(ArrayList<Arc> theseArcs){
  
  ArrayList<Arc> tempList = theseArcs;
  float angleOffset = 0.005 * PI; //Distance between each arc
    
  //Filling the lower part in
  float radius = 315;
  float x = center.x;
  float y = center.y;
  float startAngle = 1.2 * PI;
  float endAngle = 0;
  
  for(int i = 0; i < tempList.size(); i++){
    Arc a = tempList.get(i);
    float arcLength = (1.2*PI - (tempList.size() - 1) * angleOffset) / tempList.size();
    
    endAngle = startAngle + arcLength;
    
    a.setArcParam(x, y, radius, startAngle, endAngle);
    
    startAngle = endAngle + angleOffset;  //next
    
    //LOWER arcs
    if(i == tempList.size()/2 - 1){
      startAngle -= 1.6 * PI;
    }
  }
  
  return tempList;
}

int getMax(ArrayList<Circle> myList) {
  int max = 0;
  for (Circle c : myList) {
    if (c.totalPlayers > max) {
      max = c.totalPlayers;
    }
  }
  return max;
}

void debug() {
//  for(Country c : allCountries){
//    println(c.name + "\t" + c.group + "\t" + c.myColor);
//  }
//  for(Circle c: allCircles){
//    print(c.thisCountry.name);
//    for(Player p : c.clubPlayers){
//      println("\t" + p.name + " \t" + p.origin.name);
//    }
//  }  
//  for (Player p : allPlayers) {
//    if(p.origin.name.equals("Uruguai")){
//      println(p.name + " \t" + p.origin.name + " \t" + p.current.name);
//    }
//  }

//  for(Arc a: allArcs){
//    if(a.thisCountry.name.equals("Uruguai")){
//      print(a.thisCountry.name + ":" + a.teamPlayers.size());
//      for(Player p : a.teamPlayers){
//        println("\t" + p.name + "\t" + p.current.name);
//      }
//    }
//  }
}
//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    teamPlayers = _teamPlayers;
    
    isOver = false;
    isActive = true;
  }

  void setArcParam(float _x, float _y, float _r, float _startAngle, float _endAngle){
    pos = new PVector(_x, _y);
    radius = _r;
    startAngle = _startAngle;
    endAngle = _endAngle;
  }  
  
  void linkCircles(){
    //Club country
    for (Circle c : allCircles) {
      for (Player p : teamPlayers) {
        if (p.current.name.equals(c.thisCountry.name)) {
          p.currCountry = c;
          c.totalPlayers ++;
          c.clubPlayers.add(p);
          
          p.originCountry = this;
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle, endAngle);   
      float offset = 40*mm;  //distance from arc to control point
      PVector p1 = new PVector(0,0);
      PVector p2 = new PVector(0,0);
      p1.x = pos.x + cos(angle) * (radius - 4*mm);
      p1.y = pos.y + sin(angle) * (radius - 4*mm);
      p2.x = pos.x + cos(angle) * (radius - 4*mm - offset);
      p2.y = pos.y + sin(angle) * (radius - 4*mm - offset);
      
      PVector p4 = p.currCountry.pos;
//      PVector p3 = PVector.lerp(p2, p4, 0.5);
      //lerp on a vector doesn't work in javaScript mode
      PVector p3 = new PVector(p2.x, p2.y);
      p3.x = lerp(p2.x, p4.x, 0.5);
      p3.y = lerp(p2.y, p4.y, 0.5);
  
      p.setPos(p1, p2, p3, p4);
      p.setAngle(angle);
    }
  }  
  
  boolean isHovering(){
    float mouseAngle = atan2(mouseY - center.y, mouseX - center.x);
    if(mouseAngle < 0) {
      mouseAngle = TWO_PI - abs(mouseAngle); 
    }
    float distance = dist(mouseX, mouseY, center.x, center.y); 
    if(startAngle < mouseAngle && mouseAngle < endAngle &&
       radius - 4*mm < distance && distance < radius + 4*mm){
      return true;
    }else{
      return false;
    }
  }
  
  void display(){
    //TRANSITION
    float currAngle = 0;
    float alpha = 0;
    if(millis() < transition2){
      currAngle = map(transition2 - millis(), interval, 0, startAngle, endAngle);
      currAngle = constrain(currAngle, 0, endAngle);
      alpha = map(transition2 - millis(), interval, 0, 0, 255);
      alpha = constrain(alpha, 0, 255);
    }else{
      currAngle = endAngle;
      alpha = 255;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      newColor = color(hue(newColor), saturation(newColor) - 100, brightness(newColor));
    }
    if(!isActive){
      newColor = color(0, 0, 0, 30);
    }
    
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(newColor);
      strokeWeight(8*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      PVector boxSize = new PVector(15*mm, 4*mm);  
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
//      textFont(glober);      
//      textSize(10);    
      textLeading(16);  
      fill(0, alpha);      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
        if(angle < PI){
          rotate(angle - PI/2);
          text(thisCountry.abbreviation, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);
        }else{
          rotate(angle + PI/2);
          text(thisCountry.abbreviation, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
        }
    popMatrix();
  }
}
//Draw countries on the map
//Represent countries in which (clubs) World Cup athletes currently play 
//It is linked to players in order to update their control points
class Circle {
  PVector pos;
  PVector controlPoint;
  float radius;
  float finalRadius;
  int totalPlayers;
  
  boolean isOver;
  boolean isActive;  
  
  Country thisCountry;
  ArrayList<Player> clubPlayers;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0; 
    clubPlayers = new ArrayList<Player>();
   
    isOver = false;
    isActive = true;    
  }
  
  void setPos(float lat, float lng){
    // Equirectangular projection
    pos.x = map(lng, -180, 180, worldMapPos.x, worldMapPos.x + worldMapSize.x); 
    pos.y = map(lat, 90, -90, worldMapPos.y, worldMapPos.y + worldMapSize.y);    
  }
  
  void setControlPoint(){
      float offset = 30*mm;
      float distance = dist(pos.x, pos.y, center.x, center.y);
      float angle = atan2(pos.y - center.y, pos.x - center.x);
      if(angle < 0) {
        angle = TWO_PI - abs(angle); 
      }    
      controlPoint.x = center.x + cos(angle) * (distance + finalRadius + offset);
      controlPoint.y = center.y + sin(angle) * (distance + finalRadius + offset);  
  }
  
  void setRadius(int max){
    finalRadius = map(totalPlayers, 1, max, 6, 50);
    setControlPoint();    
  }
  
  void update(){
    float padding = 10; //space in between the circles
    for(Circle c : allCircles){
      float distance = dist(c.pos.x, c.pos.y, pos.x, pos.y);
      float minDistance = c.radius + radius + padding;
      if(distance < minDistance && distance > 0){
        PVector escape = new PVector(pos.x - c.pos.x,
                                     pos.y - c.pos.y);
        escape.normalize();
        pos.x += escape.x * 1.2;
        pos.y += escape.y * 1.2;
        
        setControlPoint();        
      }    
    }  
  }  
  
  boolean isHovering(){
    if(dist(mouseX, mouseY, pos.x, pos.y) < radius){
      return true;
    }else{
      return false;
    }
  }

  void display() {
    //TRANSITION
    if(radius < finalRadius * 0.99){
      radius += (finalRadius - radius) * 1;
    }else{
      radius = finalRadius;
    }
    
    color newColor = thisCountry.myColor;
    if(isOver){
      //If it's NOT one of the "gray" countries...
      if(saturation(newColor) > 100){
        newColor = color(hue(newColor), saturation(newColor) - 100, brightness(newColor));
      }else{
        newColor = color(hue(newColor), saturation(newColor), brightness(newColor) + 20);
      }
    }
    if(!isActive){
      newColor = color(0, 0, 0, 30);
    }    
    
    noStroke();  
    fill(newColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    if(isOver || isActive){
      PVector boxSize = new PVector(14*mm, 6*mm);
  //    rect(pos.x - boxSize.x/2, pos.y - boxSize.y/2, boxSize.x, boxSize.y);
      fill(0);
  //    textFont(glober);
      textSize(8);
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      textLeading(8);
      text(thisCountry.name, pos.x - boxSize.x/2, pos.y - boxSize.x/2, boxSize.x, boxSize.x);
      
      if(selectedType.equals("circle") && isActive){
        text(clubPlayers.size(), pos.x, pos.y + boxSize.y/2);
      }
    }
  }
}

//Do not draw
//Only a sort of HashMap to store countries x colors
class Country{
  String name;
  String abbreviation;
  String group;
  color myColor;
  
  Country(String _name, String _abbreviation, String _group){
    name = _name;
    abbreviation = _abbreviation;
    group = _group;
  }
  
  void setColor(int i){
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float hu = 0;
    float sa = 0;
    float br = 0;

//    //hue
    if(groupInt % 2 != 0){
      hu = map(groupInt, 96, 104, 100, 235);
      hu = hu + (i%4)*4;
    }else{
      hu = map(groupInt, 98, 104, 0, 55);
      hu = hu - (i%4)*2;
    }
    hu = constrain(hu, 0, 255);
    
    sa = 255;
    
    //Indigo blue
    if(140 < hu && hu < 200){
      sa -= 100;
    }
       
    br = 255;
    
    if(groupInt < 97){  //gray
//      hu = 40;
//      sa = 90;
//      br = 130;
      hu = 40;
      sa = 90;
      br = 200;
    }
    myColor = color(hu, sa, br);
  }
}
//Draws lines
class Player {
  String name, club;
  Country origin, current;
  ArrayList<PVector> anchors;
  float angle;
  
  Circle currCountry;
  Arc originCountry;

  Player(String _name, Country _origin, String _club, Country _current) {
    name = _name;
    origin = _origin;
    club = _club;
    current = _current;
    anchors = new ArrayList<PVector>();
  }

  void setPos(PVector p1, PVector p2, PVector p3, PVector p4) {
    anchors.add(p1);
    anchors.add(p2);    
    anchors.add(p3); 
    anchors.add(p4);    
  }
  
  void setAngle(float _angle){
    angle = _angle;
  }

  void display() {
    
    float alpha = 0;
    if(millis() < transition3){
      alpha = map(transition3 - millis(), interval, 0, 0, 100);
      alpha = constrain(alpha, 0, 100);
    }else{
      alpha = 100;
    }  
    
    //Line
    noFill();
    strokeWeight(0.3*mm);
    stroke(currCountry.thisCountry.myColor, alpha);
//    line(anchors.get(0).x, anchors.get(0).y, currCountry.pos.x, currCountry.pos.y);
    bezier(anchors.get(0).x, anchors.get(0).y, 
           anchors.get(1).x, anchors.get(1).y,
           anchors.get(2).x, anchors.get(2).y,
           anchors.get(3).x, anchors.get(3).y);
//    bezier(anchors.get(0).x, anchors.get(0).y, 
//           anchors.get(1).x, anchors.get(1).y,
//           currCountry.controlPoint.x, currCountry.controlPoint.y,
//           currCountry.pos.x, currCountry.pos.y);
  }
}



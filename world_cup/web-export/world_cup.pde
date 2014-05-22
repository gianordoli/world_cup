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

PShape worldMap;
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
  size(800, 850);
  colorMode(HSB);
  mm = 3;
  glober = createFont("GloberBold", 8);
  center = new PVector(width/2, height/2);

  //Loading and positioning map
  worldMap = loadShape("world_map_equirectangular.svg");
  worldMapSize = new PVector(worldMap.width * 2.5, worldMap.height * 3);
  worldMapPos = new PVector((width - worldMapSize.x)/2 - 15*mm, (height - worldMapSize.y)/2 + 30*mm);

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
  String[] sortedCountries = loadStrings("countries_sorted_by_groups.txt");
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
  
  //Now setting connections from circle to arc, through players
  for(Arc a : allArcs){
    for(Player p : a.teamPlayers){
      p.originCountry = a;
      for(Circle c : allCircles){
        if(p.currCountry == c){
          c.clubPlayers.add(p);
        }
      }
    }
  }

  //Now that we've linked players and circles,
  //let's calculate the circle radius based on the number
  //of players linked to it
  int maxPlayers = getMax(allCircles);
  for (Circle c : allCircles) {
    c.setRadius(maxPlayers);
  }  

//  debug();
  
  selectedType = "";
  
  interval = 1000;
  transition1 = millis() + 3000;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
}

void draw() {  
  background(255, 255, 255);
//  shape(worldMap, worldMapPos.x, worldMapPos.y, worldMapSize.x, worldMapSize.y);

  if(millis() > transition1){
    
    for(Arc a : allArcs){
      
      if(millis() > transition2){
        if(selectedType.equals("") ||
          (selectedType.equals("arc") && selectedCountry == a.thisCountry)){
          for(Player p : a.teamPlayers){
            p.display();
            p.currCountry.currColor = p.currCountry.thisCountry.myColor;
          }
        }
      }      
      a.display();
    }
  }
  
  for (Circle c : allCircles) {
    if(selectedType.equals("circle") && selectedCountry == c.thisCountry){
      for(Player p : c.clubPlayers){
        p.display();
      }
    }    
    c.update();
    c.display();    
  }  
}

//void mousePressed(){
//  selectedType = "";
//  for (Arc a : allArcs) {
//    if(a.isHovering()){
//      if(!selectedType.equals("arc") && selectedCountry != a.thisCountry){
//        selectedType = "arc";
//        selectedCountry = a.thisCountry;
//        a.currColor = a.thisCountry.myColor;
//        dimColors();
//      }else{
//        selectedType = "";
//      }
//    }
//  }
//  
//  for (Circle c : allCircles) {
//    if(c.isHovering()){
//      //If it' not already selected... Select!
//      if(!selectedType.equals("circle") && selectedCountry != c.thisCountry){
//        selectedType = "circle";
//        selectedCountry = c.thisCountry;
//        c.currColor = c.thisCountry.myColor;
//        dimColors();
//      }else{
//        selectedType = "";
//      }
//    }
//  }
//  if(selectedType.equals("")){
//    selectedCountry = null;
//    restoreColors();
//  }  
//}
//
//void mouseMoved(){
//  boolean changeCursor = false;
//  
//  for (Arc a : allArcs) {
//    color newColor = a.thisCountry.myColor;
//    if(a.isHovering()){
//      changeCursor = true;
//      newColor = color(hue(newColor), saturation(newColor) - 100, brightness(newColor));
//    }else{
//      newColor = a.thisCountry.myColor;
//    }
//    if(selectedType.equals("")){
//      a.currColor = newColor;
//    }
//  }   
//  
//  for (Circle c : allCircles) {
//    color newColor = c.thisCountry.myColor;
//    if(c.isHovering()){
//      changeCursor = true;
//      //If it' not one of the gray countries
//      if(saturation(newColor) > 0){
//        newColor = color(hue(newColor), saturation(newColor) - 100, brightness(newColor));
//      }else{
//        newColor = color(hue(newColor), saturation(newColor), brightness(newColor) + 50);
//      }
//    }else{
//      newColor = c.thisCountry.myColor;
//    }
//    if(selectedType.equals("")){
//      c.currColor = newColor;
//    }
//  }  
//
//  if(changeCursor){
//    cursor(HAND);
//  }else{
//    cursor(ARROW);
//  }
//}

void dimColors(){
  for(Arc a: allArcs){
    if(!selectedType.equals("arc") || selectedCountry != a.thisCountry){
      a.currColor = color(0, 0, 0, 30);
    }
  }  
  for(Circle c: allCircles){
    if(!selectedType.equals("circle") || selectedCountry != c.thisCountry){
      c.currColor = color(0, 0, 0, 30);
    }
  }
}

void restoreColors(){
  for(Arc a: allArcs){
    a.currColor = a.thisCountry.myColor;
  }   
  for(Circle c: allCircles){
    c.currColor = c.thisCountry.myColor;
  }
}

ArrayList<Country> initCountries(String filename){
  ArrayList<Country> tempList = new ArrayList<Country>();
  String[] tableString = loadStrings(filename);
    for (String lineString : tableString) {
      String[] myLine = split(lineString, "\t");
      String name = trim(myLine[0]);
      String group = trim(myLine[1]);
      Country thisCountry = new Country(name, group);
//      thisCountry.setColor();
      tempList.add(thisCountry);
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
    
    Country origin = new Country("", "");
    for (Country c : allCountries) {
      if(originString.equals(c.name)){
        origin = c;
        break;
      }
    }
    Country current = new Country("", "");
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
  
  Country prevCountry = new Country("", "");
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
  float radius = 135*mm;
  float x = center.x;
  float y = center.y;
  float startAngle = 0.15 * PI;
  float endAngle = 0;
  
  for(int i = 0; i < tempList.size(); i++){
    Arc a = tempList.get(i);
    float arcLength = (1.4*PI - (tempList.size() - 1) * angleOffset) / tempList.size();
    
    endAngle = startAngle + arcLength;
    
    a.setArcParam(x, y, radius, startAngle, endAngle);
    
    startAngle = endAngle + angleOffset;  //next
    
    //Next arc
    if(i == tempList.size()/2 - 1){
      startAngle += 0.3 * PI;
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
  for(Country c : allCountries){
    println(c.name + "\t" + c.group + "\t" + c.myColor);
  }
  for(Circle c: allCircles){
    println(c.thisCountry.name);
  }  
  for (Player p : allPlayers) {
    println(p.name + " \t" + p.origin.name);
  }
  for(Arc a: allArcs){
    print(a.thisCountry.name + ":" + a.teamPlayers.size());
    for(Player p : a.teamPlayers){
      println("\t" + p.name);
    }
  }
}
//World cup teams
//Linked to Country (only to read colors)
//Contains list of Player

class Arc{
  PVector pos;
  float radius;
  float startAngle;
  float endAngle;
  color currColor;
  
  Country thisCountry;
  ArrayList<Player> teamPlayers;
  
  Arc(Country _thisCountry, ArrayList<Player> _teamPlayers){
    thisCountry = _thisCountry;
    currColor = thisCountry.myColor;
    teamPlayers = _teamPlayers;
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
        }
      }
    }  
  }
  
  void setPlayersPositions() { 

    for (int i = 0; i < teamPlayers.size(); i++) {
  
      Player p = teamPlayers.get(i);
      
      float angle = map(i, 0, teamPlayers.size() - 1, startAngle, endAngle);   
      float offset = 20*mm;  //distance from arc to control point
      float x1 = pos.x + cos(angle) * (radius - 4*mm);
      float y1 = pos.y + sin(angle) * (radius - 4*mm);
      float x2 = pos.x + cos(angle) * (radius - 4*mm - offset);
      float y2 = pos.y + sin(angle) * (radius - 4*mm - offset);    
  
      p.setPos(x1, y1, x2, y2);
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
    
    pushMatrix();
      translate(pos.x, pos.y);
      noFill();
      stroke(currColor);
      strokeWeight(8*mm);
      strokeCap(SQUARE);
      arc(0, 0, radius*2, radius*2, startAngle, currAngle);
      
      PVector boxSize = new PVector(15*mm, 4*mm);  
      rectMode(CORNER);
      textAlign(CENTER, CENTER);
      textFont(glober);      
//      textSize(10);    
      textLeading(10);  
      fill(0, alpha);      
      float angle = (endAngle + startAngle)/2;
      translate(cos(angle) * radius, sin(angle) * radius);
        if(angle < PI){
          rotate(angle - PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
        }else{
          rotate(angle + PI/2);
          text(thisCountry.name, - boxSize.x/2, - boxSize.x/2, boxSize.x, boxSize.x);      
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
  color currColor;
  
  Country thisCountry;
  ArrayList<Player> clubPlayers;

  Circle(Country _thisCountry, float lat, float lng) {
    thisCountry = _thisCountry;
    currColor = thisCountry.myColor;
    pos = new PVector();
    controlPoint = new PVector();
    setPos(lat, lng);
    radius = 1;
    totalPlayers = 0; 
    clubPlayers = new ArrayList<Player>(); 
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
    finalRadius = map(totalPlayers, 0, max, 2*mm, 20*mm);
    setControlPoint();    
  }
  
  void update(){
    float padding = 4*mm; //space in between the circles
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
    
    if(radius < finalRadius * 0.99){
      radius += (finalRadius - radius) * 0.2;
    }else{
      radius = finalRadius;
    }
    
    noStroke();  
    fill(currColor);
    ellipse(pos.x, pos.y, radius * 2, radius * 2);
    
    PVector boxSize = new PVector(14*mm, 4*mm);    
    fill(0);
    textFont(glober);
    textSize(8);
    rectMode(CORNER);
    textAlign(CENTER, CENTER);
    textLeading(8);
    text(thisCountry.name, pos.x - boxSize.x/2, pos.y - boxSize.x/2, boxSize.x, boxSize.x);
  }
}

//Do not draw
//Only a sort of HashMap to store countries x colors
class Country{
  String name;
  String group;
  color myColor;
  
  Country(String _name, String _group){
    name = _name;
    group = _group;
  }
  
  void setColor(int i){
    //Converting group Strint to char and to int
    int[] code = int(group.toCharArray());
    int groupInt = code[0];
    float h, s, b;

//    //hue
    if(groupInt % 2 != 0){
      h = map(groupInt, 96, 104, 100, 235);
      h += i%4 * 4;
    }else{
      h = map(groupInt, 98, 104, 0, 60);
      h -= i%4 * 2;
    }
    
    s = 255;
    
    //Indigo blue
    if(140 < h && h < 200){
      s -= 100;
    }    
    b = 255;
    
    if(groupInt < 97){  //gray
      s = 0;
      b = 170;
    }

    myColor = color(h, s, b);  
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

  void setPos(float x1, float y1, float x2, float y2) {
    anchors.add(new PVector(x1, y1));
    anchors.add(new PVector(x2, y2));    
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
           currCountry.pos.x, currCountry.pos.y,
           currCountry.pos.x, currCountry.pos.y);
//    bezier(anchors.get(0).x, anchors.get(0).y, 
//           anchors.get(1).x, anchors.get(1).y,
//           currCountry.controlPoint.x, currCountry.controlPoint.y,
//           currCountry.pos.x, currCountry.pos.y);
  }
}



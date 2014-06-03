/* @pjs preload="galileu.svg, diagram.svg"; */ 

/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com
 
 Geoplacement based on Till Nagel's tutorial: 
 http://btk.tillnagel.com/tutorials/geo-tagging-placemaker.html 
 --------------------------------------------------------------------------- */

color bgColor;
color labelColor;
color inactiveColor;

ArrayList<Player> allPlayers;
ArrayList<Country> allCountries;

ArrayList<Circle> allCircles;
ArrayList<Arc> allArcs;

PVector worldMapPos;
PVector worldMapSize;
PVector center;

//animation
int interval;
int transition1;
int transition2;
int transition3;
int transition4;
int showTutorial;
boolean showList;

PFont archivoNarrow;
PFont archivoNarrowBold;
PFont bitter;
PFont bitterBold;
PShape galileu;
PShape diagram;

String selectedType; //"arc" or "circle"
Country selectedCountry;

TextArea myTextArea;

void setup() {
  size(920, 700);
  colorMode(HSB, 255, 255, 255);

  bgColor = color(60);
  labelColor = color(150);
  inactiveColor = color(255, 80);

  //JS font loading
  archivoNarrow = createFont("Archivo Narrow", 10);
  archivoNarrowBold = createFont("Archivo Narrow Bold", 10);
  bitter = createFont("Bitter", 10);
  bitterBold = createFont("Bitter Bold", 10);  

  //Processing font loading
//  archivoNarrow = createFont("ArchivoNarrow-Regular", 10);
//  archivoNarrowBold = createFont("ArchivoNarrow-Bold", 10);
//  bitter = createFont("Bitter-Regular", 10);
//  bitterBold = createFont("Bitter-Bold", 10);  
  
  galileu = loadShape("galileu.svg");
  diagram = loadShape("diagram.svg");
  myTextArea = new TextArea(20, 240, 220, 420);

  center = new PVector(620, 350);

  //positioning "map"
  worldMapSize = new PVector(780, 420);
  worldMapPos = new PVector(center.x - worldMapSize.x/2 - 40, center.y - worldMapSize.y/2 + 65);

  /*----- COUNTRIES -----*/
  allCountries = initCountries("countries_groups.tsv");
  for (int i = 0; i < allCountries.size(); i++) {
    Country c = allCountries.get(i);
    c.setColor(i);
  }
  allCircles = loadCirclesCoordinates("coordinates_pt.tsv");

  /*------ PLAYERS ------*/
  allPlayers = loadPlayers("players_pt.tsv"); 
  //Players' positions in the arc will be based on this sorted list
  //  String[] sortedCountries = loadStrings("countries_sorted_by_angle_pt.txt");
  String[] sortedCountries = new String[allCountries.size()];
  for (int i = 0; i < allCountries.size(); i++) {
    sortedCountries[i] = allCountries.get(i).name;
  } 
  allPlayers = sortPlayers(allPlayers, sortedCountries, "origin");  //Sorting the arcs

  /*------ ARCS ------*/
  allArcs = createArcs(allPlayers);  //Creating arcs based on players list
  allArcs = setArcs(allArcs);        //Setting arc angle
  for (Arc a : allArcs) {
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

  selectedType = "";

  interval = 1000;
  transition1 = millis() + 3*interval;
  transition2 = transition1 + interval;
  transition3 = transition2 + interval;
  transition4 = transition3 + interval;
  showTutorial = 0;
  showList = false;
  
  debug();  
}

void draw() {  
  background(bgColor);

  PVector textPos = new PVector(20, 200);
  float leading = 13;  

  //Default/initial/show all
  if (selectedType.equals("") && millis() > transition1) {
  for(int i = 0; i < allArcs.size(); i++){
    Arc a = allArcs.get(i);
    a.display(i);
      if (millis() > transition2) {
        //Players
        for (Player p : a.teamPlayers) {
          p.display();
        }
        if (transition3 < millis() && millis() < transition4) {
          showTutorial = 1;
        }
      }
    }
  }
  
  //Players
  if (selectedType.equals("arc")){
    for(int i = 0; i < allArcs.size(); i++){
      Arc a = allArcs.get(i);  
      if (a.isActive) {      
        for (Player p : a.teamPlayers) {
          p.display();
        }
        if(showList){
          drawPlayersList(a.thisCountry, 0);
        }
      }
    }
  }else if(selectedType.equals("circle")){
    for (Circle c : allCircles) {
      if(c.isActive) {      
        for (Player p : c.clubPlayers) {
          p.display();
        }
        if(showList){
          drawPlayersList(c.thisCountry, c.clubPlayers.size());
        }        
      }      
    }
  }

  //Arcs (selected)
  if (!selectedType.equals("")){
    for(int i = 0; i < allArcs.size(); i++){
      Arc a = allArcs.get(i);
      a.display(i);
    }
  }

  //Circles
  for (Circle c : allCircles) {    
    c.update();
    c.display();
  }  

  //Tutorial?
  if (showTutorial > 0) {
    drawTutorial();
  }
  else if(millis() > transition4){
    drawHeader();
    drawLabels();
  }

  //Logo
  shape(galileu, 816, 668);
  
  //Tutorial
  shape(diagram, 852, 10);
  fill(255);
  textFont(archivoNarrowBold);
  textSize(13);
  textAlign(CENTER, TOP);
  text("COMO LER", 880, 76);
}

void mouseReleased() {
  
  //Have I just finished dragging my scrollbar? 
  //If yes, no need to mess with my selection.
  //If not, let's check what I am trying to select
    //Also, I need to check if not in "tutorial mode"
  if(!myTextArea.isDragging && showTutorial == 0){
    
    //Let's assume that I'll deselect everything anyway
    selectedType = ""; 
    Boolean click = false;
    
    //Checking arcs
    for (Arc a : allArcs) {
      
      //It looks like my mouse was over something when I pressed it!
      if (a.isHovering()) {
        
        //Ok, select this something — unless it is the smae thing I had before
        if (!selectedType.equals("arc") && selectedCountry != a.thisCountry) {
          selectedType = "arc";
          selectedCountry = a.thisCountry;
          dimColors();        
          a.isActive = true;
  
          for (Player p : a.teamPlayers) {
            p.isActive = true;
            p.currCountry.isActive = true;
          }
          showList = true;
          setTextArea();
          click = true;
        }
      }
    }
  
    //Checking circles
    for (Circle c : allCircles) {
      if (c.isHovering()) {
        //If it' not already selected... Select!
        if (!selectedType.equals("circle") && selectedCountry != c.thisCountry) {
          selectedType = "circle";
          selectedCountry = c.thisCountry;
          dimColors();
          c.isActive = true;
  
          for (Player p : c.clubPlayers) {
            p.isActive = true;
            p.originCountry.isActive = true;
          }
          showList = true;
          setTextArea();
          click = true;
        }
      }
      
      //I I went trhough it all and no selection was made,
      //I was really trying to deselect everything. So...
      if (!click) {
        selectedCountry = null;
        restoreColors();
        showList = false;      
      }      
    }
  }
  
  //TUTORIAL
  if(showTutorial > 0){
    Arc a = allArcs.get(16);
    selectedType = "arc";
    selectedCountry = a.thisCountry;
    dimColors();
    a.isActive = true;
    for (Player p : a.teamPlayers) {
      p.isActive = true;
      p.currCountry.isActive = true;
    }         
    showTutorial ++;    
    
    if(showTutorial > 2){
      showTutorial = 0;
      selectedCountry = null;
      restoreColors();
      showList = false;
      selectedType = "";
    }
  }
  
  if(852 < mouseX && mouseX < 852 + diagram.width &&
     15 < mouseY && mouseY < 15 + diagram.height){
      Circle c = allCircles.get(5);
      selectedType = "circle";
      selectedCountry = c.thisCountry;
      dimColors();
      c.isActive = true;
      for (Player p : c.clubPlayers) {
        p.isActive = true;
        p.originCountry.isActive = true;
      }         
      showTutorial = 1;
      showList = false;
  }  
  
  //Whatever I was doing, I' not dragging my scrollbar anymore!
  myTextArea.isDragging = false;  
}

void mousePressed(){ 
  if(myTextArea.isHovering()){
    myTextArea.isDragging = true;
  }
}

void mouseDragged(){
  myTextArea.drag();
}

void mouseMoved() {
  boolean changeCursor = false;

  for (Arc a : allArcs) {
    if (a.isHovering()) {
      changeCursor = true;
      a.isOver = true;
    }
    else {
      a.isOver = false;
    }
  }   

  for (Circle c : allCircles) {
    color newColor = c.thisCountry.myColor;
    if (c.isHovering()) {
      changeCursor = true;
      c.isOver = true;
    }
    else {
      c.isOver = false;
    }
  }  
  
  if(myTextArea.isHovering()){
    changeCursor = true;
  }

  //COMO LER
  if(852 < mouseX && mouseX < 852 + diagram.width &&
     15 < mouseY && mouseY < 15 + diagram.height + 20){
      changeCursor = true;
  }

  if (changeCursor) {
    cursor(HAND);
  }
  else {
    cursor(ARROW);
  }
}

void dimColors() {
  
  for (Arc a: allArcs) {
    a.isActive = false;
    for (Player p: a.teamPlayers) {
      p.isActive = false;
    }
  }  
  for (Circle c: allCircles) {
    c.isActive = false;
  }
}

void restoreColors() {
  for (Arc a: allArcs) {
    a.isActive = true;
    for (Player p: a.teamPlayers) {
      p.isActive = true;
    }
  }   
  for (Circle c: allCircles) {
    c.isActive = true;
  }
}

ArrayList<Country> initCountries(String filename) {
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
      if (name.equals(c.name)) {
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
      if (originString.equals(c.name)) {
        origin = c;
        break;
      }
    }
    Country current = new Country("", "", "");
    for (Country c : allCountries) {
      if (currentString.equals(c.name)) {
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
  for (String s : sortedCountries) {
    s = trim(s);
  }  
  //Looping through each sorted value
  for (int i = 0; i < sortedCountries.length; i++) {
    //Looping through each object
    for (int j = 0; j < thesePlayers.size(); j++) {
      String thisValue = "";
      if (criteria.equals("origin")) {
        thisValue = thesePlayers.get(j).origin.name;
      }
      else if (criteria.equals("current")) {
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

ArrayList<Arc> createArcs(ArrayList<Player> thesePlayers) {

  ArrayList<Arc> tempList = new ArrayList<Arc>();

  Country prevCountry = new Country("", "", "");
  ArrayList<Player> tempPlayers = new ArrayList<Player>();

  for (int i = 0; i < thesePlayers.size(); i++) {

    Player p = thesePlayers.get(i);

    //If the current player's country is different from the previous...
    if (!p.origin.name.equals(prevCountry.name)) {
      //If it is not the first player...
      if (i != 0) {
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
    if (i == thesePlayers.size() - 1) {
      tempList.add(new Arc(prevCountry, tempPlayers));
    }    

    prevCountry = p.origin;
  }
  return tempList;
}

ArrayList<Arc> setArcs(ArrayList<Arc> theseArcs) {

  ArrayList<Arc> tempList = theseArcs;
  float angleOffset = 0.005 * PI; //Distance between each arc

  //Filling the lower part in
  float radius = 315;
  float x = center.x;
  float y = center.y;
  float startAngle = 1.2 * PI;
  float endAngle = 0;
  float direction = 1;

  for (int i = 0; i < tempList.size(); i++) {
    Arc a = tempList.get(i);
    float arcLength = (1.2*PI - (tempList.size() - 1) * angleOffset) / tempList.size();

    endAngle = startAngle + arcLength * direction;

    if (startAngle < endAngle) {  //Upper arcs
      a.setArcParam(x, y, radius, startAngle, endAngle);
    }
    else {                      //Lower arcs
      a.setArcParam(x, y, radius, endAngle, startAngle);
    }

    startAngle = endAngle + angleOffset * direction;  //next

    //lower arcs
    if (i == tempList.size()/2 - 1) {
      startAngle -= PI;
      direction = -1;
    }
  }

  return tempList;
}

void setTextArea(){
  int nLines = 0;
  String[] col1 = new String[0];
  String[] col2 = new String[0]; 
  String[] col3 = new String[0];
  
  if(selectedType.equals("arc")){
    for (Arc a : allArcs) {  
      if (a.isActive) {
        for (Player p : a.teamPlayers) {
          if (p.isActive) {
            nLines ++;
            col1 = expand(col1, col1.length + 1);
            col2 = expand(col2, col2.length + 1);
            col1[col1.length - 1] = p.name;
            col2[col2.length - 1] = p.club + " (" + p.current.abbreviation + ")"; 
          }
        }
      }
    }
    
  }else if(selectedType.equals("circle")){

    for (Circle c : allCircles) {  
      if (c.isActive) {
        for (Player p : c.clubPlayers) {
          if (p.isActive) {
            nLines ++;
            col1 = expand(col1, col1.length + 1);
            col2 = expand(col2, col2.length + 1);
            col3 = expand(col3, col3.length + 1);
            col1[col1.length - 1] = p.name;
            col2[col2.length - 1] = p.origin.abbreviation.toUpperCase();
            col3[col3.length - 1] = p.club; 
          }
        }
      }
    }
  }  
//  printArray(col1);
//  printArray(col2);
  myTextArea.setText(col1, col2, col3);
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
//    println(c.thisCountry.name);
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

/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 Gabriel Gianordoli
 gianordoligabriel@gmail.com
 
 Extracting list of countries from original spreadsheet
--------------------------------------------------------------------------- */

void setup(){
  StringList countries = new StringList();
  
  String[] tableString = loadStrings("players_pt.tsv");
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    if(!countries.hasValue(myLine[0])){
      countries.append(myLine[0]);
    }
    if(!countries.hasValue(myLine[3])){
      countries.append(myLine[3]);
    }    
  }
  println(countries);
  
  String[] countriesArray = new String[countries.size()];
  for(int i = 0; i < countries.size(); i++){
    countriesArray[i] = countries.get(i);
  }
  saveStrings("countries_list_pt.txt", countriesArray);
}

void draw(){

}

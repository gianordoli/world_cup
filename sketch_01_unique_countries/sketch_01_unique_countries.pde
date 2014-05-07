//Loading data to extract a list of unique countries
void setup(){
  StringList countries = new StringList();
  
  String[] tableString = loadStrings("players.tsv");
  for(String lineString : tableString){
    String[] myLine = split(lineString, "\t");
    if(!countries.hasValue(myLine[0])){
      countries.append(myLine[0]);
    }
    if(!countries.hasValue(myLine[3])){
      countries.append(myLine[3]);
    }    
  }
//  println(allCountries);
  
  String[] countriesArray = new String[countries.size()];
  for(int i = 0; i < countries.size(); i++){
    countriesArray[i] = countries.get(i);
  }
  saveStrings("countries_list.txt", countriesArray);
}

void draw(){

}

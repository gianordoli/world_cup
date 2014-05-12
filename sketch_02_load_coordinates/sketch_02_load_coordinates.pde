/* ---------------------------------------------------------------------------
 World Cup 2014: Teams vs Clubs
 2014, for Galileu Magazine, Brazil
 gianordoligabriel@gmail.com
 
 This sketch only loads the coordinates for geoplacing the countries
 Using Temboo to access Yahoo API
 You'll need your own credentials to access it. Just replace "credentials.txt" 
--------------------------------------------------------------------------- */

import com.temboo.core.*;
import com.temboo.Library.Yahoo.PlaceFinder.*;

// Create a session using your Temboo account application details
TembooSession session;

String[] countriesCoordinates;
JSONArray allResults;

void setup() {
  
  String[] myCredentials = loadStrings("credentials.txt");
  session = new TembooSession("gianordoli", "myFirstApp", myCredentials[0]);
  allResults = new JSONArray();  

  String[] allCountries = loadStrings("countries_list_en.txt");
  for(int i =0; i < allCountries.length; i++){
    allCountries[i] = trim(allCountries[i]);
    allCountries[i] = allCountries[i].toLowerCase();
    println(allCountries[i]);
  }
  countriesCoordinates = new String[allCountries.length];
  
  for(int i = 0; i < allCountries.length; i++){
    // Run the FindByAddress Choreo function
    runFindByAddressChoreo(allCountries[i], i);
  }

  exit();  
}

void runFindByAddressChoreo(String address, int index) {
  println("serching for: " + address);
  
  // Create the Choreo object using your Temboo session
  FindByAddress findByAddressChoreo = new FindByAddress(session);

  // Set credential
  findByAddressChoreo.setCredential("yahooParsons");

  // Set inputs
  findByAddressChoreo.setResponseFormat("json");
  findByAddressChoreo.setAddress(address);

  // Run the Choreo and store the results
  FindByAddressResultSet findByAddressResults = findByAddressChoreo.run();
  
  // Print results
//  println(findByAddressResults.getResponse());
    allResults.append(parseJSONObject(findByAddressResults.getResponse()));
    
    String country, latitude, longitude;
    
    JSONObject obj = parseJSONObject(findByAddressResults.getResponse());
    JSONObject query = obj.getJSONObject("query");
    JSONObject results = query.getJSONObject("results");
    if(address.equals("england") || address.equals("scotland") || address.equals("wales")){
      println("United Kingdom");
      JSONArray ResultArray = results.getJSONArray("Result");
      country = ResultArray.getJSONObject(1).getString("state");
      latitude = ResultArray.getJSONObject(1).getString("offsetlat");
      longitude = ResultArray.getJSONObject(1).getString("offsetlon");
    }else{
      JSONObject Result = results.getJSONObject("Result");
      country = Result.getString("country");
      latitude = Result.getString("offsetlat");
      longitude = Result.getString("offsetlon"); 
    }
    println("country:" + country + "\t latitude: " + latitude + "\t longitude: " + longitude);
    countriesCoordinates[index] = country + "\t" + latitude + "\t" + longitude;
    saveJSONArray(allResults, "coordinates_en.json");
    saveStrings("coordinates_en.tsv", countriesCoordinates);
}

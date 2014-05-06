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
  
  createJSONArray("countries.txt");
  parseCoordinates();
  exit();  
}

void createJSONArray(String countriesFilename){
  
  String[] allCountries = loadStrings(countriesFilename);
  countriesCoordinates = new String[allCountries.length];
  
  for(int i = 0; i < allCountries.length; i++){
    // Run the FindByAddress Choreo function
    runFindByAddressChoreo(allCountries[i], i);
  }
//  println(allResults);
  saveJSONArray(allResults, "coordinates.json");  
}

void parseCoordinates(){
  for(int i = 0; i < allResults.size(); i++){
    JSONObject obj = allResults.getJSONObject(i);
    JSONObject query = obj.getJSONObject("query");
    JSONObject results = query.getJSONObject("results");
    JSONObject Result = results.getJSONObject("Result");
    String country = Result.getString("country");
    String latitude = Result.getString("latitude");
    String longitude = Result.getString("longitude");
    println("latitude: " + latitude + ", longitude: " + longitude);
  
    countriesCoordinates[i] = country + "\t" + latitude + "\t" + longitude;    
  }
  saveStrings("coordinates.tsv", countriesCoordinates);
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
}

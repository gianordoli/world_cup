import com.temboo.core.*;
import com.temboo.Library.Yahoo.PlaceFinder.*;

// Create a session using your Temboo account application details
TembooSession session;

void setup() {
  String[] myCredentials = loadStrings("credentials.txt");
//  print(myCredentials[0]);
  session = new TembooSession("gianordoli", "myFirstApp", myCredentials[0]);
  // Run the FindByAddress Choreo function
  runFindByAddressChoreo();
}

void runFindByAddressChoreo() {
  // Create the Choreo object using your Temboo session
  FindByAddress findByAddressChoreo = new FindByAddress(session);

  // Set credential
  findByAddressChoreo.setCredential("yahooParsons");

  // Set inputs
  findByAddressChoreo.setResponseFormat("json");
  findByAddressChoreo.setAddress("Brazil");

  // Run the Choreo and store the results
  FindByAddressResultSet findByAddressResults = findByAddressChoreo.run();
  
  // Print results
  println(findByAddressResults.getResponse());

}

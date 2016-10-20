/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Kitura
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv
import Foundation

public class Controller {

  let router: Router
  let appEnv: AppEnv

  var port: Int {
    get { return appEnv.port }
  }

  var url: String {
    get { return appEnv.url }
  }

  init() throws {
    appEnv = try CloudFoundryEnv.getAppEnv()

    // All web apps need a Router instance to define routes
    router = Router()

    // Serve static content from "public"
    router.all("/", middleware: StaticFileServer())

    // Basic GET request
    router.get("/hello", handler: getHello)

    // Basic POST request
    router.post("/hello", handler: postHello)

    // JSON Get request
    router.get("/json", handler: getJSON)
    
    // usaepay request
    router.post("/runSale", handler: runSale)
  }

  public func runSale(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("POST - /runSale route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"

    if let data = try request.readString()?.data(using: String.Encoding.utf8){
    	
    	let item = JSON(data:data)
    	let cardNumber = item["cardNumber"].stringValue
    	let cardExp = item["cardExp"].stringValue
   		let cardCode = item["cardCode"].stringValue
   		let transAmount = item["transAmount"].stringValue
   		let transDescription = item["transDescription"].stringValue
    	let transInvoiceNumber = item["transInvoiceNumber"].stringValue
    	
    	
    	let scriptUrl = "https://api.us.apiconnect.ibmcloud.com/balduinousibmcom-development/runSale"
        let urlWithParams = scriptUrl + "?cardNumber=\(cardNumber)&cardExp=\(cardExp)&cardCode=\(cardCode)&transAmount=\(transAmount)&transDescription=\(transDescription)&transInvoiceNumber=\(transInvoiceNumber)"
        let myUrl = URL(string: urlWithParams)        
        var request = URLRequest(url: myUrl!)
       	request.httpMethod = "POST"
    	request.addValue("d95b7289-f8b2-43e9-a7c4-da48294b64f1", forHTTPHeaderField: "X-IBM-Client-Id")
    	
        // Excute HTTP Request
        let task = try URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                try response.status(.OK).send("error=\(error)").end()
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
/*            
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    print(convertedJsonIntoDict)
                    
                    // Get value by key
                    let firstNameValue = convertedJsonIntoDict["userName"] as? String
                    print(firstNameValue!)
                    
                }

            } catch let error as NSError {
                print(error.localizedDescription)
            }
*/            
       		try response.status(.OK).send(responseString).end()
        }
        
       task.resume()
       	
       	//try response.status(.OK).send("{\"cardNumber\":\"\(cardNumber)\", \"cardExp\":\"\(cardExp)\", \"cardCode\":\"\(cardCode)\", \"transAmount\":\"\(transAmount)\", \"transDescription\": \"\(transDescription)\", \"transInvoiceNumber\":\"\(transInvoiceNumber)\"}").end()//      				try response.status(.OK).send("{\"cardNumber\":\"\(cardNumber)\", \"cardExp\":\"\(cardExp)\", \"cardCode\":\"\(cardCode)\", \"transAmount\":\"\(transAmount)\", \"transDescription\": \"\(transDescription)\", \"transInvoiceNumber\":\"\(transInvoiceNumber)\"}").end()       				
 


    } else {
      try response.status(.OK).send("Kitura-Starter received a POST request!").end()
    }
  }

  
  public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send("Hello from Kitura-Starter!").end()
  }

  public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("POST - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"

    if let data = try request.readString()?.data(using: String.Encoding.utf8){
    	
    	let item = JSON(data:data)
    	let firstName = item["firstName"].stringValue
    	let lastName = item["lastName"].stringValue
     
      try response.status(.OK).send("Hello \(firstName) \(lastName), from Kitura-Starter!").end()
    } else {
      try response.status(.OK).send("Kitura-Starter received a POST request!").end()
    }
  }

  public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /json route handler...")
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    var jsonResponse = JSON([:])
    jsonResponse["framework"].stringValue = "Kitura"
    jsonResponse["applicationName"].stringValue = "Kitura-Starter"
    jsonResponse["company"].stringValue = "IBM"
    jsonResponse["organization"].stringValue = "Swift @ IBM"
    jsonResponse["location"].stringValue = "Austin, Texas"
    try response.status(.OK).send(json: jsonResponse).end()
  }

}

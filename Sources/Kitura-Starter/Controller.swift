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
import KituraRequest


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

    response.headers["Content-Type"] = "text/plain; charset=utf-8"

    if let data = try request.readString()?.data(using: String.Encoding.utf8){
    	
    	let item = JSON(data:data)
    	let cardNumber = item["cardNumber"].stringValue
    	let cardExp = item["cardExp"].stringValue
   		let cardCode = item["cardCode"].stringValue
   		let transAmount = item["transAmount"].stringValue
   		let transDescription = item["transDescription"].stringValue
    	let transInvoiceNumber = item["transInvoiceNumber"].stringValue
    	       
       let parameters = ["cardCode":cardCode, "cardExpiration":cardExp, "cardNumber":cardNumber, "transAmount":transAmount, "transDescription":transDescription, "transInvoice":transInvoiceNumber]
       
       KituraRequest.request(.POST,
                      		 "https://api.us.apiconnect.ibmcloud.com/balduinousibmcom-development/runSale",
                   		   	 parameters: parameters,
                      		 encoding: URLEncoding.default,
                      		 headers: ["X-IBM-Client-Id":"d95b7289-f8b2-43e9-a7c4-da48294b64f1"])
                      
                    .response {
  						request1, response1, data1, error1 in
  						
  						do {
  						
	  						let json = JSON(data: data1!)							
							if let resp = json.rawString() {
								
	        					try response.status(.OK).send(resp).end()       				
	 						}
	 						
 						} catch let error as NSError {
   	  						Log.info("Error: \(error.localizedDescription)")
   	  						print(error.localizedDescription)
   	      				}

					}
 

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

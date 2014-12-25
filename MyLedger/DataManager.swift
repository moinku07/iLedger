//
//  DataManager.swift
//  TopApps
//
//  Created by Dani Arnaout on 9/2/14.
//  Edited by Eric Cerney on 9/27/14.
//  Copyright (c) 2014 Ray Wenderlich All rights reserved.
//

import Foundation


class DataManager {
    
    struct domain {
        //let url: String = "http://10.0.0.10/ledger/admin/"
        let url: String = "http://ledger.durlov.com/admin/"
    }
    
    class func postDataAsyncWithCallback(url: NSString, jsonData: NSDictionary, completion: (data: NSData?, error: NSError?) -> Void){
        //let nsurl:NSURL = NSURL(string: url)!
        let nsurl:NSURL = NSURL(string: (self.domain().url + url))!
        var err: NSError?
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonData, options: nil, error: &err)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, urlData: NSData!, reponseError: NSError!) -> Void in
            if(urlData != nil ) {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                        /*
                        var jsonParseError: NSError? = nil
                        let object: AnyObject = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                        println(object)
                        */
                        completion(data: urlData, error: nil)
                    }else{
                        var statusError = NSError(domain:url, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(data: nil, error: statusError)
                    }
                }
            }else {
                if let error = reponseError {
                    completion(data: nil, error: error)
                }
            }
        }

    }
    
    class func postDataSyncWithCallback(url: NSString, jsonData: NSDictionary, completion: (data: NSData?, error: NSError?) -> Void){
        //let nsurl:NSURL = NSURL(string: url)!
        let nsurl:NSURL = NSURL(string: (self.domain().url + url))!
        var err: NSError?
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = "POST"
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonData, options: nil, error: &err)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if(urlData != nil ) {
            if let httpResponse = response as? NSHTTPURLResponse {
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                    /*
                    var jsonParseError: NSError? = nil
                    let object: AnyObject = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                    println(object)
                    */
                    completion(data: urlData, error: nil)
                }else{
                    var statusError = NSError(domain:url, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                }
            }
        }else {
            if let error = reponseError {
                completion(data: nil, error: error)
            }
        }
        
    }
    
    class func loadDataSyncWithCallback(url: NSString, completion: (data: NSData?, error: NSError?) -> Void){
        let nsurl:NSURL = NSURL(string: (self.domain().url + url))!
        
        var err: NSError?
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = "GET"
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonData, options: nil, error: &err)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var reponseError: NSError?
        var response: NSURLResponse?
        
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
        
        if(urlData != nil ) {
            if let httpResponse = response as? NSHTTPURLResponse {
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                    /*
                    var jsonParseError: NSError? = nil
                    let object: AnyObject = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                    println(object)
                    */
                    completion(data: urlData, error: nil)
                }else{
                    var statusError = NSError(domain:url, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                }
            }
        }else {
            if let error = reponseError {
                completion(data: nil, error: error)
            }
        }
        
    }
    
    class func loadDataAsyncWithCallback(url: NSString, completion: (data: NSData?, error: NSError?) -> Void){
        let nsurl:NSURL = NSURL(string: (self.domain().url + url))!
        
        var err: NSError?
        
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)
        request.HTTPMethod = "GET"
        //request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonData, options: nil, error: &err)
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response: NSURLResponse!, urlData: NSData!, reponseError: NSError!) -> Void in
            if(urlData != nil ) {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300){
                        /*
                        var jsonParseError: NSError? = nil
                        let object: AnyObject = NSString(data: urlData!, encoding: NSUTF8StringEncoding)!
                        println(object)
                        */
                        completion(data: urlData, error: nil)
                    }else{
                        var statusError = NSError(domain:url, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                        completion(data: nil, error: statusError)
                    }
                }
            }else {
                if let error = reponseError {
                    completion(data: nil, error: error)
                }
            }
        }
        
    }
  
    class func getDataFromFileWithSuccess(fileName: String, fileType: String, success: ((data: NSData) -> Void)) {
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        println("fileName: \(fileName), fileType: \(fileType)")
      //2
      /*let filePath = NSBundle.mainBundle().pathForResource(fileName,ofType:fileType)
   
      var readError:NSError?
      if let data = NSData(contentsOfFile:filePath!,
        options: NSDataReadingOptions.DataReadingUncached,
        error:&readError) {
        success(data: data)
      }*/
    })
  }
  /*
  class func loadDataFromURL(url: NSURL, completion:(data: NSData?, error: NSError?) -> Void) {
    var session = NSURLSession.sharedSession()
    
    // Use NSURLSession to get data from an NSURL
    let loadDataTask = session.dataTaskWithURL(url, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
      if let responseError = error {
        completion(data: nil, error: responseError)
      } else if let httpResponse = response as? NSHTTPURLResponse {
        if httpResponse.statusCode != 200 {
          var statusError = NSError(domain:"com.raywenderlich", code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
          completion(data: nil, error: statusError)
        } else {
          completion(data: data, error: nil)
        }
      }
    })
    
    loadDataTask.resume()
  }*/
    /*
    class func loadDataFromURL(url: String, completion:(data: NSData?, error: NSError?) -> Void) {
        let callURLString = "\(self.domain().url)\(url)"
        println(callURLString)
        let nURL = self.domain().url + url
        println(nURL)
        
        let callURL: NSURL = NSURL(string: url)!
        
        var session = NSURLSession.sharedSession()
        
        
        
        let task = session.dataTaskWithURL(callURL, completionHandler: { (data:NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if let responseError = error{
                completion(data: nil, error: responseError)
            }else if let httpResponse = response as? NSHTTPURLResponse{
                if httpResponse.statusCode != 200{
                    var statusError = NSError(domain:self.domain().url, code:httpResponse.statusCode, userInfo:[NSLocalizedDescriptionKey : "HTTP status code has unexpected value."])
                    completion(data: nil, error: statusError)
                }else{
                    completion(data: data, error: nil)
                }
            }
        })
        
        task.resume()
        
    }
    */
    class func loadDataFromURL1(url: String, completion:(data: NSData?, error: NSError?) -> Void) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var params = ["username":"jameson", "password":"password"] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["success"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
    
}
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
    
    class func postDataWithCallback(url: NSString, jsonData: NSDictionary, completion: (data: NSData?, error: NSError?) -> Void){
        let nsurl:NSURL = NSURL(string: url)!
        
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
  }
    
    
}
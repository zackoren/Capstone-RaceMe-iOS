//
//  ServerAPI.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/17/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import Foundation

class ServerAPI {
    
    let storageAPI = StorageAPI()
    var baseURL: String!
    
    init(url: String)  {
        baseURL = url
    }
    
    func postRequestTo(pathURL: String, withRequest data: [String: AnyObject], completionHandler completionFunction: ((Bool, [String:AnyObject]?, String) -> Void)!){
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
            
            // create post request
            if let post_url = NSURL(string: "\(baseURL)\(pathURL)") {
                let post_request = NSMutableURLRequest(URL: post_url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 300)
                post_request.HTTPMethod = "POST"
                
                // insert json data to the request
                post_request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                if let token = storageAPI.getToken() {
                    post_request.setValue(token, forHTTPHeaderField: "Authorization")
                }
                post_request.HTTPBody = jsonData
                
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                
                var succeeded = false
                var err = ""
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var result: [String:AnyObject]?
                    let task = session.dataTaskWithRequest(post_request){ data, response, error in
                        if error != nil {
                            print("1st Error -> \(error)")
                            err = error!.localizedDescription
                            succeeded = false
                        } else {
                            do {
                                result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                                
                                print("Result -> \(result!)")
                                if let errr = result!["error"] as? String {
                                    err = errr
                                }
                                succeeded = false
                                // self.decodeJWT(result)
                                
                            } catch let error as NSError {
                                print("2nd Error -> \(error)")
                                err = error.localizedDescription
                                succeeded = false
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            if let httpResponse = response as? NSHTTPURLResponse {
                                print("Status code: (\(httpResponse.statusCode))")
                                if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 { succeeded = true }
                                completionFunction?(succeeded, result, err)
                            } else {
                                completionFunction?(succeeded, result, err)
                            }
                        })
                    }
                    
                    task.resume()
                })
               
            }
            
        } catch let error as NSError {
            print("json error: \(error)")
        }
    }
    
    func getRequestTo(pathURL: String, completionHandler completionFunction: ((Bool, [String:AnyObject]?, String) -> Void)!){
        if let getURL = NSURL(string: "\(baseURL)\(pathURL)") {
            let getRequest = NSMutableURLRequest(URL: getURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 300)
            getRequest.HTTPMethod = "GET"
            if let token = storageAPI.getToken() {
                print("token in get -> \(token)")
                getRequest.setValue("FUCK: \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            var succeeded = false
            var err = ""
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var result: [String:AnyObject]?
                let task = session.dataTaskWithRequest(getRequest){ data, response, error in
                    if error != nil {
                        print("1st Error -> \(error)")
                        err = error!.localizedDescription
                        succeeded = false
                    } else {
                        do {
                            result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                            
                            print("Result -> \(result!)")
                            if let errr = result!["error"] as? String {
                                err = errr
                            }
                            succeeded = false
                            // self.decodeJWT(result)
                            
                        } catch let error as NSError {
                            print("2nd Error -> \(error)")
                            err = error.localizedDescription
                            succeeded = false
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        if let httpResponse = response as? NSHTTPURLResponse {
                            print("Status code: (\(httpResponse.statusCode))")
                            if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 { succeeded = true }
                            completionFunction?(succeeded, result, err)
                        } else {
                            completionFunction?(succeeded, result, err)
                        }
                    })
                }
                
                task.resume()
            })

        }
    }
}


struct Routes {
    
    static let baseURL = "https://capstone-beatme.herokuapp.com"
    // static let baseURL = "http://192.168.1.4:3000"
    // static let baseURL = "http://146.95.77.250:3000"
    static let registerPath = "/register"
    static let loginPath = "/login"
    static let healthPath = "/upload"
    static let matchPath = "/match"
    static let racePath = "/race"
    
}

struct JWT {

    static func decodeJWT(jwt: String?) -> String? {
        if jwt != nil {
            let headerPayloadSignature = jwt!.componentsSeparatedByString(".")
            var payloadBase64String = headerPayloadSignature[1]
            if payloadBase64String.characters.count % 4 != 0 {
                let padlen = 4 - payloadBase64String.characters.count % 4
                payloadBase64String += String(count: padlen, repeatedValue: Character("="))
            }
            // print("payloadBase64String -> \(payloadBase64String)")
            if let encodedString = NSData(base64EncodedString: payloadBase64String, options: []) {
                if let base64Decoded = String(data: encodedString, encoding: NSUTF8StringEncoding) {
                    // print("Base64Decoded -> \(base64Decoded)")
                    return base64Decoded
                }
            }
        }
        return nil
    }
    
    static func getJWT(jwt: [String: AnyObject]?) -> String? {
        if let token = jwt?["token"] as? String {
            return token
        }
        return nil
    }
    
    static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
}
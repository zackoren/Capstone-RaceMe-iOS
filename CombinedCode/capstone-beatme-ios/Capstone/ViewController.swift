//
//  ViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/14/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    /* CONSTANTS */
    let REGISTER_URL = "https://capstone-beatme.herokuapp.com/register"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendButton() {
        postToServer();
    }
    
    private func postToServer() {
        // print("posting");
        if let user_name = usernameTextField.text {
            if let password = passwordTextField.text {
                let request = ["username": user_name, "password": password]
                
                do {
                    let jsonData = try NSJSONSerialization.dataWithJSONObject(request, options: .PrettyPrinted)
                    
                    // create post request
                    if let post_url = NSURL(string: REGISTER_URL) {
                        let post_request = NSMutableURLRequest(URL: post_url)
                        post_request.HTTPMethod = "POST"
                        
                        // insert json data to the request
                        post_request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                        post_request.HTTPBody = jsonData
                        
                        let task = NSURLSession.sharedSession().dataTaskWithRequest(post_request){ data, response, error in
                            if error != nil {
                                print("1")
                                print("Error -> \(error)")
                                return
                            }
                            
                            do {
                                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String:AnyObject]
                                
                                print("Result -> \(result)")
                                
                            } catch {
                                print("2")
                                print("Error -> \(error)")
                            }
                        }
                        
                        task.resume()
                    }
                } catch {
                    print("json error: \(error)")
                }
                
            }
        }
        
    }
    
    /* UITextfield Delegate Methods */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}


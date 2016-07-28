//
//  ChallengeViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/19/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit

class ChallengeViewController: UIViewController {

    let storageAPI = StorageAPI()
    let serverAPI = ServerAPI(url: Routes.baseURL)
    var opponentUsername: String!
    
    
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var opponentActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var routeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var startRaceButton: MaterialButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]   
    }
    
    @IBAction func getOpponentButtonTapped() {
        opponentActivityIndicator.startAnimating()
        serverAPI.getRequestTo(Routes.matchPath) { (success, result, err) in
            self.opponentActivityIndicator.stopAnimating()
            if success {
                // print("Result from tap -> \(result)")
                if result != nil {
                    if let opponentName = result!["name"] as? String {
                        opponentUsername = opponentName
                        if let opponentRank = result!["rank"] as? Int {
                            self.opponentLabel.text = "\(opponentName), Rank: \(opponentRank)"

                        }
                    }
                }
            } else {
                print("Error -> \(err)")
            }
        }
    }
    
    @IBAction func getRouteButtonTapped() {
        
    }

    @IBAction func startRaceButtonTapped() {
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "UserRun" {
                if let urvc = segue.destinationViewController as? UserRunViewController {
                    urvc.challengerUsername = 
                    urvc.opponentUsername = self.opponentUsername
                }
            }
        }
    }
 

}

//
//  LoginViewController.swift
//  Twitter
//
//  Created by Ashwin Rohit on 2/18/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func onLoginButton(_ sender: UIButton) {
        let request_url = "https://api.twitter.com/oauth/request_token"
        TwitterAPICaller.client?.login(url: request_url, success: {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }, failure: { Error in
            print("Login Credentials incorrect")
        })
        self.performSegue(withIdentifier: "loginToHome", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

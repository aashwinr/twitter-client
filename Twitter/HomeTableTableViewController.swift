//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Ashwin Rohit on 2/18/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {
    
    var tweetList = [NSDictionary]()
    var numTweets = 10
    
    @IBAction func onLogoutButton(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true) {
            print("Logout Process completed")
        }
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
    
    func loadTweetContents() {
        let reqUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count":numTweets]

        TwitterAPICaller.client?.getDictionariesRequest(url: reqUrl, parameters: params, success: { (tweets: [NSDictionary]) in
            self.tweetList.removeAll()
            for tweet in tweets {
                self.tweetList.append(tweet)
            }
            self.tableView.reloadData()
        }, failure: { Error in
            print("Could not get tweets")
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweetContents();
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        let tweetDict = tweetList[indexPath.row]
        let userInfo = tweetDict["user"] as! [String:Any]
        let userName = userInfo["name"] as! String
        let tweetContents = tweetDict["text"] as! String
        cell.profileName.text = userName
        cell.tweetContents.text = tweetContents
        
        let imageUrl = URL(string: userInfo["profile_image_url_https"] as! String)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profilePicture.image = UIImage(data: imageData)
        }
        
        let radius = cell.profilePicture.bounds.width/2
        cell.profilePicture.layer.cornerRadius = radius
        cell.profilePicture.layer.masksToBounds = true
        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetList.count
    }

}

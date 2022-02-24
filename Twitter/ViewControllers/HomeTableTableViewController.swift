import UIKit

@available(iOS 13.0, *)
class HomeTableTableViewController: UITableViewController {
    
    var tweetList = [NSDictionary]()
    var userInfo = [String:Any]()
    var numTweets = 20
    
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
    
    func initRefreshControl() {
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    @objc func refresh(_ sender:AnyObject) {
        self.loadTweetContents()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRefreshControl()
        loadTweetContents()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        var infoDict = tweetList[indexPath.row]
        let userInfoDict = retrieveInfo(infoDict)
        
        if let imageData = getProfilePictureData(userInfoDict) {
            cell.profilePicture.image = UIImage(data: imageData)
            cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.height/2
            cell.profilePicture.clipsToBounds = true
        }
        
        cell.profileName.text = getProfileName(userInfoDict)
        cell.dateLabel.text = getFormattedDate(infoDict)
        cell.userNameLabel.text = getUserName(userInfoDict)
        cell.retweetSourceLabel.text = ""
        
        if let rtDict = getRetweetDict(infoDict) {
            infoDict = rtDict
            cell.retweetSourceLabel.text = "rt from @\(getUserName(retrieveInfo(infoDict))!)"
        }
        
        cell.retweetButtonOutlet.setTitle("", for: .normal)
        cell.likeButtonOutlet.setTitle("", for: .normal)
        cell.tweetContent.text = getTweetContents(infoDict)
        cell.retweetCount = Int(getRetweetCount(infoDict) ?? "0")!
        cell.likeCount = Int(getFavCount(infoDict) ?? "0")!
        
        if didUserRt(infoDict) {
            cell.retweetTriggered = true
            cell.setRtButton()
        } else {
            cell.retweetTriggered = false
            cell.unsetRtButton()
        }
        
        if didUserLike(infoDict) {
            cell.likeTriggered = true
            cell.setLikeButton()
        } else {
            cell.likeTriggered = false
            cell.unsetLikeButton()
        }
        
        cell.tweetId = getTweetId(infoDict)
        cell.superViewControllerRef = self
        
        return cell
    }
        
    func retrieveInfo(_ infoDict: NSDictionary) -> [String:Any] {
        return infoDict["user"] as! [String:Any]
    }
    
    func getProfileName(_ userInfoDict: [String:Any]) -> String {
        return userInfoDict["name"] as! String
    }
    
    func getUserName(_ userInfoDict: [String:Any]) -> String? {
        return userInfoDict["screen_name"] as? String
    }
    
    func getTweetContents(_ infoDict: NSDictionary) -> String? {
        return infoDict["text"] as? String
    }
    
    func getProfilePictureData(_ userInfoDict: [String:Any]) -> Data? {
        let imageUrlString = userInfoDict["profile_image_url_https"] as! String
        if let imageUrl = URL(string: imageUrlString) {
            let data = try? Data(contentsOf: imageUrl)
            return data
        }
        return nil
    }
    
    func getFormattedDate(_ infoDict: NSDictionary) -> String? {
        
        var returnStr = ""
        var elapsedSeconds = Int()
        var elapsedHours = Int()
        var elapsedMins = Int()
        var elapsedDays = Int()
        
        let dateStr = infoDict["created_at"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        if let date = dateFormatter.date(from: dateStr) {
            
            let elapsedTime = abs(date.timeIntervalSinceNow)
            elapsedSeconds = Int(elapsedTime)
            elapsedMins = elapsedSeconds/60
            elapsedHours = elapsedMins/60
            elapsedDays = elapsedHours/24
            
            if elapsedDays > 0 {
                dateFormatter.dateFormat = "dd MMM"
                returnStr += dateFormatter.string(from: date)
            } else if elapsedHours > 0 {
                returnStr += "\(elapsedHours) " + (elapsedHours == 1 ? "hr" : "hrs")
            } else {
                returnStr += "\(elapsedMins) " + (elapsedMins == 1 ? "min" : "mins")
            }
            
        } else {
            print("Cannot Parse Date")
            return nil
        }
        
        return returnStr
        
    }
    
    func getFormattedNum(_ num: Int?) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 1
        if let fnum = num {
            if fnum > 10000 {
                let dividedVal = Double(fnum)/1000.0 as NSNumber
                if let formattedStr = numberFormatter.string(from: dividedVal) {
                    return formattedStr + "k"
                }
                return nil
            } else {
                return String(fnum)
            }
        }
        return nil
    }
    
    func getRetweetCount(_ infoDict: NSDictionary) -> String? {
        let numRt = infoDict["retweet_count"] as? NSNumber
        return getFormattedNum(numRt?.intValue)
    }
    
    func getFavCount(_ infoDict: NSDictionary) -> String? {
        let numLikes = infoDict["favorite_count"] as? NSNumber
        return getFormattedNum(numLikes?.intValue)
    }
    
    func getRetweetDict(_ infoDict: NSDictionary) -> NSDictionary? {
        return infoDict["retweeted_status"] as? NSDictionary
    }
    
    func didUserRt(_ infoDict: NSDictionary) -> Bool {
        infoDict["retweeted"] as! Bool
    }
    
    func didUserLike(_ infoDict: NSDictionary) -> Bool {
        return infoDict["favorited"] as! Bool
    }
    
    func getTweetId(_ infoDict: NSDictionary) -> Int {
        return infoDict["id"] as! Int
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetList.count
    }

}

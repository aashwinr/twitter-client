//
//  TweetCell.swift
//  Twitter
//
//  Created by Ashwin Rohit on 2/18/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class TweetCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var tweetContent: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var retweetSourceLabel: UILabel!
    @IBOutlet weak var rtCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var retweetTriggered = Bool()
    var likeTriggered = Bool()
    var retweetCount = Int()
    var likeCount = Int()
    var tweetId = Int()
    var superViewControllerRef = UIViewController()
    
    @IBOutlet weak var retweetButtonOutlet: UIButton!
    @IBAction func retweetButton(_ sender: Any) {
        if(!retweetTriggered) {
            self.retweetCount += 1
            self.setRtButton()
            self.retweetTriggered = true
            TwitterAPICaller.client?.retweet(tweetID: tweetId, success: {
                print("Rt'd | Incremented")
            }, failure: { Error in
                self.retweetCount -= 1
                self.unsetRtButton()
                self.retweetTriggered = false
                self.sendAlert(title: "Error", msg: "Description: \(Error.localizedDescription)")
            })
        } else {
            self.retweetCount -= 1
            self.unsetRtButton()
            self.retweetTriggered = false
            TwitterAPICaller.client?.unretweet(tweetID: tweetId, success: {
                print("unRt'd | decremented")
            }, failure: { Error in
                self.retweetCount += 1
                self.setRtButton()
                self.retweetTriggered = true
                self.sendAlert(title: "Error", msg: "Description: \(Error.localizedDescription)")
            })
        }
    }
    
    func setRtButton() {
        retweetButtonOutlet.setImage(UIImage(systemName: "arrowshape.turn.up.left.2.fill"), for: .normal)
        rtCountLabel.text = String(retweetCount)
    }
    
    func unsetRtButton() {
        retweetButtonOutlet.setImage(UIImage(systemName: "arrowshape.turn.up.left.2"), for: .normal)
        rtCountLabel.text = String(retweetCount)
    }

    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBAction func likeButton(_ sender: Any) {
        if(!likeTriggered) {
            self.likeCount += 1
            self.setLikeButton()
            self.likeTriggered = true
            TwitterAPICaller.client?.likeTweet(tweetID: tweetId, success: {
                print("Liked : Incremented")
            }, failure: { Error in
                self.likeCount -= 1
                self.unsetLikeButton()
                self.likeTriggered = false
                self.sendAlert(title: "Error", msg: "Description: \(Error.localizedDescription)")
            })
        } else {
            self.likeCount -= 1
            self.unsetLikeButton()
            self.likeTriggered = false
            TwitterAPICaller.client?.unlikeTweet(tweetID: tweetId, success: {
                print("Unliked : Decremented")
            }, failure: { Error in
                self.likeCount += 1
                self.setLikeButton()
                self.likeTriggered = true
                self.sendAlert(title: "Error", msg: "Description: \(Error.localizedDescription)")
            })
        }
    }
    
    func setLikeButton() {
        likeButtonOutlet.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeCountLabel.text = String(likeCount)
    }
    
    func unsetLikeButton() {
        likeButtonOutlet.setImage(UIImage(systemName: "heart"), for: .normal)
        likeCountLabel.text = String(likeCount)
    }
    
    func sendAlert(title: String?, msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "dismiss", style: .default))
        (superViewControllerRef).present(alertController, animated: true, completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        // super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

//
//  ComposeViewController.swift
//  Twitter
//
//  Created by Ashwin Rohit on 2/23/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var tweetEntryField: UITextView!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var tweetButtonController: UIButton!
    
    @IBAction func tweetButton(_ sender: Any) {
        composeTweet()
    }
    
    let twitterCharLimit = 280
    var currCharCount = Int()
    var editState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTweetEntryField()
    }
    
    func initTweetEntryField() {
        tweetEntryField.delegate = self
        characterCount.text = String(twitterCharLimit)
        tweetEntryField.text = ""
        tweetEntryField.layer.borderWidth = 0.5
        tweetEntryField.layer.borderColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1).cgColor
        tweetEntryField.layer.cornerRadius = 10
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charCount = tweetEntryField.text?.count ?? 0
        let addCount = text.count
        currCharCount = charCount + addCount
        let remainingChars = twitterCharLimit - (currCharCount)
        if(remainingChars < 0) {
            self.characterCount.textColor = .red
            self.tweetButtonController.tintColor = .red
        } else {
            self.characterCount.textColor = nil
            self.tweetButtonController.tintColor = nil
        }
        self.characterCount.text = String(remainingChars)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if(!editState) {
            if(textView == tweetEntryField) {
                tweetEntryField.text = ""
            }
            editState = true
        }
    }
    
    func composeTweet() {
        if(currCharCount > twitterCharLimit) {
            self.sendAlert(title: "Character Limit Exceeded", msg: "You've exceeded the maximum character limit of 280")
        }
        TwitterAPICaller.client?.postTweet(string: self.tweetEntryField.text, success: {
            self.sendAlert(title: "Tweet Sent!", msg: nil)
            self.initTweetEntryField()
        }, failure: { Error in
            self.sendAlert(title: "Error: Tweet not composed", msg: "Description: \(Error.localizedDescription)")
        })
        initTweetEntryField()
    }
    
    func sendAlert(title: String?, msg: String?) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "dismiss", style: .default))
        (self).present(alertController, animated: true, completion: nil)
    }
    
}

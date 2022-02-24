//
//  SearchViewController.swift
//  Twitter
//
//  Created by Ashwin Rohit on 2/19/22.
//  Copyright © 2022 Dan. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let resultsCount = 10
    var searchResults = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getSearchReq(query: String) {
        let reqUrlStr = "https://api.twitter.com/1.1/users/search.json"
        let encodedStr = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        TwitterAPICaller.client?.getDictionariesRequest(url: reqUrlStr, parameters: ["q":encodedStr, "count":resultsCount], success: { (userObjects: [NSDictionary]) in
            self.searchResults.removeAll()
            for userObject in userObjects {
                self.searchResults.append(userObject)
            }
            print(self.searchResults)
        }, failure: { Error in
            print("Request not received")
        })
    }
    
    func getUrlWithComponents(query: String) -> String? {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "", value: query)
        ]
        return components.url?.absoluteString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let searchCell = self.tableView.dequeueReusableCell(withIdentifier: "resultCell") as! SearchResultCell
        let userObject = searchResults[indexPath.row] as? [String:Any]
        if let imageData = getProfilePictureData(userObject ?? [:]) {
            searchCell.profilePicture.image = UIImage(data: imageData)
            searchCell.profilePicture.layer.cornerRadius = searchCell.profilePicture.bounds.width/2
            searchCell.profilePicture.clipsToBounds = true
        }
        let name = userObject!["name"] as! String
        searchCell.profileNameLabel.text = name
        return searchCell
    }
    
    func getProfilePictureData(_ userDict: [String:Any]) -> Data? {
        let imageUrlString = userDict["profile_image_url_https"] as! String
        if let imageUrl = URL(string: imageUrlString) {
            let data = try? Data(contentsOf: imageUrl)
            return data
        }
        return nil
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getSearchReq(query: searchText)
        self.tableView.reloadData()
    }

}

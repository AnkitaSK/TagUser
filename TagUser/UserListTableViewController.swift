//
//  UserListTableViewController.swift
//  TagUser
//
//  Created by Ankita Kalangutkar on 10/28/16.
//  Copyright © 2016 Ankita Kalangutkar. All rights reserved.
//

import UIKit

class UserListTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadList", name: "reloadList", object: nil)
        
    }
    
    func reloadList() {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserSearchManager.userSearchSharedManager.filteredUserNames.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell")
        cell?.textLabel?.text = UserSearchManager.userSearchSharedManager.filteredUserNames[indexPath.row]
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedUserName:String
        selectedUserName = UserSearchManager.userSearchSharedManager.filteredUserNames[indexPath.row]
        
        let nameSelected = ["nameSelected":selectedUserName]
        NSNotificationCenter.defaultCenter().postNotificationName("updateSelectedUserName", object: nameSelected)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


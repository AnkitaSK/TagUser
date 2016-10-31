//
//  UserSearchManager.swift
//  TagUser
//
//  Created by Ankita Kalangutkar on 10/28/16.
//  Copyright © 2016 Ankita Kalangutkar. All rights reserved.
//

import UIKit

extension RangeReplaceableCollectionType where Generator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(object : Generator.Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

class UserSearchManager: NSObject {
    static let userSearchSharedManager:UserSearchManager = UserSearchManager()
    
    var userNames = [String]()
    var filteredUserNames = [String]()
    var removeUserNames = [String]()
    
    override init() {
        super.init()
        
        userNames = ["John", "Michel", "James", "Arya", "Jon", "Tyrion", "Shae"]
    }
    
    func filterContentForSearchText(searchText:String) {
        filteredUserNames = userNames.filter({ (name:String) -> Bool in
            if name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil {
                return name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil
            }
            else {
                return false
            }
            
        })
        
        if filteredUserNames.count == 0 {
            filteredUserNames.appendContentsOf(userNames)
        }
//        remove old searched names
        for name in removeUserNames {
            userNames.removeObject(name)
            filteredUserNames.removeObject(name)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("reloadList", object: nil)
    }
    
}

//
//  ViewController.swift
//  TagUser
//
//  Created by Ankita Kalangutkar on 10/28/16.
//  Copyright © 2016 Ankita Kalangutkar. All rights reserved.
//

import UIKit

extension UITextView {
    func boundingRectForCharacterRange(range: NSRange) -> CGRect? {
        
        guard let attributedText = attributedText else { return nil }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        
        // Convert the range for glyphs.
        layoutManager.characterRangeForGlyphRange(range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRectForGlyphRange(glyphRange, inTextContainer: textContainer)
        
    }
}

class ViewController: UIViewController {
    
    lazy var containerViewController: UINavigationController = {
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("UserListTableViewController")
        let navigationController = UINavigationController(rootViewController: popoverContent!)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.Popover
        popoverContent?.preferredContentSize = CGSizeMake(100, 100)
        return navigationController
    }()
    
    var searchedText:String?
    var textviewTextRange:NSRange?
    var textEntered:String = ""
    @IBOutlet var messageTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//     for textview to start editing from top
        self.automaticallyAdjustsScrollViewInsets = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSelectedUserName:", name: "updateSelectedUserName", object: nil)
    
        messageTextView.text = "Enter text here..."
        messageTextView.textColor = UIColor.grayColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSelectedUserName(notification:NSNotification) {
//        dismiss listview
        if (containerViewController.presentingViewController != nil) {
            dismissViewControllerAnimated(false, completion: nil)
        }
        
        let selectedName:String = notification.object!["nameSelected"] as! String

//        replace text by selectedname text
        replaceBySelectedText(selectedName)
        
//        save name to be removed
        UserSearchManager.userSearchSharedManager.removeUserNames.append(selectedName)
        
//        set background color to text
        setTextBackgroundColor(selectedName)
    }
    
    func replaceBySelectedText(selectedName:String) {
        let textEndPosition:UITextPosition = messageTextView.positionFromPosition(messageTextView.endOfDocument, offset: 0)!
        let textStartPosition:UITextPosition = messageTextView.positionFromPosition(messageTextView.endOfDocument, offset: -(searchedText?.characters.count)! - 1)!
        let textRange:UITextRange = messageTextView.textRangeFromPosition(textStartPosition, toPosition:textEndPosition)!
        messageTextView.replaceRange(textRange, withText: selectedName)
    }
    
    func setTextBackgroundColor(selectedName:String) {
        //        setting a background color
        let endPosition:UITextPosition = messageTextView.positionFromPosition(messageTextView.endOfDocument, offset: 0)!
        let startPosition: UITextPosition = messageTextView.positionFromPosition(messageTextView.endOfDocument, offset: -(selectedName.characters.count))!
        let actualRange:UITextRange = messageTextView.textRangeFromPosition(startPosition, toPosition: endPosition)!
        let rect = messageTextView.firstRectForRange(actualRange)
        
        let view:UIView = UIView()
        view.frame = rect
        view.layer.cornerRadius = 5.0
        view.backgroundColor = UIColor(red: 220/255, green: 230/255, blue: 246/255, alpha: 1)
        //        view.backgroundColor = UIColor.blueColor()
        messageTextView.addSubview(view)
        messageTextView.sendSubviewToBack(view)
    }

}

extension ViewController:UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        //        return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.None
    }
}

extension ViewController:UITextViewDelegate {
    
    func showUserListViewAtLocation(location:Int) {
    
        if (containerViewController.presentingViewController == nil) {
            let popover:UIPopoverPresentationController = containerViewController.popoverPresentationController!
            popover.sourceView = messageTextView
            popover.delegate = self
            popover.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popover.canOverlapSourceViewRect = true
            
            let rect:CGRect = messageTextView.boundingRectForCharacterRange(textviewTextRange!)!
            popover.sourceRect = CGRectMake(rect.origin.x, messageTextView.frame.origin.y + messageTextView.frame.size.height - 40.0, 0, 0)
            containerViewController.navigationBarHidden = true
            presentViewController(containerViewController, animated: true, completion: nil)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Enter text here..." {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if let indexPath = textView.text.rangeOfString("@",options: NSStringCompareOptions.BackwardsSearch) {
            let distance:Int = textView.text.startIndex.distanceTo(indexPath.startIndex)
            let index: String.Index = textView.text.startIndex.advancedBy(distance + 1)
            let searchText = textView.text.substringFromIndex(index)
            
            let whiteSpaceRange = searchText.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
            if let _ = whiteSpaceRange {
                if (containerViewController.presentingViewController != nil) {
                    dismissViewControllerAnimated(false, completion: nil)
                }
            }
            else {
                if textEntered != "@" {
                    //                change textview height
                    changeTextViewHeight(textView)
                    
                    //                filter username
                    UserSearchManager.userSearchSharedManager.filterContentForSearchText(searchText)
                    
                    //                search in a table
                    showUserListViewAtLocation(distance + 1)
                    
                    print(searchText)
                    
                    searchedText = searchText
                    
                }
            }

        }
        
    }
    
    func changeTextViewHeight(textView:UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        textviewTextRange = range
        textEntered = text
        return true
    }
}


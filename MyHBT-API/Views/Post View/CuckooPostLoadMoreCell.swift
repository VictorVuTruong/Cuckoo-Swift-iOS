//
//  HBTGramPostLoadMoreCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/14/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class CuckooPostLoadMoreCell: UITableViewCell {
    var delegate: PostDetailCellDelegator!
    
    // The loading indicator which let the user know that new posts are being loaded
    @IBOutlet weak var loadMoreActivityIndicatorView: UIActivityIndicatorView!
    
    // The view which will act as a load more button
    @IBOutlet weak var loadMoreView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Create tap gesture recognizer for the load more view
        let tapGestureLoadMoreView = UITapGestureRecognizer(target: self, action: #selector(CuckooPostLoadMoreCell.viewTappedLoadMorePost))
        
        // Add tap gesture to the load more view
        loadMoreView.addGestureRecognizer(tapGestureLoadMoreView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //**************************************** TAP GESTURES ****************************************
    // The function which take the user to the post detail when the user tap the view
    @objc func viewTappedLoadMorePost(gesture: UIGestureRecognizer) {
        // Check to make sure that view is not nil
        if (gesture.view) != nil {
            // Show the activity indicator
            loadMoreActivityIndicatorView.isHidden = false
            
            // Start animating the activity indicator
            loadMoreActivityIndicatorView.startAnimating()
            
            // Call the function to load more posts
            self.delegate.callFunctionToLoadMorePost(myData: "" as AnyObject)
        }
    }
    //**************************************** END TAP GESTURES ****************************************
}

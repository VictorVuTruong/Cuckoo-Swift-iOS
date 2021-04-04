//
//  UserStatsSeeMoreCell.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 12/22/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class UserStatsSeeMoreCell: UITableViewCell {
    var delegate: UserStatsCellDelegator?
    
    // The variable which will keep track of which user stats info to load at this row
    var userStatsInfoToLoad = ""
    
    @IBAction func seeMoreButton(_ sender: UIButton) {
        // Call the function and take user to the view controller where the user can see user stats detail
        gotoUserStatsDetail()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // The function which will take user to the view controller where the user can see user stats detail info
    func gotoUserStatsDetail() {
        // Call the function which will take user to the view controller where the user can see user stats detail
        delegate?.callSegueFromCellShowUserStatsDetail(userStatsCategory: userStatsInfoToLoad)
    }
}

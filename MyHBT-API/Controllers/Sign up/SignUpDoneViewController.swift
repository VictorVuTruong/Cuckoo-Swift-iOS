//
//  SignUpDoneViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 9/18/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit

class SignUpDoneViewController: UIViewController {
    // The button which will take user to the main view controller
    @IBAction func gotoMainButton(_ sender: UIButton) {
        // Perform segue and take user to the main view controller
        performSegue(withIdentifier: "signUpDoneToMain", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

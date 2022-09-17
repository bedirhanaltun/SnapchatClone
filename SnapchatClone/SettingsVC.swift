//
//  SettingsVC.swift
//  SnapchatClone
//
//  Created by Bedirhan Altun on 16.09.2022.
//

import UIKit
import Firebase

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func logOutButtonClicked(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toLoginScreen", sender: nil)
        }
        catch{
            
        }
    }
}

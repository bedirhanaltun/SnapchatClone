//
//  SnapVC.swift
//  SnapchatClone
//
//  Created by Bedirhan Altun on 16.09.2022.
//

import UIKit

class SnapVC: UIViewController {
    
    var selectedSnap: Snap?
    var selectedTime: Int?
    

    @IBOutlet weak var timeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let time = selectedTime{
            timeLabel.text = "Time left: \(time)"

        }
        
    }

}

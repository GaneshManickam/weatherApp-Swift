//
//  weatherCell.swift
//  weatherApp
//
//  Created by Ganesh Manickam on 5/13/17.
//  Copyright © 2017 mobileappexpert. All rights reserved.
//

import UIKit

class weatherCell: UITableViewCell {

    @IBOutlet var reportLbl: UILabel!
    @IBOutlet var theImgview: UIImageView!
    @IBOutlet var dayLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

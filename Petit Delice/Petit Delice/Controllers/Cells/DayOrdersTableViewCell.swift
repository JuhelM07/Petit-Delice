//
//  DayOrdersTableViewCell.swift
//  Petit Delice
//
//  Created by Jahan Miah on 27/12/2020.
//

import UIKit

class DayOrdersTableViewCell: UITableViewCell {
    @IBOutlet weak var customerInstagram: UILabel!
    @IBOutlet weak var deliveryDate: UILabel!
    @IBOutlet weak var customerOrder: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}

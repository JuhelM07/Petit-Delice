//
//  OrderDetailsViewController.swift
//  Petit Delice
//
//  Created by Juhel on 29/12/2020.
//

import UIKit

class OrderDetailsViewController: UITableViewController {
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerInstagramLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var cakeTypeLabel: UILabel!
    @IBOutlet weak var cakeSizeLabel: UILabel!
    @IBOutlet weak var cakeFlavourLabel: UILabel!
    @IBOutlet weak var giftBoxSweetTreatsLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    var getCustomerName = String()
    var getCustomerInstagram = String()
    var getDeliveryDate = String()
    var getCakeType = String()
    var getCakeSize = String()
    var getCakeFlavour = String()
    var getGiftBoxSweetTreats = Bool()
    var getAdditionalInformation = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIForDetails()
    }
    
    func setUpUIForDetails() {
        customerNameLabel.text = getCustomerName
        customerInstagramLabel.text = getCustomerInstagram
        deliveryDateLabel.text = getDeliveryDate
        
        cakeTypeLabel.text = getCakeType
        cakeSizeLabel.text = getCakeSize
        cakeFlavourLabel.text = getCakeFlavour
        
        if getGiftBoxSweetTreats {
            giftBoxSweetTreatsLabel.text = "Yes"
        } else {
            giftBoxSweetTreatsLabel.text = "No"
        }
        
        if getAdditionalInformation == "" {
            additionalInfoLabel.text = "No additional information"
        } else {
            additionalInfoLabel.text = getAdditionalInformation
        }

        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

}

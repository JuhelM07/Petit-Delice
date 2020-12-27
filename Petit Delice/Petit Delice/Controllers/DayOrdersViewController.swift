//
//  DayOrdersViewController.swift
//  Petit Delice
//
//  Created by Juhel on 27/12/2020.
//

import UIKit

class DayOrdersViewController: UIViewController {
    
    @IBOutlet weak var ordersView: UIView!
    @IBOutlet weak var ordersTableView: UITableView!
    
    var orderDetails = [OrderDetails]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ordersTableView.backgroundColor = UIColor(red: 255, green: 236, blue: 252, alpha: 0)
        setUpRoundView()

    }
    
    func setUpRoundView() {
        ordersView.layer.cornerRadius = 10
        ordersView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
// x button closes modal
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func closeAnywhereButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension DayOrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ordersTableView.dequeueReusableCell(withIdentifier: "DayOrdersCell", for: indexPath) as! DayOrdersTableViewCell
        let orders = orderDetails[indexPath.row]
        cell.customerName.text = orders.customerName
        cell.customerInstagram.text = orders.instagramUsername
        cell.customerOrder.text = "\(orders.cakeSizeQuantity)  \(orders.cakeType)"
        cell.deliveryDate.text = orders.deliveryDate
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 255, green: 236, blue: 252, alpha: 0)
    }
    
    
}



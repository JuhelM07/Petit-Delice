//
//  ArchiveViewController.swift
//  Petit Delice
//
//  Created by Jahan Miah on 31/12/2020.
//

import UIKit
import Firebase
import CodableFirebase


class ArchiveViewController: UIViewController {

    
    
    @IBOutlet weak var noArchivedOrdersLabel: UILabel!
    @IBOutlet weak var ordersTableView: UITableView!
    
    
    var orderDetails = [OrderDetails]()
    let database = Database.database().reference()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadArchivedOrders()

    }
    
    
    
    func loadArchivedOrders() {
        self.orderDetails.removeAll()
        database.child("archive").observeSingleEvent(of: .value) { [self] (snapshot) in
            let value = snapshot.value as? [String: Any]
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userDict = userSnap.value as! [String:AnyObject] //child data
                
                do {
                    let order = try FirebaseDecoder().decode(OrderDetails.self, from: userDict)
                    self.orderDetails.append(order)
                } catch let error {
                    print(error)
                }
            }
            ordersTableView.reloadData()
            
            if orderDetails.count == 0 {
                self.ordersTableView.isHidden = true
                self.noArchivedOrdersLabel.isHidden = false
            } else {
                self.ordersTableView.isHidden = false
                self.noArchivedOrdersLabel.isHidden = true
            }
            
            print("Order Array: \(self.orderDetails.count)")
        }
    }
    

}




extension ArchiveViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
        
        let cell = ordersTableView.dequeueReusableCell(withIdentifier: "archivedOrderCell", for: indexPath) as! DayOrdersTableViewCell
        let orders = orderDetails[indexPath.row]
        cell.customerName.text = orders.customerName
        cell.customerInstagram.text = orders.instagramUsername
        cell.customerOrder.text = "\(orders.cakeSizeQuantity) \(orders.cakeType)"
        cell.deliveryDate.text = "Delivery date: \(orders.deliveryDate)"
        
        //let date = dateFormatter.
        cell.createdAt.text = "Order placed on: \(orders.createdAt)"
            
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let archivedOrder = orderDetails[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let orderDetailsVC = storyBoard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController
        
        orderDetailsVC.getCustomerName = archivedOrder.customerName
        orderDetailsVC.getCustomerInstagram = archivedOrder.instagramUsername
        orderDetailsVC.getDeliveryDate = archivedOrder.deliveryDate
        orderDetailsVC.getCakeType = archivedOrder.cakeType
        orderDetailsVC.getCakeSize = archivedOrder.cakeSizeQuantity
        orderDetailsVC.getCakeFlavour = archivedOrder.cakeFlavour
        orderDetailsVC.getGiftBoxSweetTreats = archivedOrder.giftBoxSweetTreats
        orderDetailsVC.getAdditionalInformation = archivedOrder.additionalInformation
        orderDetailsVC.getCustomerReference = archivedOrder.customerReference
        orderDetailsVC.getCreatedAt = archivedOrder.createdAt
        
        orderDetailsVC.cameFromArchive = true
        
        self.navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
    
}

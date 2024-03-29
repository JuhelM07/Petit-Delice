//
//  ViewController.swift
//  Petit Delice
//
//  Created by Juhel on 24/12/2020.
//

import UIKit
import FSCalendar
import FirebaseDatabase
import Firebase
import CodableFirebase

protocol ViewControllerDelegate {
  func didloadOrders()
}

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var mainCalendar: FSCalendar!
    @IBOutlet weak var deadlinesCollectionView: UICollectionView!
    
    let database = Database.database().reference()
    var orderDetails = [OrderDetails]()
    var datesArray = [String]()
    var dateSelected = String()
    var deadlinesDates = [OrderDetails]()
    var delegate: ViewControllerDelegate?
    
    @IBOutlet weak var noOrderThisWeekView: UIView!
    
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.shadowImage = UIImage()
        setUpCollectionView()
        

        
        //loadAllOrders()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAllOrders()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCreateOrder" {
            if let vc = segue.destination as? CreateOrderViewController {
                vc.getDateFromMain = dateSelected
                
            }
        }
    }
    
    @objc func addTapped() {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CreateOrderViewController") as? CreateOrderViewController
        
        vc?.getDateFromMain = dateSelected
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func setUpDelegates() {
        
    }
    
    func setUpCollectionView() {
        let deadlineLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        deadlineLayout.itemSize = CGSize(width: 207, height: 207)
        deadlineLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        deadlineLayout.minimumInteritemSpacing = 5.0
        deadlineLayout.minimumLineSpacing = 10.0
        deadlineLayout.scrollDirection = .horizontal
        
        deadlinesCollectionView.collectionViewLayout = deadlineLayout
    }
    

    
    func loadAllOrders() {
        self.orderDetails.removeAll()
        database.child("orders").observeSingleEvent(of: .value) { [self] (snapshot) in
            let value = snapshot.value as? [String: Any]
            
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let userDict = userSnap.value as! [String:AnyObject] //child data
                
                do {
                    let order = try FirebaseDecoder().decode(OrderDetails.self, from: userDict)
                    self.orderDetails.append(order)
                    self.mainCalendar.reloadData()
                } catch let error {
                    print(error)
                }
            }
            self.calculateDeadlines()
            print("Orders: \(self.orderDetails)")
            
        }
    }
    
    func calculateDeadlines() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
        self.deadlinesDates.removeAll()
        
        for order in orderDetails {
            let date = dateFormatter.date(from: order.deliveryDate)
            
            if date != nil {
                let delta = date! - Date()
                let days = delta / 86400
                print("Days: \(days)")
                if days >= -1 && days <= 7 {
                    self.deadlinesDates.append(order)
                }
            }
        }
        deadlinesCollectionView.reloadData()
        print(deadlinesDates.count)
        if deadlinesDates.count == 0 {
            self.deadlinesCollectionView.isHidden = true
            self.noOrderThisWeekView.isHidden = false
        } else {
            self.deadlinesCollectionView.isHidden = false
            self.noOrderThisWeekView.isHidden = true
        }
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dateString = self.dateFormatter.string(from: date)
        print("date string: \(dateString)")
        dateSelected = dateString
        var ordersForDate = [OrderDetails]()
        
        for order in orderDetails {
            if order.deliveryDate == dateString {
                print("There are orders for \(order.deliveryDate)")
                ordersForDate.append(order)
            }
        }
   // doesnt open modal for no order dates
        for date in ordersForDate{
            if date.deliveryDate == dateString{
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let dayOrdersVC = storyBoard.instantiateViewController(withIdentifier: "DayOrdersViewController") as! DayOrdersViewController
                dayOrdersVC.delegate = self
                dayOrdersVC.orderDetails = ordersForDate
                self.present(dayOrdersVC, animated: true, completion: nil)
                break
            }
        }
        

        
        
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        datesArray.removeAll()
        
        let dateString = self.dateFormatter.string(from: date)
        
        for order in orderDetails {
            datesArray.append(order.deliveryDate)
        }
        
        if datesArray.contains(dateString) {
            return 1
        }
        
        return 0
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 207, height: 207)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deadlinesDates.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "deadlineCell", for: indexPath) as! DeadlinesCollectionViewCell
        
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.masksToBounds = false
        
        let deadlineInfo = deadlinesDates[indexPath.row]
        cell.customerName.text = deadlineInfo.customerName
        cell.customerInstagram.text = deadlineInfo.instagramUsername
        cell.deliveryDate.text = deadlineInfo.deliveryDate
        cell.customerOrder.text = "\(deadlineInfo.cakeSizeQuantity) \(deadlineInfo.cakeType)"
        // Configure the cell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let deadlineInfo = deadlinesDates[indexPath.row]
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let orderDetailsVC = storyBoard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController
        
        orderDetailsVC.getCustomerName = deadlineInfo.customerName
        orderDetailsVC.getCustomerInstagram = deadlineInfo.instagramUsername
        orderDetailsVC.getDeliveryDate = deadlineInfo.deliveryDate
        orderDetailsVC.getCakeType = deadlineInfo.cakeType
        orderDetailsVC.getCakeSize = deadlineInfo.cakeSizeQuantity
        orderDetailsVC.getCakeFlavour = deadlineInfo.cakeFlavour
        orderDetailsVC.getGiftBoxSweetTreats = deadlineInfo.giftBoxSweetTreats
        orderDetailsVC.getAdditionalInformation = deadlineInfo.additionalInformation
        orderDetailsVC.getCustomerReference = deadlineInfo.customerReference
        orderDetailsVC.getCreatedAt = deadlineInfo.createdAt
        
        self.navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
}

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension ViewController: DayOrdersViewControllerDelegate {
    func goToOrderDetailsWithImage(customerName: String, customerInstagram: String, deliveryDate: String, cakeType: String, cakeSize: String, cakeFlavour: String, giftBoxSweetTreats: Bool, additionalInfo: String, customerReference: String, createdAt: String, imageURLs: [String]) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let orderDetailsVC = storyBoard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController
        
        orderDetailsVC.getCustomerName = customerName
        orderDetailsVC.getCustomerInstagram = customerInstagram
        orderDetailsVC.getDeliveryDate = deliveryDate
        orderDetailsVC.getCakeType = cakeType
        orderDetailsVC.getCakeSize = cakeSize
        orderDetailsVC.getCakeFlavour = cakeFlavour
        orderDetailsVC.getGiftBoxSweetTreats = giftBoxSweetTreats
        orderDetailsVC.getAdditionalInformation = additionalInfo
        orderDetailsVC.getCustomerReference = customerReference
        orderDetailsVC.getCreatedAt = createdAt
        orderDetailsVC.getImages = imageURLs
        orderDetailsVC.displayImages = true
        
        self.navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
    
    func goToOrderDetails(customerName: String, customerInstagram: String, deliveryDate: String, cakeType: String, cakeSize: String, cakeFlavour: String, giftBoxSweetTreats: Bool, additionalInfo: String, customerReference: String, createdAt: String) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let orderDetailsVC = storyBoard.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController
        
        orderDetailsVC.getCustomerName = customerName
        orderDetailsVC.getCustomerInstagram = customerInstagram
        orderDetailsVC.getDeliveryDate = deliveryDate
        orderDetailsVC.getCakeType = cakeType
        orderDetailsVC.getCakeSize = cakeSize
        orderDetailsVC.getCakeFlavour = cakeFlavour
        orderDetailsVC.getGiftBoxSweetTreats = giftBoxSweetTreats
        orderDetailsVC.getAdditionalInformation = additionalInfo
        orderDetailsVC.getCustomerReference = customerReference
        orderDetailsVC.getCreatedAt = createdAt
        orderDetailsVC.displayImages = false
        //orderDetailsVC.getImages = imageURLs
        
        self.navigationController?.pushViewController(orderDetailsVC, animated: true)
    }
    
    
}

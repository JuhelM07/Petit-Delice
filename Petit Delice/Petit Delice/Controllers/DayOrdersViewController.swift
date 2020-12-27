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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRoundView()

    }
    
    func setUpRoundView() {
        ordersView.layer.cornerRadius = 10
        ordersView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

}

//extension DayOrdersViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        return cell
//    }
//    
//    
//}

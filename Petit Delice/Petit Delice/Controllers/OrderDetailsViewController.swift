//
//  OrderDetailsViewController.swift
//  Petit Delice
//
//  Created by Juhel on 29/12/2020.
//

import UIKit
import MaterialTextField
import Firebase
import FirebaseDatabase
import SDWebImage
import QuartzCore


class OrderDetailsViewController: UITableViewController {
    
    //MARK:- Picker View Choices
    let cakeTypeData = ["Cake", "Cupcakes"]
    var cakeSizeData = ["4 inch", "5 inch", "6 inch", "8 inch"]
    let cakeFlavourData = ["Vanilla", "Chocolate", "Red Velvet", "Oreo", "Funfetti"]
    
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var customerInstagramLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    @IBOutlet weak var cakeTypeLabel: UILabel!
    @IBOutlet weak var cakeSizeLabel: UILabel!
    @IBOutlet weak var cakeFlavourLabel: UILabel!
    @IBOutlet weak var giftBoxSweetTreatsLabel: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    
    @IBOutlet weak var customerNameTF: MFTextField!
    @IBOutlet weak var customerInstagramTF: MFTextField!
    @IBOutlet weak var deliveryDateTF: MFTextField!
    @IBOutlet weak var cakeTypeTF: MFTextField!
    @IBOutlet weak var cakeSizeTF: MFTextField!
    @IBOutlet weak var cakeFlavourTF: MFTextField!
    @IBOutlet weak var giftBoxSweetTreatsSwitch: UISwitch!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    
    var getCustomerName = String()
    var getCustomerInstagram = String()
    var getDeliveryDate = String()
    var getCakeType = String()
    var getCakeSize = String()
    var getCakeFlavour = String()
    var getGiftBoxSweetTreats = Bool()
    var getAdditionalInformation = String()
    var getCustomerReference = String()
    var getCreatedAt = String()
    var getImages = [String]()
    var displayImages = Bool()
    
    
    var isInEditMode = false
    var cameFromArchive = false
    
    
    let cakeTypePicker = UIPickerView()
    let cakeSizePicker = UIPickerView()
    let cakeFlavourPicker = UIPickerView()
    let datePicker = UIDatePicker()
    
    let database = Database.database().reference()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIForDetails()
        setUpTextFieldsForUI()
        setupNavigationBar()
        setUpPickerViews()
        setUpDatePicker()
        setUpCollectionView()
        additionalInfoLabel.sizeToFit()
    }
    
    func setUpDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressedOnToolbar))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        deliveryDateTF.inputAccessoryView = toolbar
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            print("iOS < 13.4")
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        if getDeliveryDate != "" {
            print("De Dt: \(getDeliveryDate)")
            let date = dateFormatter.date(from: getDeliveryDate)!
            datePicker.setDate(date, animated: true)
        }
        
        deliveryDateTF.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func doneButtonPressedOnToolbar() {
        deliveryDateTF.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func dateChanged() {
        deliveryDateTF.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    func setupNavigationBar(){
//        let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
//        navigationItem.rightBarButtonItem = editButton
//
//        let deleteButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(deleteButtonTapped))
//        deleteButton.tintColor = UIColor.red
//        navigationItem.setRightBarButtonItems([deleteButton,editButton], animated: false)
//
        if cameFromArchive == false {
            let moreButton = UIBarButtonItem(title: "More...", style: .plain, target: self, action: #selector(moreButtonTapped))
            navigationItem.rightBarButtonItem = moreButton
        }
    }
    
    
    
    
    @objc func moreButtonTapped(){
        let moreDialogueBox = UIAlertController(title: "More", message: "Choose an action", preferredStyle: .actionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print ("Cancel Button Tapped")
        }
        let editButton = UIAlertAction(title: "Edit", style: .default) { (action) in
            self.editButtonTapped()
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteButtonTapped()
        }
        let archiveButton = UIAlertAction(title: "Archive", style: .default) { (action) in
            self.archiveButtonTapped()
        }
        
        
        moreDialogueBox.addAction(cancelButton)
        moreDialogueBox.addAction(editButton)
        moreDialogueBox.addAction(archiveButton)
        moreDialogueBox.addAction(deleteButton)
        self.present(moreDialogueBox, animated: true, completion: nil)
    }
    
    
    
    
    func archiveButtonTapped(){
        let customerObject: [String: Any] = [
            "customer_name": getCustomerName as! NSObject,
            "instagram_username": getCustomerInstagram as! NSObject,
            "delivery_date": getDeliveryDate as! NSObject,
            "cake_type": getCakeType as! NSObject,
            "cake_size_or_quantity": getCakeSize as! NSObject,
            "cake_flavour": getCakeFlavour as NSObject,
            "gift_box_sweet_treats": giftBoxSweetTreatsSwitch.isOn as NSObject,
            "additional_information": getAdditionalInformation as NSObject,
            "customer_reference": getCustomerReference as NSObject,
            "created_at": getCreatedAt as NSObject
        ]
        
        database.child("archive").child("\(getCustomerReference)").setValue(customerObject) {
            (error:Error?, ref:DatabaseReference) in
            
            if let error = error {
                print("Data failed to archive \(error)")
            } else {
                self.removeData()
                print("Data archived")
            }
            
        }
        
        
    }
    
    
    
    @objc func editButtonTapped(){
        isInEditMode = true
        navigationItem.rightBarButtonItem = nil
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        
        
        UIView.transition(with: tableView,
                          duration: 0.15,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
        
        
        //tableView.reloadData()
        
    }
    
    
    
    
    
    @objc func deleteButtonTapped(){
        print("delete button tapped")
        let deleteDialogueBox = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print ("Cancel Button Tapped")
        }
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            print ("Delete Button Tapped")
            self.removeData()
        }
        
        deleteDialogueBox.addAction(cancelButton)
        deleteDialogueBox.addAction(deleteButton)
        
        self.present(deleteDialogueBox, animated: true, completion: nil)
        
    }
    
    
    
    func removeData(){
        database.child("orders").child(getCustomerReference).removeValue() {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be deleted: \(error).")
            } else {
              print("Data deleted successfully!")
                
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    
    
    
    @objc func doneButtonTapped(){
        updateDatabase()
    }
    

    
    
    
    
    func setUpPickerViews() {
        cakeTypePicker.delegate = self
        cakeTypeTF.inputView = cakeTypePicker
        
        cakeSizePicker.delegate = self
        cakeSizeTF.inputView = cakeSizePicker
        
        cakeFlavourPicker.delegate = self
        cakeFlavourTF.inputView = cakeFlavourPicker
        
        
    }
    
    
    func setUpTextFieldsForUI(){
        customerNameTF.text = getCustomerName
        customerInstagramTF.text = getCustomerInstagram
        deliveryDateTF.text = getDeliveryDate
        cakeTypeTF.text = getCakeType
        cakeSizeTF.text = getCakeSize
        cakeFlavourTF.text = getCakeFlavour
        
        
        if getGiftBoxSweetTreats == true {
            giftBoxSweetTreatsSwitch.isOn = true
            
        } else {
            giftBoxSweetTreatsSwitch.isOn = false
        }
   

        
        additionalInfoTextView.text = getAdditionalInformation
    }
    
    
    func setUpUIForDetails() {
        customerNameLabel.text = getCustomerName
        customerInstagramLabel.text = getCustomerInstagram
        createdAtLabel.text = getCreatedAt
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
    
    func setUpCollectionView() {
        let imagesLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        imagesLayout.itemSize = CGSize(width: 128, height: 128)
        imagesLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        imagesLayout.minimumInteritemSpacing = 5.0
        imagesLayout.minimumLineSpacing = 10.0
        imagesLayout.scrollDirection = .horizontal
        
        imagesCollectionView.collectionViewLayout = imagesLayout
    }
    
    
    func updateDatabase (){
     //   guard let key = database.child("orders").child(getCustomerReference) else { return }
        
        let customerObject: [String: Any] = [
            "customer_name": customerNameTF.text as! NSObject,
            "instagram_username": customerInstagramTF.text as! NSObject,
            "delivery_date": deliveryDateTF.text as! NSObject,
            "cake_type": cakeTypeTF.text as! NSObject,
            "cake_size_or_quantity": cakeSizeTF.text as! NSObject,
            "cake_flavour": cakeFlavourTF.text! as NSObject,
            "gift_box_sweet_treats": giftBoxSweetTreatsSwitch.isOn as NSObject,
            "additional_information": additionalInfoTextView.text as NSObject,
            "customer_reference": getCustomerReference as NSObject
        ]
        database.child("orders").child(getCustomerReference).updateChildValues(customerObject) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be saved: \(error).")
            } else {
              print("Data saved successfully!")
                
                //self.isInEditMode = false
                //self.navigationItem.rightBarButtonItem = nil
                //self.setupNavigationBar()
                //self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //0-8
        //9-17
        
        let isHiddenWhenInEditMode = [0,1,2,3,4,5,6,7,8,9,10]
        
        let isHiddenWhenInViewMode = [11,12,13,14,15,16,17,18,19]
        
        if isInEditMode == false {
            
            
            
            if isHiddenWhenInViewMode.contains(indexPath.row){
                return 0
            } else if indexPath.row == 9 {
                if displayImages == false {
                    return 0
                }
            }
            
        } else {
            if isHiddenWhenInEditMode.contains(indexPath.row){
                return 0
            } else if indexPath.row == 10 {
                return UITableView.automaticDimension
            }
            
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
      
        
        
    }

}


extension OrderDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == cakeTypePicker {
            return cakeTypeData.count
        } else if pickerView == cakeSizePicker {
            return cakeSizeData.count
        }
        return cakeFlavourData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == cakeTypePicker {
            return cakeTypeData[row]
        } else if pickerView == cakeSizePicker {
            return cakeSizeData[row]
        }
        return cakeFlavourData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == cakeTypePicker {
            cakeSizeTF.text = ""
            cakeTypeTF.text = cakeTypeData[row]
            
            if cakeTypeTF.text == "Cupcakes" {
                cakeSizeData = ["Box of 6", "Box of 12"]
            } else {
                cakeSizeData = ["4 inch", "5 inch", "6 inch", "8 inch"]
            }
        } else if pickerView == cakeSizePicker {
            cakeSizeTF.text = cakeSizeData[row]
        } else {
            cakeFlavourTF.text = cakeFlavourData[row]
        }
    }
    
    
}

extension OrderDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! UploadedImagesCollectionViewCell
        
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOpacity = 0.2
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.masksToBounds = false
        
        let imageURL = getImages[indexPath.row]
        cell.imageView.sd_setImage(with: URL(string: imageURL), completed: nil)
        return cell
    }
}

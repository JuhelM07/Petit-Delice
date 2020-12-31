//
//  CreateOrderViewController.swift
//  Petit Delice
//
//  Created by Juhel on 24/12/2020.
//

import UIKit
import FirebaseDatabase
import Firebase
import MaterialTextField

class CreateOrderViewController: UIViewController {
    
    //MARK:- Picker View Choices
    let cakeTypeData = ["Cake", "Cupcakes"]
    var cakeSizeData = ["4 inch", "5 inch", "6 inch", "8 inch"]
    let cakeFlavourData = ["Vanilla", "Chocolate", "Red Velvet", "Oreo", "Funfetti"]
    
    //MARK:- Outlets
    @IBOutlet weak var customerNameTextField: MFTextField!
    @IBOutlet weak var customerInstagramTextField: MFTextField!
    @IBOutlet weak var deliveryDateTextField: MFTextField!
    @IBOutlet weak var cakeTypeTextField: MFTextField!
    @IBOutlet weak var cakeSizeTextField: MFTextField!
    @IBOutlet weak var cakeFlavourTextField: MFTextField!
    @IBOutlet weak var giftBoxSweetTreatsSwitch: UISwitch!
    @IBOutlet weak var additionalInformationTextView: UITextView!
    
    //MARK:- Variables
    private let database = Database.database().reference()
    
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    var getDateFromMain = String()
    
    let cakeTypePicker = UIPickerView()
    let cakeSizePicker = UIPickerView()
    let cakeFlavourPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if getDateFromMain != "" {
            deliveryDateTextField.text = getDateFromMain
        }
        setUpPickerViews()
        
    }
    
    func setUpPickerViews() {
        cakeTypePicker.delegate = self
        cakeTypeTextField.inputView = cakeTypePicker
        
        cakeSizePicker.delegate = self
        cakeSizeTextField.inputView = cakeSizePicker
        
        cakeFlavourPicker.delegate = self
        cakeFlavourTextField.inputView = cakeFlavourPicker
        
        
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        var orderString = String()
        
        database.child("orders").observeSingleEvent(of: .value) { (snapshot) in
            
            repeat {
                orderString = String((0..<8).map{ _ in self.letters.randomElement()! })
            } while snapshot.hasChild(orderString)
            
            self.addNewOrder(orderString: orderString)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func addNewOrder(orderString: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        let date = dateFormatter.string(from: Date())
        
        let customerObject: [String: Any] = [
            "customer_name": customerNameTextField.text as! NSObject,
            "instagram_username": customerInstagramTextField.text as! NSObject,
            "delivery_date": deliveryDateTextField.text as! NSObject,
            "cake_type": cakeTypeTextField.text as! NSObject,
            "cake_size_or_quantity": cakeSizeTextField.text as! NSObject,
            "cake_flavour": cakeFlavourTextField.text! as NSObject,
            "gift_box_sweet_treats": giftBoxSweetTreatsSwitch.isOn as NSObject,
            "additional_information": additionalInformationTextView.text as NSObject,
            "customer_reference": orderString as NSObject,
            "created_at": date as NSObject
        ]
        
        database.child("orders").child("\(orderString)").setValue(customerObject)
    }
    
}

extension CreateOrderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
            cakeSizeTextField.text = ""
            cakeTypeTextField.text = cakeTypeData[row]
            
            if cakeTypeTextField.text == "Cupcakes" {
                cakeSizeData = ["Box of 6", "Box of 12"]
            } else {
                cakeSizeData = ["4 inch", "5 inch", "6 inch", "8 inch"]
            }
        } else if pickerView == cakeSizePicker {
            cakeSizeTextField.text = cakeSizeData[row]
        } else {
            cakeFlavourTextField.text = cakeFlavourData[row]
        }
    }
    
    
}

extension CreateOrderViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cakeTypeTextField{
            let index = cakeTypePicker.selectedRow(inComponent: 0)
            if index == 0 {
                cakeTypeTextField.text = cakeTypeData.first
            }
            

        } else if textField == cakeSizeTextField{
            let index = cakeSizePicker.selectedRow(inComponent: 0)
            if index == 0 {
                cakeSizeTextField.text = cakeSizeData.first
            }
        } else if textField == cakeFlavourTextField{
            let index = cakeFlavourPicker.selectedRow(inComponent: 0)
            if index == 0 {
                cakeFlavourTextField.text = cakeFlavourData.first
            }
        }
        
        
        
        
        
    }
    
}

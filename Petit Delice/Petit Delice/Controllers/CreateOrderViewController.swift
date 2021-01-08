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
import FirebaseStorage
import JGProgressHUD

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
    
    @IBOutlet weak var depositTextField: MFTextField!
    @IBOutlet weak var totalAmountTextField: MFTextField!
    @IBOutlet weak var imageUploadButton: UIButton!
    @IBOutlet weak var additionalInformationTextView: UITextView!
    
    @IBOutlet weak var additionalInformationTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageFileName1Label: UILabel!
    @IBOutlet weak var imageFileName2Label: UILabel!
    @IBOutlet weak var imageFileName3Label: UILabel!
    
    @IBOutlet weak var uploadedImageStackView1: UIStackView!
    @IBOutlet weak var uploadedImageStackView2: UIStackView!
    @IBOutlet weak var uploadedImageStackView3: UIStackView!
    
    
    //MARK:- Variables
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let hud = JGProgressHUD()
    
    var getDateFromMain = String()
    
    let cakeTypePicker = UIPickerView()
    let cakeSizePicker = UIPickerView()
    let cakeFlavourPicker = UIPickerView()
    let datePicker = UIDatePicker()
    
    var uploadedImagesCount = 0
    var imagesData = [Data]()
    var imageNames = [String]()
    var imageURLs = [String]()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if getDateFromMain != "" {
            deliveryDateTextField.text = getDateFromMain
        }
        setUpPickerViews()
        setUpDatePicker()
        setUpOutletButtonUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpImagesUploadedUI()
    }
    
    func setUpImagesUploadedUI() {
        if uploadedImagesCount == 0 {
            additionalInformationTopConstraint.constant = 20.0
            uploadedImageStackView1.isHidden = true
            uploadedImageStackView2.isHidden = true
            uploadedImageStackView3.isHidden = true
        } else {
            additionalInformationTopConstraint.constant = 100.0
        }
    }
    
    func setUpOutletButtonUI() {
        imageUploadButton.layer.shadowColor = UIColor.lightGray.cgColor
        imageUploadButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageUploadButton.layer.shadowRadius = 5.0
        imageUploadButton.layer.shadowOpacity = 0.2
        imageUploadButton.layer.masksToBounds = false
        
    }
    
    func setUpPickerViews() {
        cakeTypePicker.delegate = self
        cakeTypeTextField.inputView = cakeTypePicker
        
        cakeSizePicker.delegate = self
        cakeSizeTextField.inputView = cakeSizePicker
        
        cakeFlavourPicker.delegate = self
        cakeFlavourTextField.inputView = cakeFlavourPicker
    }
    
    func setUpDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressedOnToolbar))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        deliveryDateTextField.inputAccessoryView = toolbar
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
            print("iOS < 13.4")
        }
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        if getDateFromMain != "" {
            let date = dateFormatter.date(from: deliveryDateTextField.text!)!
            datePicker.setDate(date, animated: true)
        }
        
        deliveryDateTextField.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func doneButtonPressedOnToolbar() {
        deliveryDateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func dateChanged() {
        deliveryDateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        var orderString = String()
        
        hud.textLabel.text = "Loading"
        hud.show(in: self.view, animated: true)
        
        database.child("orders").observeSingleEvent(of: .value) { (snapshot) in
            
            repeat {
                orderString = String((0..<8).map{ _ in self.letters.randomElement()! })
            } while snapshot.hasChild(orderString)
            
            if self.uploadedImagesCount > 0 {
                print("\(self.uploadedImagesCount) images")
                for imageName in self.imageNames {
                    let index = self.imageNames.firstIndex(of: imageName)!
                    self.uploadImages(orderString: orderString, imageName: imageName, index: index)
                }
            } else {
                print("No images")
                self.addNewOrder(orderString: orderString)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func deleteImageTapped(_ sender: UIButton) {
        
        imageUploadButton.isEnabled = true
        
        if uploadedImagesCount == 3 {
            uploadedImageStackView3.isHidden = true
            uploadedImagesCount = uploadedImagesCount - 1
        } else if uploadedImagesCount == 2 {
            uploadedImageStackView2.isHidden = true
            uploadedImagesCount = uploadedImagesCount - 1
        } else {
            uploadedImageStackView2.isHidden = true
            uploadedImagesCount = uploadedImagesCount - 1
            setUpImagesUploadedUI()
        }
        
        if sender.tag == 1001 {
            print("Remove first image")
            
            imagesData.remove(at: 0)
            imageNames.remove(at: 0)
            
        } else if sender.tag == 1002 {
            print("Remove second image")
            
            imagesData.remove(at: 1)
            imageNames.remove(at: 1)
            
        } else if sender.tag == 1003 {
            print("Remove third image")
            
            imagesData.remove(at: 2)
            imageNames.remove(at: 2)
        }
        
        
        if uploadedImagesCount == 2 {
            imageFileName1Label.text = imageNames[0]
            imageFileName2Label.text = imageNames[1]
        } else if uploadedImagesCount == 1 {
            imageFileName1Label.text = imageNames[0]
        }
        
        print("Remaining to upload \(imageNames)")
        print("Remaining to upload \(imagesData)")
        
        
    }
    
    

    
    
    func addNewOrder(orderString: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
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
            "created_at": date as NSObject,
            "deposit_amount": depositTextField.text as! NSObject,
            "total_amount": totalAmountTextField.text as! NSObject,
            "images": imageURLs as NSObject
            //image upload here
        ]

        database.child("orders").child("\(orderString)").setValue(customerObject)
        hud.dismiss()
        

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
    
    func uploadImages(orderString: String, imageName: String, index: Int) {
        
        let reference = storage.child("images").child(orderString).child(imageName)
        
        print(orderString)
        print(imageName)
        print(index)
        
        reference.putData(imagesData[index], metadata: nil) { ( _, error) in
            guard error == nil else {
                print("Failed to upload data")
                return
            }
            
            self.storage.child("images").child(orderString).child(imageName).downloadURL { (url, error) in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteURL
                self.imageURLs.append("\(urlString)")
                print("Download URLs \(self.imageURLs)")
                
                if self.imageURLs.count == self.uploadedImagesCount {
                    self.addNewOrder(orderString: orderString)
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
            
        }
    }
    
}

extension CreateOrderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    @IBAction func chooseFileButtonTapped(_ sender: Any) {
        let photoPicker = UIImagePickerController()
        photoPicker.sourceType = .photoLibrary
        photoPicker.delegate = self
        photoPicker.allowsEditing = true
        present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        
        
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                var fileName = url.lastPathComponent
                let fileType = url.pathExtension
            if uploadedImagesCount < 3 {
                uploadedImagesCount = uploadedImagesCount + 1
            }
            fileName = fileName.replacingOccurrences(of: ".\(fileType)", with: "", options: NSString.CompareOptions.literal, range: nil)
            setUpImagesUploadedUI()
            if uploadedImagesCount == 1 {
                uploadedImageStackView1.isHidden = false
                imageFileName1Label.text = fileName
                imageNames.append(fileName)
            } else if uploadedImagesCount == 2 {
                uploadedImageStackView2.isHidden = false
                imageFileName2Label.text = fileName
                imageNames.append(fileName)
            } else if uploadedImagesCount == 3 {
                uploadedImageStackView3.isHidden = false
                imageFileName3Label.text = fileName
                imageNames.append(fileName)
                
                imageUploadButton.isEnabled = false
                imageUploadButton.setTitle("Max uploaded", for: .disabled)
            }
        }
        
        guard let imageData = image.pngData() else { return }
        imagesData.append(imageData)
        
        print(imageNames)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

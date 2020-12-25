//
//  Order.swift
//  Petit Delice
//
//  Created by Juhel on 24/12/2020.
//

import Foundation

struct Order: Codable {
    let orders: OrderDetails
}

struct OrderDetails: Codable {
    let customerName: String
    let instagramUsername: String
    let deliveryDate: String
    let cakeType: String
    let cakeSizeQuantity: String
    let cakeFlavour: String
    let giftBoxSweetTreats: Bool
    let additionalInformation: String
    
    init?(data: [String: Any]) {
        
        guard let customerName = data["customer_name"] as? String,
            let instagramUsername = data["instagram_username"] as? String,
            let deliveryDate = data["delivery_date"] as? String,
            let cakeType = data["cake_type"] as? String,
            let cakeSizeQuantity = data["cake_size_or_quantity"] as? String,
            let cakeFlavour = data["cake_flavour"] as? String,
            let giftBoxSweetTreats = data["gift_box_sweet_treats"] as? Bool,
            let additionalInformation = data["additional_information"] as? String else {
                return nil
        }
        
        
        self.customerName = customerName
        self.instagramUsername = instagramUsername
        self.deliveryDate = deliveryDate
        self.cakeType = cakeType
        self.cakeSizeQuantity = cakeSizeQuantity
        self.cakeFlavour = cakeFlavour
        self.giftBoxSweetTreats = giftBoxSweetTreats
        self.additionalInformation = additionalInformation
    }
    
    enum CodingKeys: String, CodingKey {
        case customerName = "customer_name"
        case instagramUsername = "instagram_username"
        case deliveryDate = "delivery_date"
        case cakeType = "cake_type"
        case cakeSizeQuantity = "cake_size_or_quantity"
        case cakeFlavour = "cake_flavour"
        case giftBoxSweetTreats = "gift_box_sweet_treats"
        case additionalInformation = "additional_information"
    }
    
}

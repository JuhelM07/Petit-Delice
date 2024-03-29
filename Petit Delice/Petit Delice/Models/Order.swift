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
    let images: [String]?
    let additionalInformation: String
    let customerReference: String
    let createdAt: String
    
    init?(data: [String: Any]) {
        
        guard let customerName = data["customer_name"] as? String,
            let instagramUsername = data["instagram_username"] as? String,
            let deliveryDate = data["delivery_date"] as? String,
            let cakeType = data["cake_type"] as? String,
            let cakeSizeQuantity = data["cake_size_or_quantity"] as? String,
            let cakeFlavour = data["cake_flavour"] as? String,
            let giftBoxSweetTreats = data["gift_box_sweet_treats"] as? Bool,
            let images = data["images"] as? [String],
            let additionalInformation = data["additional_information"] as? String,
            let customerReference = data["customer_reference"] as? String,
            let createdAt = data["created_at"] as? String else {
                return nil
        }
        
        
        self.customerName = customerName
        self.instagramUsername = instagramUsername
        self.deliveryDate = deliveryDate
        self.cakeType = cakeType
        self.cakeSizeQuantity = cakeSizeQuantity
        self.cakeFlavour = cakeFlavour
        self.giftBoxSweetTreats = giftBoxSweetTreats
        self.images = images
        self.additionalInformation = additionalInformation
        self.customerReference = customerReference
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case customerName = "customer_name"
        case instagramUsername = "instagram_username"
        case deliveryDate = "delivery_date"
        case cakeType = "cake_type"
        case cakeSizeQuantity = "cake_size_or_quantity"
        case cakeFlavour = "cake_flavour"
        case giftBoxSweetTreats = "gift_box_sweet_treats"
        case images = "images"
        case additionalInformation = "additional_information"
        case customerReference = "customer_reference"
        case createdAt = "created_at"
    }
    
}

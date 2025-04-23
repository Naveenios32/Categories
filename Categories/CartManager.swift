//
//  CartManager.swift
//  Categories
//
//  Created by NaveenKumar on 22/04/25.
//


import Foundation

class CartManager {
    static let shared = CartManager()
    private init() {}

    private var items = [[String: Any]]()
    func addItem(_ item: [String: Any]) {
        guard let newItemID = item["id"] as? Int else {
            print("Item missing 'id' key, cannot check for duplicates.")
            return
        }

        let isAlreadyInCart = items.contains { ($0["id"] as? Int) == newItemID }
        if isAlreadyInCart {
            print("Item already in cart with ID: \(newItemID)")
            return
        }

        items.append(item)
    }



    func clearCart() {
        items.removeAll()
    }

    func getCartItems() -> [[String: Any]] {
        return items
    }
}

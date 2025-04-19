//
//  CartManager.swift
//  Categories
//
//  Created by NaveenKumar on 22/04/25.
//

import Foundation
import Foundation

class CartManager {
    static let shared = CartManager()
    private init() {}

    private var items = [[String: Any]]()

    func addItem(_ item: [String: Any]) {
        items.append(item)
    }

    func clearCart() {
        items.removeAll()
    }

    func getCartItems() -> [[String: Any]] {
        return items
    }
}

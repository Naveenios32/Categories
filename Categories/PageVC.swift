//
//  PageVC.swift
//  Categories
//
//  Created by Apple on 02/04/25.
//

import UIKit

class PageVC: UIViewController {
    
    @IBOutlet weak var backbtn: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    var allData: [String: Any]?
        static var cartItems = [[String: Any]]() 
        

    override func viewDidLoad() {
        super.viewDidLoad()

        backbtn.layer.cornerRadius = 25
        addToCartButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)

        setupUI()
    }

    func setupUI() {
        guard let data = allData else {
            print("Error: No data received in PageVC")
            return
        }

        category.text = data["category"] as? String ?? "Unknown Category"
        desc.text = data["description"] as? String ?? "No description available"
        price.text = "$\(data["price"] as? Double ?? 0.0)"

        if let ratingDict = data["rating"] as? [String: Any] {
            let ratingValue = ratingDict["rate"] as? Double ?? 0.0
            let countValue = ratingDict["count"] as? Int ?? 0
            rate.text = "\(ratingValue)"
            count.text = "Reviews: \(countValue)"
        } else {
            rate.text = "No rating"
            count.text = "Reviews: 0"
        }

        if let urlString = data["image"] as? String, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.image.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            image.image = UIImage(named: "placeholder")
        }
    }

    @IBAction func back(_ sender: Any) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "NavigatePage") as! NavigatePage
         
            navigationController?.pushViewController(secondVC, animated: true)
    }

    @objc func addToCart() {
        guard let item = allData else {
            print("Error: No item data to add to cart")
            return
        }

        PageVC.cartItems.append(item)
        print("Item added to cart: \(item)")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let cartVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            cartVC.cartItems = PageVC.cartItems

            navigationController?.pushViewController(cartVC, animated: true)
        } else {
            print("Error: Could not instantiate ViewController. Check storyboard ID.")
        }
    }
}

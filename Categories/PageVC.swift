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

           updateUI()
       }

       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           // Reconfigure UI when the view reappears to ensure data is refreshed
           updateUI()
       }

       func updateUI() {
           guard let data = allData else { return }

           category.text = data["category"] as? String ?? "Unknown Category"
           desc.text = data["description"] as? String ?? "No description"
           price.text = "$\(data["price"] as? Double ?? 0.0)"

           if let rating = data["rating"] as? [String: Any] {
               rate.text = "\(rating["rate"] as? Double ?? 0.0)"
               count.text = "Reviews: \(rating["count"] as? Int ?? 0)"
           }

           if let urlStr = data["image"] as? String, let url = URL(string: urlStr) {
               DispatchQueue.global().async {
                   if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                       DispatchQueue.main.async {
                           self.image.image = img
                       }
                   }
               }
           }
       }

       @IBAction func back(_ sender: Any) {
           // When navigating back, ensure that allData is still set
           let secondVC = storyboard?.instantiateViewController(withIdentifier: "NavigatePage") as! NavigatePage
           navigationController?.pushViewController(secondVC, animated: true)
       }

       @objc func addToCart() {
           guard let item = allData else { return }

           // Add item to the CartManager
           CartManager.shared.addItem(item)

           // Push ViewController with cart data after adding item
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let cartVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
               navigationController?.pushViewController(cartVC, animated: true)
           }
       }
   }

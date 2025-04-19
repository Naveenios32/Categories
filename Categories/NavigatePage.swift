//
//  NavigatePage.swift
//  Categories
//
//  Created by Apple on 02/04/25.
//

import UIKit

class NavigatePage: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var receivedData = [[String:Any]]()
   
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var CollectionPage: UICollectionView!
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           CollectionPage.register(UINib(nibName: "NavigateCell", bundle: nil), forCellWithReuseIdentifier: "NavigateCell")
           CollectionPage.delegate = self
           CollectionPage.dataSource = self
           
           back.layer.cornerRadius = 25
           back.addTarget(self, action: #selector(gotobackPage), for: .touchUpInside)
       }
       
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           print("NavigatePage appeared — reloading data")
           CollectionPage.reloadData() // Refresh data when coming back from PageVC
       }

       @objc func gotobackPage() {
           let secondVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
         
               navigationController?.pushViewController(secondVC, animated: true)
       }
       
       // MARK: CollectionView DataSource

       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return receivedData.count
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           guard let smallCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavigateCell", for: indexPath) as? NavigateCell else {
               print("Error: Unable to dequeue NavigateCell")
               return UICollectionViewCell()
           }
           
           let product = receivedData[indexPath.row]
           let imageUrl = product["image"] as? String ?? ""
           let title = product["title"] as? String ?? "Unknown"
           
           let priceText: String
           if let price = product["price"] as? Double {
               priceText = "$\(price)"
           } else if let price = product["price"] as? Int {
               priceText = "$\(price)"
           } else {
               priceText = "Price not available"
           }

           smallCell.desc.text = title
           smallCell.price.text = priceText
           smallCell.imageName.image = UIImage(named: "placeholder")

           if let url = URL(string: imageUrl) {
               DispatchQueue.global().async {
                   if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                       DispatchQueue.main.async {
                           smallCell.imageName.image = image
                       }
                   }
               }
           }

           return smallCell
       }
       
       // MARK: CollectionView Layout

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
           return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
       }

       // MARK: Navigation

       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let selectedProduct = receivedData[indexPath.row]
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           if let detailsPage = storyboard.instantiateViewController(withIdentifier: "PageVC") as? PageVC {
               detailsPage.allData = selectedProduct
               navigationController?.pushViewController(detailsPage, animated: true)
           } else {
               print("Error: Could not instantiate PageVC")
           }
       }
   }

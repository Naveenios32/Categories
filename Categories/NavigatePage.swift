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
    
//    override func viewDidLoad() {
//           super.viewDidLoad()
//
//           CollectionPage.register(UINib(nibName: "NavigateCell", bundle: nil), forCellWithReuseIdentifier: "NavigateCell")
//           CollectionPage.delegate = self
//           CollectionPage.dataSource = self
//
//           back.layer.cornerRadius = 25
//           back.addTarget(self, action: #selector(gotobackPage), for: .touchUpInside)
//       }
//
//       override func viewWillAppear(_ animated: Bool) {
//           super.viewWillAppear(animated)
//           print("NavigatePage appeared — reloading data")
//           CollectionPage.reloadData() // Refresh data when coming back from PageVC
//       }
//
//       @objc func gotobackPage() {
//           let secondVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//
//               navigationController?.pushViewController(secondVC, animated: true)
//       }
//
//       // MARK: CollectionView DataSource
//
//       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//           return receivedData.count
//       }
//
//       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//           guard let smallCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavigateCell", for: indexPath) as? NavigateCell else {
//               print("Error: Unable to dequeue NavigateCell")
//               return UICollectionViewCell()
//           }
//
//           let product = receivedData[indexPath.row]
//           let imageUrl = product["image"] as? String ?? ""
//           let title = product["title"] as? String ?? "Unknown"
//
//           let priceText: String
//           if let price = product["price"] as? Double {
//               priceText = "$\(price)"
//           } else if let price = product["price"] as? Int {
//               priceText = "$\(price)"
//           } else {
//               priceText = "Price not available"
//           }
//
//           smallCell.desc.text = title
//           smallCell.price.text = priceText
//           smallCell.imageName.image = UIImage(named: "placeholder")
//
//           if let url = URL(string: imageUrl) {
//               DispatchQueue.global().async {
//                   if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
//                       DispatchQueue.main.async {
//                           smallCell.imageName.image = image
//                       }
//                   }
//               }
//           }
//
//           return smallCell
//       }
//
//       // MARK: CollectionView Layout
//
//       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//           return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//       }
//
//       // MARK: Navigation
//
//       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//           let selectedProduct = receivedData[indexPath.row]
//           let storyboard = UIStoryboard(name: "Main", bundle: nil)
//           if let detailsPage = storyboard.instantiateViewController(withIdentifier: "PageVC") as? PageVC {
//               detailsPage.allData = selectedProduct
//               navigationController?.pushViewController(detailsPage, animated: true)
//           } else {
//               print("Error: Could not instantiate PageVC")
//           }
//       }
//   }
    override func viewDidLoad() {
          super.viewDidLoad()
          
          CollectionPage.register(UINib(nibName: "NavigateCell", bundle: nil), forCellWithReuseIdentifier: "NavigateCell")
          CollectionPage.delegate = self
          CollectionPage.dataSource = self
          
          back.layer.cornerRadius = 25
          back.addTarget(self, action: #selector(gotobackPage), for: .touchUpInside)
          
          fetchData()
      }
      
      override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          fetchData()
      }
      
      func fetchData() {
          // Your API call here (example using URLSession)
          guard let url = URL(string: "https://fakestoreapi.com/products") else { return }

          URLSession.shared.dataTask(with: url) { data, response, error in
              if let error = error {
                  print("API error:", error.localizedDescription)
                  return
              }
              
              guard let data = data else { return }
              
              do {
                  if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                      DispatchQueue.main.async {
                          self.receivedData = jsonArray
                          self.CollectionPage.reloadData()
                      }
                  }
              } catch {
                  print("Failed to parse JSON:", error)
              }
          }.resume()
      }

      @objc func gotobackPage() {
          let secondVC = storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
         
                        navigationController?.pushViewController(secondVC, animated: true)
      }

      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          return receivedData.count
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          guard let smallCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NavigateCell", for: indexPath) as? NavigateCell else {
              return UICollectionViewCell()
          }

          let product = receivedData[indexPath.row]
          smallCell.desc.text = product["title"] as? String ?? "Unknown"
          smallCell.price.text = "$\(product["price"] as? Double ?? 0.0)"
          smallCell.imageName.image = UIImage(named: "placeholder")

          if let urlString = product["image"] as? String, let url = URL(string: urlString) {
              DispatchQueue.global().async {
                  if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                      DispatchQueue.main.async {
                          smallCell.imageName.image = image
                      }
                  }
              }
          }

          return smallCell
      }
      
      func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
          let selectedProduct = receivedData[indexPath.row]
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          if let detailsPage = storyboard.instantiateViewController(withIdentifier: "PageVC") as? PageVC {
              detailsPage.allData = selectedProduct
              navigationController?.pushViewController(detailsPage, animated: true)
          }
      }
  }

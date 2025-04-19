//
//  HomeVC.swift
//  Categories
//
//  Created by Apple on 01/04/25.
//

import UIKit
import MapKit
import CoreLocation

class HomeVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate {
    
    var serverresult = [[String:Any]]()
    let locationManager = CLLocationManager()
    var locationLabel : UILabel!
    var searchBar : UISearchBar!
    let delivery = UILabel()
    
    @IBAction func nextPage1(_ sender: Any) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "NavigatePage") as! NavigatePage
            secondVC.receivedData = serverresult
            navigationController?.pushViewController(secondVC, animated: true)
    }
    
    
    @IBAction func nextPage2(_ sender: Any) {
        let secondVC = storyboard?.instantiateViewController(withIdentifier: "NavigatePage") as! NavigatePage
            secondVC.receivedData = serverresult
            navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            CollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
            CollectionView.delegate = self
            CollectionView.dataSource = self
            
            fetchProducts()
            setupUI()
           setupSearchBar()
    
           locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            } else {
                print("Location services are not enabled")
            }
        
        delivery.text = "Delivey Address"
        delivery.textColor = .systemGray3
        delivery.textAlignment = .center
        delivery.frame = CGRect(x: 180, y: 20, width: 100, height: 20)

        }
        
      
        
    func fetchProducts() {
        let urlString = "https://fakestoreapi.com/products"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let productData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    self.serverresult = productData
                    
                    DispatchQueue.main.async {
                        self.CollectionView.reloadData()
                    }
                } else {
                    print("Error: API did not return expected array format.")
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return serverresult.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let smallCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
                print("Error: Unable to dequeue CollectionViewCell")
                return UICollectionViewCell()
            }
            
            let product = serverresult[indexPath.row]
            let imageUrl = product["image"] as? String ?? ""
            let category = product["category"] as? String ?? "Unknown"
            let price = product["price"] as? String ?? "Unknown"

            
            
            if let url = URL(string: imageUrl) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: url) {
                        if let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                smallCell.imageView.image = image  // Set image to imageView
                            }
                        }
                    }
                }
            } else {
                smallCell.imageView.image = UIImage(named: "image")  // Set default image if URL is invalid
            }
            
            smallCell.label.text = category
            return smallCell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

        return UIEdgeInsets(top: 0.0, left: 15, bottom: 5, right: 10)

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
               guard let location = locations.last else { return }
               fetchLocationName(from: location)
               locationManager.stopUpdatingLocation()
           }

           func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
               locationLabel.text = "Failed to get location"
               print("Error: \(error.localizedDescription)")
           }

           func fetchLocationName(from location: CLLocation) {
               let geocoder = CLGeocoder()
               geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                   guard let self = self else { return }
                   if let error = error {
                       self.locationLabel.text = "Error: \(error.localizedDescription)"
                       return
                   }

                   if let placemark = placemarks?.first,
                      let locality = placemark.locality,
                      let country = placemark.country {
                       self.locationLabel.text = "\(locality), \(country)"
                   } else {
                       self.locationLabel.text = "Location not found"
                   }
               }
           }


    func checkLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationLabel.text = "Location access denied. Please enable location in settings."
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    
    func setupUI() {
               locationLabel = UILabel()
               locationLabel.textAlignment = .center
               locationLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
               locationLabel.text = "Fetching location..."
               locationLabel.translatesAutoresizingMaskIntoConstraints = false

               view.addSubview(locationLabel)

               NSLayoutConstraint.activate([
                   locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                   locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
               ])
           }
    
    
    func setupSearchBar() {
              let searchContainer = UIView()
              searchContainer.backgroundColor = UIColor.systemGray5
              searchContainer.layer.cornerRadius = 10
              searchContainer.clipsToBounds = true
              
              let searchTextField = UITextField()
              searchTextField.placeholder = "           Search the entire shop"
              searchTextField.font = UIFont.systemFont(ofSize: 16)
              searchTextField.borderStyle = .none
              searchTextField.backgroundColor = .clear
              
              let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
              searchIcon.tintColor = .darkGray
              searchIcon.contentMode = .scaleAspectFit
              searchTextField.leftView = searchIcon
              searchTextField.leftViewMode = .always

              searchContainer.addSubview(searchTextField)
              view.addSubview(searchContainer)
              searchContainer.translatesAutoresizingMaskIntoConstraints = false
              searchTextField.translatesAutoresizingMaskIntoConstraints = false
              
              NSLayoutConstraint.activate([
                  searchContainer.heightAnchor.constraint(equalToConstant: 55),
                  searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                  searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                  searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 65),
                  
                  searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 15),
                  searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
                  
                  
              ])
          }
    }

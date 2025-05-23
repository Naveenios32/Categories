



import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    
    var selectedItems = Set<Int>()
    var itemQuantities = [Int: Int]()
    
    var cartItems: [[String: Any]] {
        return CartManager.shared.getCartItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        initializeQuantities()
        addCartIconToView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateCartBadge()

    }
    
    func setupUI() {
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(proceedToCheckout), for: .touchUpInside)
        selectAllButton.addTarget(self, action: #selector(toggleSelectAll), for: .touchUpInside)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "CartCell")
    }
    
    func initializeQuantities() {
        for index in 0..<cartItems.count {
            if itemQuantities[index] == nil {
                itemQuantities[index] = 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        let item = cartItems[index]
        
        cell.titleLabel.text = item["title"] as? String ?? "Item"
        cell.priceLabel.text = "$\(item["price"] as? Double ?? 0.0)"
        cell.quantityLabel.text = "\(itemQuantities[index] ?? 1)"
        
        if let urlStr = item["image"] as? String, let url = URL(string: urlStr) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.productImageView.image = img
                    }
                }
            }
        }
        
        
        cell.checkmarkButton.setImage(
            UIImage(systemName: selectedItems.contains(index) ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        
        
        cell.plusButton.tag = index
        cell.minusButton.tag = index
        cell.checkmarkButton.tag = index
        
        cell.plusButton.addTarget(self, action: #selector(increaseQuantity(_:)), for: .touchUpInside)
        cell.minusButton.addTarget(self, action: #selector(decreaseQuantity(_:)), for: .touchUpInside)
        cell.checkmarkButton.addTarget(self, action: #selector(toggleSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    @objc func increaseQuantity(_ sender: UIButton) {
        let index = sender.tag
        itemQuantities[index, default: 1] += 1
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    @objc func decreaseQuantity(_ sender: UIButton) {
        let index = sender.tag
        if let quantity = itemQuantities[index], quantity > 1 {
            itemQuantities[index] = quantity - 1
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    @objc func toggleSelection(_ sender: UIButton) {
        let index = sender.tag
        if selectedItems.contains(index) {
            selectedItems.remove(index)
        } else {
            selectedItems.insert(index)
        }
        
        
        updateSelectAllButton()
        
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    @objc func toggleSelectAll() {
        if selectedItems.count < cartItems.count {
            
            selectedItems = Set(0..<cartItems.count)
        } else {
            
            selectedItems.removeAll()
        }
        
        
        updateSelectAllButton()
        
        
        tableView.reloadData()
    }
    
    func updateSelectAllButton() {
        if selectedItems.count == cartItems.count {
            selectAllButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            selectAllButton.setImage(UIImage(systemName: "circle"), for: .normal)
        }
    }
    @objc func proceedToCheckout() {
        let selectedProducts = selectedItems.map { cartItems[$0] }
        if selectedProducts.isEmpty {
            let alert = UIAlertController(title: "No Items Selected", message: "Please select items before checkout.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        } else {
            print("Checkout items: \(selectedProducts)")
            
            // Show Thank You alert
            let thankYouAlert = UIAlertController(title: "Thank You!", message: "Your order has been placed successfully.", preferredStyle: .alert)
            thankYouAlert.addAction(UIAlertAction(title: "OK", style: .default))
            present(thankYouAlert, animated: true)
            
            // Optional: clear selected items after checkout
            selectedItems.removeAll()
            tableView.reloadData()
        }
    }
    func addCartIconToView() {
        let cartButton = UIButton(type: .custom)
        cartButton.setImage(UIImage(systemName: "cart"), for: .normal)
        cartButton.tintColor = .black
        cartButton.frame = CGRect(x: view.frame.width - 100, y: 90, width: 40, height: 40)
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)

        let badgeLabel = UILabel(frame: CGRect(x: 25, y: -5, width: 18, height: 18))
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textColor = .white
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 9
        badgeLabel.layer.masksToBounds = true
        badgeLabel.tag = 99
        cartButton.addSubview(badgeLabel)

        cartButton.tag = 88
        view.addSubview(cartButton)

        updateCartBadge()
    }

    func updateCartBadge() {
        if let cartButton = view.viewWithTag(88) as? UIButton,
           let badgeLabel = cartButton.viewWithTag(99) as? UILabel {
            let count = cartItems.count
            badgeLabel.text = "\(count)"
            badgeLabel.isHidden = count == 0
        }
    }


    @objc func cartButtonTapped() {
        print("Cart icon tapped!") // Optional: navigate to cart page
    }

}

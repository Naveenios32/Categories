



import UIKit

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!

    var cartItems = [[String: Any]]()
        var selectedItems = Set<Int>()
        var itemQuantities = [Int: Int]()


override func viewDidLoad() {
    super.viewDidLoad()

    print("Cart Loaded. Items:", cartItems)
    setupUI()
    setupTableView()
    initializeQuantities()
}

override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
}

func setupUI() {
    checkoutButton.layer.cornerRadius = 10
    checkoutButton.addTarget(self, action: #selector(proceedToCheckout), for: .touchUpInside)
    selectAllButton.addTarget(self, action: #selector(toggleSelectAll), for: .touchUpInside)
}

func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self

    let nib = UINib(nibName: "CartCell", bundle: nil)
    tableView.register(nib, forCellReuseIdentifier: "CartCell")
}

func initializeQuantities() {
    for index in 0..<cartItems.count {
        if itemQuantities[index] == nil {
            itemQuantities[index] = 1
        }
    }
}

// MARK: - TableView DataSource

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cartItems.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as? CartCell else {
        return UITableViewCell()
    }

    let index = indexPath.row
    let item = cartItems[index]
    let title = item["title"] as? String ?? "Unknown Item"
    let price = item["price"] as? Double ?? 0.0
    let imageUrl = item["image"] as? String ?? ""
    let quantity = itemQuantities[index] ?? 1
    let isSelected = selectedItems.contains(index)

    // Populate cell
    cell.titleLabel.text = title
    cell.priceLabel.text = "$\(price)"
    cell.quantityLabel.text = "\(quantity)"
    cell.checkmarkButton.setImage(UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle"), for: .normal)

    // Load image
    if let url = URL(string: imageUrl) {
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    cell.productImageView.image = image
                }
            }
        }
    } else {
        cell.productImageView.image = UIImage(named: "placeholder")
    }

    // Set button actions
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

// MARK: - Quantity Controls

@objc func increaseQuantity(_ sender: UIButton) {
    let index = sender.tag
    itemQuantities[index, default: 1] += 1
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
}

@objc func decreaseQuantity(_ sender: UIButton) {
    let index = sender.tag
    if let currentQuantity = itemQuantities[index], currentQuantity > 1 {
        itemQuantities[index] = currentQuantity - 1
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}

// MARK: - Selection Controls

@objc func toggleSelection(_ sender: UIButton) {
    let index = sender.tag
    if selectedItems.contains(index) {
        selectedItems.remove(index)
    } else {
        selectedItems.insert(index)
    }
    tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
}

@objc func toggleSelectAll() {
    if selectedItems.count < cartItems.count {
        selectedItems = Set(0..<cartItems.count)
    } else {
        selectedItems.removeAll()
    }
    tableView.reloadData()
}

// MARK: - Checkout

@objc func proceedToCheckout() {
    let selectedProducts = selectedItems.map { cartItems[$0] }

    if selectedProducts.isEmpty {
        let alert = UIAlertController(title: "No Items Selected", message: "Please select items before proceeding to checkout.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return
    }

    print("Proceeding to checkout with:", selectedProducts)
    // You can add segue or transition to checkout screen here
}
}

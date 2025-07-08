//
//  EventProductsVC.swift
//  aha-mobile
//
//  Created by Matthew Soh on 7/6/25.
//

import UIKit

class EventProductsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var products: [Product] = []
    var eventCode: String?
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = """
        \(product.name)
        Price: $\(product.price)
        \(product.description)
        In stock: \(product.quantity)
        """
        return cell
    }
    
    func loadProducts() async {
        guard let eventCode = eventCode else {
            print("❌ No event code provided.")
            return
        }
        do {
            products = try await APIService.fetchProducts(for: eventCode)
            tableView.reloadData()
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            await loadProducts()
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

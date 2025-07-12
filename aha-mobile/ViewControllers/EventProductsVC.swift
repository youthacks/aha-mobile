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
    var refreshTimer: Timer?
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductTableViewCell else {
            fatalError("Unable to dequeue ProductTableViewCell")
        }

        let product = products[indexPath.row]
        print(product, cell)
        cell.nameLabel.text = product.name
        cell.priceLabel.text = String(product.price)    
        cell.descriptionLabel.text = product.description
        if product.quantity == 0 {
            cell.backgroundColor = .systemRed
        } else {
            cell.backgroundColor = .white
        }
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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

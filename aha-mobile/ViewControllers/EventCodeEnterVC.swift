//
//  EventCodeVC.swift
//  aha-mobile
//
//  Created by Matthew Soh on 7/6/25.
//

import Foundation
import UIKit

class EventCodeEnterVC: UIViewController {
    
    @IBOutlet weak var eventCodeTextField: UITextField!
    private var fetchedProducts: [Product] = []
    private var validEventCode: String?
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        guard let code = eventCodeTextField.text?.trimmingCharacters(in: .whitespaces), !code.isEmpty else {
            showAlert(title: "Missing Code", message: "Please enter an event code before continuing.")
            return
        }

        Task {
            do {
                print("Checking event code: \(code)")
                let event = try await APIService.fetchEvent(for: code)
                print("✅ Event response: \(event)")

                let products = try await APIService.fetchProducts(for: code)
                guard !products.isEmpty else {
                    print("❌ No products returned, not performing segue")
                    return
                }

                self.fetchedProducts = products
                self.validEventCode = code
                await MainActor.run {
                    self.performSegue(withIdentifier: "showEventProducts", sender: sender)
                }
            } catch {
                print("❌ Caught error in continueButtonTapped: \(error)")
                self.validEventCode = nil
                self.fetchedProducts = []
                await MainActor.run {
                    self.showAlert(title: "Invalid Code", message: "Unable to find event. Please check your code and try again.")
                }
            }
        }
    }
    
    @IBAction func unwindToFirstVC(_ segue: UIStoryboardSegue) {
        // You can leave this empty, it's just a target for the unwind
        self.validEventCode = nil
        self.fetchedProducts = []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventProducts",
           let destination = segue.destination as? EventProductsVC,
           let code = validEventCode {
            destination.eventCode = code
            destination.products = fetchedProducts
        }
    }

    private func showAlert(title: String, message: String) {
        guard isViewLoaded, view.window != nil else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showEventProducts" {
            return validEventCode != nil && !fetchedProducts.isEmpty
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validEventCode = nil
    }
}

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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showEventProducts" {
            print(eventCodeTextField.text)
            if (eventCodeTextField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty {
                showAlert(title: "Missing Code", message: "Please enter an event code before continuing.")
                return false
            }

            // Try to validate the event code asynchronously
            Task {
                let success = await self.validateEventCode()
                if success {
                    self.performSegue(withIdentifier: identifier, sender: sender)
                }
            }

            return false // Cancel original segue; proceed only if validation passes
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventProducts",
           let destination = segue.destination as? EventProductsVC {
            destination.eventCode = eventCodeTextField.text ?? ""
        }
    }

    private func validateEventCode() async -> Bool {
        guard let code = eventCodeTextField.text?.trimmingCharacters(in: .whitespaces), !code.isEmpty else {
            return false
        }
        do {
            _ = try await APIService.fetchEvent(for: code)
            return true
        } catch {
            await MainActor.run {
                self.showAlert(title: "Invalid Code", message: "The event code entered is invalid. Please try again.")
            }
            return false
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

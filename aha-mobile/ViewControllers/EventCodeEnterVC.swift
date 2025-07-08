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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEventProducts",
           let destination = segue.destination as? EventProductsVC {
            destination.eventCode = eventCodeTextField.text ?? ""
        }
    }
}

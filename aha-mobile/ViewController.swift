import UIKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tokensToAddTextField: UITextField!  // Added input field
    
    var nfcSession: NFCNDEFReaderSession?
    
    var currentBalance: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.balanceLabel.text = "Balance: \(self.currentBalance) tokens"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.layer.cornerRadius = 10
        balanceLabel.text = "Balance: --"
        tokensToAddTextField.keyboardType = .numberPad
        tokensToAddTextField.placeholder = "Tokens to add"
    }
    
    @IBAction func scanButtonTapped(_ sender: UIButton) {
        print("Scan button tapped")
        statusLabel.text = "📡 Scanning tag..."
        startReadSession()
    }
    
    @IBAction func writeButtonTapped(_ sender: UIButton) {
        print("Write button tapped")
        statusLabel.text = "📡 Writing updated balance..."
        startWriteSession()
    }
    
    func getTokensToAdd() -> Int {
        let minTokens = 1
        let maxTokens = 100  // example max
        
        if let text = tokensToAddTextField.text,
           let value = Int(text),
           value >= minTokens && value <= maxTokens {
            print("Tokens to add: \(value)")
            return value
        }
        print("Invalid input or out of range, defaulting to \(minTokens)")
        return minTokens
    }
    
    func startReadSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC not available on this device")
            statusLabel.text = "❌ NFC not available."
            return
        }
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the tag to read balance."
        nfcSession?.begin()
        print("NFC Read session started")
    }
    
    func startWriteSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            print("NFC not available on this device")
            statusLabel.text = "❌ NFC not available."
            return
        }
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold your iPhone near the tag to update balance."
        nfcSession?.begin()
        print("NFC Write session started")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Required by protocol, but logic handled in didDetect tags
        print("didDetectNDEFs called - no action taken")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag detected.")
            print("No tag detected")
            return
        }
        print("Tag detected, connecting...")
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection error: \(error.localizedDescription)")
                print("Connection error: \(error.localizedDescription)")
                return
            }
            print("Connected to tag")
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("Detected NDER messages (required method)")
    }
    

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var scanButton: UIButton!
    
    var nfcSession: NFCNDEFReaderSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.layer.cornerRadius = 10
    }
    
    @IBAction func scanButtonTapped(_ sender: UIButton) {
        statusLabel.text = "📡 Hold iPhone near the tag to write."
        startWriteSession()
    }
    
    func startWriteSession() {
        guard NFCNDEFReaderSession.readingAvailable else {
            statusLabel.text = "❌ NFC not available on this device."
            return
        }
        
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag to write the loyalty token."
        nfcSession?.begin()
    }
    
    // Delegate: Called when tags are detected
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tags found.")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            tag.queryNDEFStatus { status, capacity, error in
                if let error = error {
                    session.invalidate(errorMessage: "NDEF status error: \(error.localizedDescription)")
                    print("NDEF status error: \(error.localizedDescription)")

                    return
                }
                
                switch status {
                case .notSupported:
                    session.invalidate(errorMessage: "Tag does not support NDEF.")
                    print("Tag not supported")
                case .readOnly:
                    session.invalidate(errorMessage: "Tag is read-only.")
                    print("Tag is read-only")
                case .readWrite:
                    print("Tag is read-write. Reading NDEF...")
                    tag.readNDEF { message, error in
                        if let error = error {
                            print("Read error: \(error.localizedDescription), initializing tag with balance 1")
                            self.writeBalance(tag: tag, session: session, balance: 1)
                            return
                        }
                        
                        var balance: Int?
                        
                        if let message = message, !message.records.isEmpty,
                           let record = message.records.first {
                            let payload = record.payload
                            let languageCodeLength = Int(payload.first ?? 3) & 0x3F
                            let jsonData = payload.dropFirst(1 + languageCodeLength)
                            
                            if let json = try? JSONSerialization.jsonObject(with: Data(jsonData)) as? [String: Any],
                               let existingBalance = json["balance"] as? Int {
                                balance = existingBalance
                                print("Read balance: \(existingBalance)")
                            }
                        }
                        
                        let current = balance ?? 0
                        let tokensToAdd = self.getTokensToAdd()
                        let updatedBalance = current + tokensToAdd
                        print("Updating balance to \(updatedBalance)")
                        
                        self.writeBalance(tag: tag, session: session, balance: updatedBalance)
                    }
                @unknown default:
                    session.invalidate(errorMessage: "Unknown NDEF status.")
                    print("Unknown NDEF status")
                case .readOnly:
                    session.invalidate(errorMessage: "Tag is read-only.")
                case .readWrite:
                    // Prepare the JSON payload as NDEF Text Record
                    let jsonString = "{\"loyalty_id\":\"TOKEN123\"}"
                    guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: jsonString, locale: Locale(identifier: "en")) else {
                        session.invalidate(errorMessage: "Failed to create payload.")
                        return
                    }
                    let message = NFCNDEFMessage(records: [payload])
                    
                    // Write to the tag
                    tag.writeNDEF(message) { error in
                        if let error = error {
                            session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                        } else {
                            session.alertMessage = "✅ Successfully wrote loyalty token!"
                            session.invalidate()
                            DispatchQueue.main.async {
                                self.statusLabel.text = "✅ Successfully wrote loyalty token!"
                            }
                        }
                    }
                @unknown default:
                    session.invalidate(errorMessage: "Unknown NDEF status.")
                }
            }
        }
    }
    

    // Delegate: Called if the session invalidates (e.g. error, user cancel)
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.statusLabel.text = "❌ \(error.localizedDescription)"
        }
        print("Session invalidated with error: \(error.localizedDescription)")
    }
    
    private func writeBalance(tag: NFCNDEFTag, session: NFCNDEFReaderSession, balance: Int) {
        let jsonString = "{\"balance\":\(balance)}"
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: jsonString, locale: Locale(identifier: "en")) else {
            session.invalidate(errorMessage: "Failed to create payload.")
            print("Failed to create NDEF payload")
            return
        }
        let messageToWrite = NFCNDEFMessage(records: [payload])
        print("Writing balance \(balance) to tag...")
        
        tag.writeNDEF(messageToWrite) { error in
            if let error = error {
                session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                print("Write failed: \(error.localizedDescription)")
            } else {
                self.currentBalance = balance
                session.alertMessage = "✅ Balance updated to \(balance)"
                session.invalidate()
                DispatchQueue.main.async {
                    self.statusLabel.text = "✅ Balance updated to \(balance)"
                }
                print("Write successful, balance updated to \(balance)")
            }
        }

    }
}

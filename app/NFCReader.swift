import Foundation
import CoreNFC

struct NFCInfo {
    var uid: String
    var type: String
    var detail: String
}

class NFCReader: NSObject, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    var onTagRead: ((NFCInfo) -> Void)?

    func beginScanning() {
        guard NFCTagReaderSession.readingAvailable else {
            print("nfc not available")
            return
        }

        session = NFCTagReaderSession(
            pollingOption: [.iso14443, .iso15693, .iso18092],
            delegate: self
        )

        session?.alertMessage = "hold your iphone near the tag"
        session?.begin()
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("session ended: \(error.localizedDescription)")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }

            var info = NFCInfo(uid: "unknown", type: "unknown", detail: "")

            switch tag {

            case .miFare(let mifare):
                info.uid = mifare.identifier.map { String(format: "%02X", $0) }.joined()
                info.type = "MiFare / ISO14443"
                info.detail = "common contactless card"

            case .iso15693(let iso15693):
                info.uid = iso15693.identifier.map { String(format: "%02X", $0) }.joined()
                info.type = "ISO15693"
                info.detail = "long range nfc tag"

            case .feliCa(let felica):
                info.uid = felica.currentIDm.map { String(format: "%02X", $0) }.joined()
                info.type = "FeliCa"
                info.detail = "sony system"

            case .iso7816(let iso7816):
                info.uid = iso7816.identifier.map { String(format: "%02X", $0) }.joined()
                info.type = "ISO7816"
                info.detail = "secure smartcard"

            @unknown default:
                info.type = "unknown"
                info.detail = "unsupported tag"
            }

            DispatchQueue.main.async {
                self.onTagRead?(info)
            }

            session.invalidate()
        }
    }
}
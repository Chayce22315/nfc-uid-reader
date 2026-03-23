import SwiftUI

struct ContentView: View {
    @State private var uid = "no scan yet"
    @State private var type = "-"
    @State private var detail = "-"

    let reader = NFCReader()

    var body: some View {
        VStack(spacing: 25) {

            Text("📡 NFC Scanner")
                .font(.largeTitle)

            VStack {
                Text("UID")
                Text(uid)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }

            VStack {
                Text("Type")
                Text(type)
            }

            VStack {
                Text("Info")
                Text(detail)
            }

            Button("scan card") {
                reader.onTagRead = { info in
                    uid = info.uid
                    type = info.type
                    detail = info.detail
                }
                reader.beginScanning()
            }
        }
        .padding()
    }
}
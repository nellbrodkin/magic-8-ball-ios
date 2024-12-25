//
//  ContentView.swift
//  Magic8Ball
//
//  Created by nell on 12/24/24.
//

import SwiftUI

struct ContentView: View {
    @State private var eightBallMessage = "8" // Initial message
    private let responses: [String] = loadResponses()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Background color

            Circle()
                .fill(Color.black)
                .frame(width: 400, height: 400)

            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
            
            if eightBallMessage == "8" {
                Text(eightBallMessage)
                    .font(.custom("Helvetica", size: 150))
            } else {
                GeometryReader { geometry in
                    Text(eightBallMessage)
                        .font(.custom("Helvetica", size: geometry.size.width * 0.3))
                        .minimumScaleFactor(0.5)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 150, height: 150) // Match the inner white circle size
            }
        }
        .background(
            ShakeDetectionView {
                eightBallMessage = responses.randomElement() ?? "Error"
            }
        )
    }
}

func loadResponses() -> [String] {
    guard let url = Bundle.main.url(forResource: "responses", withExtension: "json") else {
        print("responses.json not found in bundle")
        return []
    }
    
    do {
        let data = try Data(contentsOf: url)
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: [String]],
           let responses = json["responses"] {
            return responses
        }
    } catch {
        print("Error parsing JSON: \(error.localizedDescription)")
    }
    
    return []
}

struct ShakeDetectionView: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let controller = ShakeViewController()
        controller.shakeHandler = onShake
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
}

class ShakeViewController: UIViewController {
    var shakeHandler: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeHandler?()
        }
    }
}

#Preview {
    ContentView()
}

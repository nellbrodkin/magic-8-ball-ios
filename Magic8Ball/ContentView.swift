//
//  ContentView.swift
//  Magic8Ball
//
//  Created by nell on 12/24/24.
//

import SwiftUI

struct ContentView: View {
    @State private var eightBallMessage = "8" // Initial message

    var body: some View {
        ZStack {
            Color.white // Background color
                .ignoresSafeArea()

            Circle()
                .fill(Color.black)
                .frame(width: 400, height: 400)

            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
            
            if (eightBallMessage == "8") {
                Text(eightBallMessage)
                    .font(.custom("Helvetica", size: 150))

            } else {
                GeometryReader { geometry in
                    Text(eightBallMessage)
                        .font(.custom("Helvetica", size: geometry.size.width * 0.3))
                        .minimumScaleFactor(0.5) // Scale text down if necessary
    //                    .lineLimit(1)  Ensure it stays on one line
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 150, height: 150) // Match the inner white circle size
            }
           
        }
        .background(
            ShakeDetectionView { newMessage in
                eightBallMessage = newMessage // Update the message on shake
            }
        )
    }
}

struct ShakeDetectionView: UIViewControllerRepresentable {
    var onShake: (String) -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let controller = ShakeViewController()
        controller.shakeHandler = {
            fetchMagic8BallResponse { response in
                if let response = response {
                    onShake(response) // Pass the response to the ContentView
                }
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}

    func fetchMagic8BallResponse(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://eightballapi.com/api") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let reply = json["reading"] as? String {
                    completion(reply) // Pass the message to the completion handler
                } else {
                    completion(nil)
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}

class ShakeViewController: UIViewController {
    var shakeHandler: (() -> Void)?

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeHandler?() // Call the shake handler
        }
    }
}

#Preview {
    ContentView()
}

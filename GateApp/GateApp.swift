//
//  GateApp.swift
//  GateApp
//
//  Created by Kevin Barnes on 12/4/22.
//

import Intents
import SwiftUI

@main
struct GateApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { phase in
                    INPreferences.requestSiriAuthorization({ status in
                        // Handle errors here
                    })
                }
        }
    }
}

/// Send a command to the cloud.
/// - `command`: The command to send
/// - `argument`: An argument to send with the command
func sendCommand(command: String, argument: String) async {
    let url = URL(string: "https://api.particle.io/v1/devices/events")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue(GateAppViewModel.shared.authorizationHeader, forHTTPHeaderField: "Authorization")
    
    let parameters: [String: Any] = [
        "name": command,
        "data": argument
    ]
    request.httpBody = parameters.percentEncoded()
    
    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "Unable to unwrap data response.")
    } catch {
        print(error.localizedDescription)
    }
}

//
//  ChangeGateStatusIntentHandler.swift
//  GateIntents
//
//  Created by Kevin Barnes on 12/29/22.
//

import Foundation
import Intents

class ChangeGateStatusIntentHandler: INExtension, ChangeGateStatusIntentHandling {
    
    @MainActor func handle(intent: ChangeGateStatusIntent, completion: @escaping (ChangeGateStatusIntentResponse) -> Void) {
        var response: ChangeGateStatusIntentResponse
        switch (intent.gate) {
        case .unknown:
            response = ChangeGateStatusIntentResponse(code: .failure, userActivity: nil)
        case .main:
            Task {
                await sendCommand(
                    command: "main_gate_relay_1",
                    argument: "1\(intent.status == 0 ? "off" : "on")"
                )
            }
            response = ChangeGateStatusIntentResponse(code: .success, userActivity: nil)
            response.status = intent.status
            response.gate = intent.gate
        case .clubhouse:
            Task {
                await sendCommand(
                    command: "clubhouse_gate_relay_1",
                    argument: "1\(intent.status == 0 ? "off" : "on")"
                )
            }
            response = ChangeGateStatusIntentResponse(code: .success, userActivity: nil)
            response.status = intent.status
            response.gate = intent.gate
        }
        completion(response)
    }
    
    func resolveGate(for intent: ChangeGateStatusIntent, with completion: @escaping (GateResolutionResult) -> Void) {
        var result: GateResolutionResult
        if intent.gate != .unknown {
            result = GateResolutionResult.success(with: intent.gate)
        } else {
            result = GateResolutionResult.needsValue()
        }
        completion(result)
    }
    
    func resolveStatus(for intent: ChangeGateStatusIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        var result: INBooleanResolutionResult
        if let bool = intent.status {
            result = INBooleanResolutionResult.success(with: bool != 0)
        } else {
            result = INBooleanResolutionResult.needsValue()
        }
        completion(result)
    }
    
    /// Send a command to the cloud.
    /// - `command`: The command to send
    /// - `argument`: An argument to send with the command
    func sendCommand(command: String, argument: String) async {
        let url = URL(string: "https://api.particle.io/v1/devices/events")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(UserDefaults(suiteName: "group.gateapp")?.string(forKey: "authorizationHeader"), forHTTPHeaderField: "Authorization")
        
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
}

//
//  GateViewModel.swift
//  GateApp
//
//  Created by Kevin Barnes on 12/4/22.
//

import Foundation

class GateAppViewModel: ObservableObject {
    
    static let shared = GateAppViewModel()
    
    @Published var authorizationHeader: String = UserDefaults.standard.string(forKey: "authorizationHeader") ?? ""
    
    @Published var mainGate: GateModel
    @Published var clubhouseGate: GateModel
    @Published var testGate: GateModel
    
    init() {
        self.mainGate = GateModel(
            displayName: "Main Gate",
            commandName: "main_gate_relay_1",
            status: .unknown,
            skipCounter: 0
        )
        self.clubhouseGate = GateModel(
            displayName: "Clubhouse Gate",
            commandName: "clubhouse_gate_relay_1",
            status: .unknown,
            skipCounter: 0
        )
        self.testGate = GateModel(
            displayName: "Test Gate",
            commandName: "gatetest_relay_1",
            status: .unknown,
            skipCounter: 0
        )
    }
}

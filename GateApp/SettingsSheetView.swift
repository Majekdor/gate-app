//
//  SettingsSheetView.swift
//  GateApp
//
//  Created by Kevin Barnes on 12/4/22.
//

import SwiftUI

struct SettingsSheetView: View {
    
    @EnvironmentObject private var gateAppViewModel: GateAppViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Authorization ID:")
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                TextField(
                    "ID",
                    text: Binding(
                        get: {
                            self.gateAppViewModel.authorizationHeader
                        },
                        set: { newValue in
                            self.gateAppViewModel.authorizationHeader = newValue
                            UserDefaults(suiteName: "group.gateapp")?.set(newValue, forKey: "authorizationHeader")
                        }
                    )
                )
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("Settings")
        }
    }
}

struct SettingsSheetView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSheetView()
            .environmentObject(GateAppViewModel.shared)
    }
}

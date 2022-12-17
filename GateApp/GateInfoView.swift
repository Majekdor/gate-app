//
//  GateInfoView.swift
//  GateApp
//
//  Created by Kevin Barnes on 12/4/22.
//

import SwiftUI

struct GateInfoView: View {
    
    @Binding var gate: GateModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(gate.displayName)
                .font(.title)
                .fontWeight(.heavy)
            
            HStack {
                Text("Status: ")
                
                Text(self.gate.status.status())
                    .foregroundColor(self.gate.status.color())
                    .fontWeight(.bold)
                    .underline()
            }
            
            HStack {
                Button(action: {
                    // haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    // open the gate
                    Task {
                        await sendCommand(
                            command: self.gate.commandName,
                            argument: "1on"
                        )
                    }
                }, label: {
                    Text("Open")
                        .font(.title3)
                        .frame(width: 80, height: 25)
                })
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                
                Button(action: {
                    // haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    // close the gate
                    Task {
                        await sendCommand(
                            command: self.gate.commandName,
                            argument: "1off"
                        )
                    }
                }, label: {
                    Text("Close")
                        .font(.title3)
                        .frame(width: 80, height: 25)
                })
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
            }
            
            HStack {
                Text("Skip Counter:")
                
                Text("\(self.gate.skipCounter)")
                    .fontWeight(.bold)
            }
        }
    }
}

struct GateInfoView_Previews: PreviewProvider {
    static var previews: some View {
        GateInfoView(
            gate: .constant(
                GateModel(
                    displayName: "Main Gate",
                    commandName: "",
                    status: .unknown,
                    skipCounter: 0
                )
            )
        )
    }
}

//
//  ContentView.swift
//  GateApp
//
//  Created by Kevin Barnes on 12/4/22.
//

import EventSource
import Foundation
import SwiftUI

struct ContentView: View {
    
    @StateObject private var gateAppViewModel: GateAppViewModel = GateAppViewModel.shared
    
    @State private var showSettingsSheet: Bool = false
    
    @State private var eventSource: EventSource? = nil
    @State private var currentId: String? = nil
    @State private var skips: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    Divider()
                        .padding()
                    
                    GateInfoView(gate: self.$gateAppViewModel.mainGate)
                    
                    Divider()
                        .padding()
                }
                
                Group {
                    GateInfoView(gate: self.$gateAppViewModel.clubhouseGate)
                    
                    Divider()
                        .padding()
                }
                
                #if DEBUG
                
                Group {
                    GateInfoView(gate: self.$gateAppViewModel.testGate)
                    
                    Divider()
                        .padding()
                }
                
                #endif
                
                Group {
                    Text("Skip Control")
                        .font(.title)
                        .fontWeight(.heavy)
                    
                    HStack(spacing: 15) {
                        TextField("Skips", text: self.$skips)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 60)
                        
                        Button(
                            action: {
                                Task {
                                    await sendCommand(
                                        command: "skipcommand",
                                        argument: self.skips
                                    )
                                }
                            },
                            label: {
                                Text("Send")
                                    .font(.title3)
                            }
                        )
                        .buttonStyle(.borderedProminent)
                        .tint(.accentColor)
                    }
                    
                    Divider()
                        .padding()
                }
                
                Text("Update Status")
                    .font(.title)
                    .fontWeight(.heavy)
                
                Button(action: {
                    // haptic feedback
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    Task {
                        await self.openConnection()
                        if eventSource != nil {
                            await sendCommand(command: "getstate", argument: "")
                        }
                    }
                }, label: {
                    Text("Update")
                        .font(.title3)
                })
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .padding(.bottom, 50)
            }
            .navigationTitle("Gate Control")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showSettingsSheet.toggle()
                    }, label: {
                        Image(systemName: "gear")
                    })
                    .tint(.accentColor)
                }
            }
            .sheet(isPresented: self.$showSettingsSheet) {
                SettingsSheetView()
                    .environmentObject(self.gateAppViewModel)
                    .presentationDetents([.medium, .large])
            }
        }
        .onAppear {
            Task {
                await self.openConnection()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    /// Open a connection to the cloud to receive server sent events regarding each gate's status.
    func openConnection() async {
        if self.eventSource != nil || self.gateAppViewModel.authorizationHeader.isEmpty {
            return
        }
        
        let url = URL(string: "https://api.particle.io/v1/devices/events")!
        
        eventSource = EventSource(url: url, headers: ["Authorization" : self.gateAppViewModel.authorizationHeader])
        eventSource?.connect()

        eventSource?.onComplete({ (statusCode, reconnect, error) in
            eventSource?.connect(lastEventId: currentId);
        })

        eventSource?.onOpen {
            print("Event sourced opened!")
            
            Task {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue(self.gateAppViewModel.authorizationHeader, forHTTPHeaderField: "Authorization")
                
                request.httpBody = "name=getstate".data(using: .utf8)
                
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    print(String(data: data, encoding: .utf8) ?? "Unable to unwrap data response.")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }

        eventSource?.addEventListener("main_gate_1") { (id, event, data) in
            processedReceivedData(gate: &self.gateAppViewModel.mainGate, data: data)
        }
        
        eventSource?.addEventListener("clubhouse_gate_1") { (id, event, data) in
            processedReceivedData(gate: &self.gateAppViewModel.clubhouseGate, data: data)
        }
        
        #if DEBUG
        
        eventSource?.addEventListener("gatetest_1") { (id, event, data) in
            processedReceivedData(gate: &self.gateAppViewModel.testGate, data: data)
        }
        
        #endif
    }

    /// Process data received in an event listener.
    /// - `gate`: The gate that should be updated based on the data.
    /// - `data`: The data that was recevied.
    func processedReceivedData(gate: inout GateModel, data: String?) {
        guard let dataString = data else {
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: dataString.data(using: .utf8)!) as! [String : Any]
            let status = jsonObject["data"] ?? "not found"

            print("Status: \(status)")
            guard let statusString = status as? String else {
                return
            }
            
            if statusString.contains("ON") {
                gate.status = .open
                if statusString.count > 2 {
                    let numChar: Character = statusString[statusString.index(statusString.startIndex, offsetBy: 3)]
                    if let skipCounter = Int(String(numChar)) {
                        gate.skipCounter = skipCounter
                    }
                }
            } else if statusString.contains("OFF") {
                gate.status = .closed
                if statusString.count > 3 {
                    let numChar: Character = statusString[statusString.index(statusString.startIndex, offsetBy: 4)]
                    print(numChar)
                    if let skipCounter = Int(String(numChar)) {
                        gate.skipCounter = skipCounter
                    }
                }
            } else {
                gate.status = .unknown
            }
            
            // haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

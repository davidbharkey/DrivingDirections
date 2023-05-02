//
//  ContentView.swift
//  DrivingDirections
//
//  Created by David Harkey on 12/27/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var from: String = ""
    @State private var to: String = ""
    
    @StateObject private var vm = DirectionsViewModel()
    
    func directionsIcon(_ instruction: String) -> String {
        if instruction.contains("right") {
            return "arrow.turn.up.right"
        } else if instruction.contains("left") {
            return "arrow.turn.up.left"
        } else if instruction.contains("destination") {
            return "mappin.circle.fill"
        } else {
            return "arrow.up"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 0) {
                    
                    TextField("Choose starting location", text: $from)
                        .overlay(
                            Button("Sample") {
                                from = "New York, NY"
                            }.padding(.leading, 285)
                        )
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .padding(.bottom, 5)

                    TextField("Choose destination", text: $to)
                        .overlay(
                            Button("Sample") {
                                to = "Washington, DC"
                            }.padding(.leading, 285)
                        )
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Spacer()
                        Button("Search") {
                            Task {
                                await vm.calculateDirections(from: from, to: to)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(from.isEmpty || to.isEmpty)
                        
                        Button("Reset") {
                            to = ""
                            from = ""
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                }
                
                if !from.isEmpty && !to.isEmpty {
                    List(vm.steps, id: \.self) { step in
                        if !step.instructions.isEmpty {
                            HStack {
                                Image(systemName: directionsIcon(step.instructions))
                                Text(step.instructions)
                            }
                        }
                    }

                }
                Spacer()
                Text("Duration: \(vm.eta)")
                Text("Distance: \(vm.distance)")
            }
            .navigationTitle("Directions")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

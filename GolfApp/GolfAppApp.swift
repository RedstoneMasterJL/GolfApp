//
//  GolfAppApp.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import SwiftData
import MapKit

@main
struct GolfAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State var currentHole = 1
    
    @State var hole: Hole
    
    init() {
        self.hole = holes[0] // First hole
    }
    
    var body: some Scene {
        WindowGroup {
            HoleMapView(hole: $hole)
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                currentHole -= 1
                                hole = holes[currentHole-1]
                            }
                        }, label: {
                            Image(systemName: "arrow.left")
                        }).buttonStyle(.borderedProminent)
                        Spacer()
                        Button(action: {
                            withAnimation{
                                currentHole += 1
                                hole = holes[currentHole-1]
                            }
                        }, label: {
                            Image(systemName: "arrow.right")
                        }).buttonStyle(.borderedProminent)
                    }.padding()//.background(.green)
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.white.opacity(0.6)).frame(width: 60, height: 60)
                            Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                        }
                        Spacer()
                    }.padding()
                    
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

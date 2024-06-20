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
    
    var body: some Scene {
        WindowGroup {
            HoleMapView(hole: .constant(holes[currentHole-1]))
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Button(action: {currentHole -= 1}, label: {
                            Text("- 1")
                        })
                        Button(action: {currentHole += 1}, label: {
                            Text("+ 1")
                        })
                        Text("Current: \(currentHole)")
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

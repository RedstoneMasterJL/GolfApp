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
            Hole.self,
            Course.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            //DragHolesView()
            //HoleView(holes: toHoleDataArray(holes: albatross18holes))
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}

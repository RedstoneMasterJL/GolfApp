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
    var body: some Scene {
        WindowGroup {
            DragHolesView()
            HoleView(holes: albatross18holes)
            //HomeView()
        }
    }
}

//
//  HomeView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-25.
//

import SwiftUI
import MapKit


struct HomeView: View {
    @State private var showNewCourse = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Välkommen!")
                Button {
                    
                    showNewCourse = true
                    
                } label: {
                    Text("Ny bana")
                }
            }
        }
        .overlay {
            if showNewCourse {
                withAnimation { SearchableMap() }
            }
        }
        
    }
}

#Preview {
    HomeView()
}

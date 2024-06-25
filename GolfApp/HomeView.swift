//
//  HomeView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-25.
//

import SwiftUI
import MapKit


struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Välkommen!")
                NavigationLink {
                    
                    //FindCourseView()
                    SearchableMap()
                } label: {
                    Text("Ny bana")
                }
                
                
            }

        }
        
    }
}

#Preview {
    SearchableMap()
}

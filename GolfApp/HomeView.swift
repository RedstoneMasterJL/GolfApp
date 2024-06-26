//
//  HomeView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-25.
//

import SwiftUI
import MapKit
import SwiftData

struct HomeView: View {
    @State private var showNewCourse = false

    @Query var courses: [Course]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Välkommen!")
                
                ForEach(courses) { course in
                    HStack {
                        Text(course.name)
                        NavigationLink("Gå", destination: HoleView(holes: toHoleDataArray(holes: course.holes)))
                    }
                }
                
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

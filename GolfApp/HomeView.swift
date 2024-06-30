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
    
    @State var showDragHolesView = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Välkommen!")
                
                ForEach(courses) { course in
                    HStack {
                        Text(course.name)
                        NavigationLink("Gå", destination: HoleView(holes: course.holes.toHoleData()))
                        NavigationLink("Redigera", destination: DragHolesView(course.name, course.holes.toHoleData()) { holeDataArray, name in
                            course.holes = holeDataArray.toHoles()
                            course.name = name
                        })
                    }
                }
                NavigationLink("ny") {
                    SearchableMap(showDragHolesView: $showDragHolesView).navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

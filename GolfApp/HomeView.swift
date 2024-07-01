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
                ScrollView {
                    VStack {
                        ForEach(courses) { course in
                            CourseCard(course: course)
                                .padding()
                        }
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
    let schema = Schema([
        Hole.self,
        Course.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    let container: ModelContainer
    do {
        try container = ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Couldnt create modelcontainer")
    }

    return CourseCard(course: Course(name: "Albatross GK", holes: albatross18holes))
        .modelContainer(container)
}

struct CourseCard: View {
    @Bindable var course: Course
    @FocusState var isEditing
    @State var showEditView = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                TextField(course.name, text: $course.name)
                    .font(.headline)
                    .padding(.top, 5)
                    .focused($isEditing)
                    .allowsHitTesting(isEditing) // ! - https://tinyurl.com/45ya3n8n
                
                Spacer()

                Text("\(course.holes.count) hål") //ska vara course.holes.count
                //Text("18 hål")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                
            }//.background(.blue)
            Spacer()
            NavigationLink(destination: HoleView(holes: course.holes.toHoleData())) {
            Text("Spela").foregroundStyle(.blue)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 20).foregroundStyle(.blue.secondary)
                }
            }
            Menu {
                Button("Byt namn") {
                    isEditing.toggle()
                }
               
                Button("Redigera bana", systemImage: "pencil") {
                    showEditView.toggle()
                }
            } label: {
                Image(systemName: "ellipsis").foregroundStyle(.secondary)
            }.padding(.leading)

        }//.background(.red)
        .padding()
        .rectBg(expandable: true)
        
        .sheet(isPresented: $showEditView, content: {
            DragHolesView(course.name, course.holes.toHoleData()) { holeDataArray, name in
                course.holes = holeDataArray.toHoles()
                course.name = name
            }.interactiveDismissDisabled()
        })
    }
}

/*NavigationLink("Gå", destination: HoleView(holes: course.holes.toHoleData()))
NavigationLink("Redigera", destination: DragHolesView(course.name, course.holes.toHoleData()) { holeDataArray, name in
    course.holes = holeDataArray.toHoles()
    course.name = name
})*/

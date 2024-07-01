//
//  DragHolesView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-24.
//

import SwiftUI
import MapKit

struct DragHolesView: View {
    
    @State private var position: MapCameraPosition = .automatic
    @State private var modes: MapInteractionModes = [.pan, .rotate, .zoom] // Ingen pitching, ser konstigt ut med polylinen då
    
    @State var markers: [HoleData]
    
    @State var currentHole: Int
    
    init(_ name: String, _ markers: [HoleData]? = nil, closure: @escaping ([HoleData], String) -> ()) {
        if let markers = markers {
            self.markers = markers
            currentHole = markers.count
        } else {
            self.markers = [
                HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
            ]
            currentHole = 1
        }
        self.closure = closure
        self.name = name
    }
    
    @State var showSaveSheet = false
    @State var name: String
    @Environment(\.modelContext) var moc
    @Environment(\.dismiss) var dismiss
    
    var closure: ([HoleData], String) -> ()
    
    @FocusState var isEditing
    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $position, interactionModes: modes) {
                    ForEach(0..<markers.count, id: \.self) { i in
                        Annotation(String(markers[i].num), coordinate: markers[i].greenPos) {
                            MarkerView(proxy: proxy, type: .green, coordinate: $markers[i].greenPos)
                        }
                        Annotation(String(markers[i].num), coordinate: markers[i].teePos) {
                            MarkerView(proxy: proxy, type: .tee, coordinate: $markers[i].teePos)
                        }
                        MapPolyline(coordinates: [markers[i].greenPos, markers[i].teePos])
                            .stroke(.orange, lineWidth: 2)
                    }
                    
                }.mapStyle(.imagery(elevation: .realistic))
                
                //                .safeAreaInset(edge: .top) {
                //                    HStack {
                //                        Button("Spara") { showSaveSheet.toggle() }
                //                        Divider().frame(maxHeight: 15)
                //                        Text("Antal hål satta \(currentHole)")
                //                        Button("+") {
                //                            let newHoleMarker = HoleData(num: currentHole + 1, greenPos: markers[currentHole-1].greenPos, teePos: markers[currentHole-1].greenPos)
                //                            markers.append(newHoleMarker)
                //                            currentHole += 1
                //                        }.disabled(markers.count == 18)
                //                        Button("-") {
                //                            markers.removeLast()
                //                            currentHole -= 1
                //                        }.disabled(markers.count == 1)
                //                    }.frame(maxWidth: .infinity).padding(.bottom).background(.orange.gradient)
                //                }
                
                    .safeAreaInset(edge: .top) {
                        HStack {
                            Button(action: {
                                let newHoleMarker = HoleData(num: currentHole + 1, greenPos: markers[currentHole-1].greenPos, teePos: markers[currentHole-1].greenPos)
                                markers.append(newHoleMarker)
                                currentHole += 1
                            }, label: {
                                Image(systemName: "plus")
                                    .frame(height: 15)
                                //.background(Color.red)
                                    .foregroundStyle(.white)
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .tint(Color.blue.secondary.opacity(3))
                                    }
                            }).disabled(markers.count == 18)
                            
                            Button(action: {
                                markers.removeLast()
                                currentHole -= 1
                            }, label: {
                                Image(systemName: "minus")
                                    .frame(height: 15)
                                // .background(Color.red)
                                    .foregroundStyle(.white)
                                    .padding(15)
                                    .background {
                                        RoundedRectangle(cornerRadius: 15)
                                            .tint(Color.blue.secondary.opacity(3)) // https://tinyurl.com/yrd89run
                                    }
                            }).disabled(markers.count == 1)
                            
                            Spacer()
                        }.padding()
                    }
                
            }.sheet(isPresented: $showSaveSheet, content: {
                VStack(content: {
                    TextField("Namn", text: $name)
                    Button("Spara") {
                        // let newCourse = Course(name: text, holes: toHoleArray(holeDataArray: markers))
                        //   moc.insert(newCourse)
                        closure(markers, name)
                        dismiss()
                    }
                })
            })
            
            //.navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    HStack {
                        TextField("Namn", text: $name).font(.headline)
                            .focused($isEditing)
                            .allowsHitTesting(isEditing) // ! - https://tinyurl.com/45ya3n8n
                       
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(String(currentHole)) hål").font(.subheadline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            closure(markers, name)
                            dismiss()
                        } label: {
                            Label("Spara ändringar", systemImage: "checkmark")
                        }
                        Button {
                            isEditing.toggle()
                        } label: {
                            Text("Byt namn")
                        }
                        Button("Ta bort ändringar", role: .destructive) { dismiss() }
                        
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }

                
            }
        }
    }
}

#Preview {
    DragHolesView("Eaglekorten") {_,_ in
        
    }
}

let eaglekorten = [
    
    HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
]

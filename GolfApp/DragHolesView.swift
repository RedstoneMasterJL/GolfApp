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

    init(_ markers: [HoleData]? = nil) {
        if let markers = markers {
            self.markers = markers
            currentHole = markers.count
        } else {
            self.markers = [
                HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
            ]
            currentHole = 1
        }
    }
    
    @State var showSaveSheet = false
    @State var text = ""
    @Environment(\.modelContext) var moc
    @Environment(\.dismiss) var dismiss

    var body: some View {
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
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Text("")
                            .rectBg()
                        Spacer()
                        Text("Eaglekorten")
                            .rectBg(expandable: true)
                        
                        Spacer()
                        Text("")
                            .rectBg()

                    }.frame(maxHeight: 60).padding()
                }
                .safeAreaInset(edge: .top) {
                    HStack {
                            Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                            .rectBg()
                        Spacer()
                            Text("Spara")
                            .rectBg()
                    }.frame(maxHeight: 60).padding()
                }
        }.sheet(isPresented: $showSaveSheet, content: {
            VStack(content: {
                TextField("Namn", text: $text)
                Button("Spara") {
                    let newCourse = Course(name: text, holes: toHoleArray(holeDataArray: markers))
                    moc.insert(newCourse)
                    dismiss()
                }
            })
        })
    }
}

#Preview {
    DragHolesView()
}

let eaglekorten = [

    HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
]

//
//  DragHolesView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-24.
//

import SwiftUI
import MapKit

struct DragHolesView: View {
    
    @Environment(\.modelContext) var moc
    @Environment(\.dismiss) var dismiss

    @State private var position: MapCameraPosition = .automatic
    @State private var modes: MapInteractionModes = [.pan, .rotate, .zoom] // Ingen pitching, ser konstigt ut med polylinen då
    
    @State var holes: [HoleData]
    
    @State private var currentHole: Int

    init(_ holes: [HoleData]? = nil) {
        self.holes = holes ?? [
            HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
        ]
        currentHole = holes?.count ?? 1
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position, interactionModes: modes) {
                ForEach(0..<holes.count, id: \.self) { i in
                    Annotation(String(holes[i].num), coordinate: holes[i].greenPos) {
                        MarkerView(proxy: proxy, type: .green, coordinate: $holes[i].greenPos)
                    }
                    Annotation(String(holes[i].num), coordinate: holes[i].teePos) {
                        MarkerView(proxy: proxy, type: .tee, coordinate: $holes[i].teePos)
                    }
                    MapPolyline(coordinates: [holes[i].greenPos, holes[i].teePos])
                        .stroke(.orange, lineWidth: 2)
                }
                
            }.mapStyle(.imagery(elevation: .realistic))
            
                .safeAreaInset(edge: .top) {
                    HStack {
                        Button("Spara") {
                            let newCourse = Course(name: "Test", holes: holes)
                            moc.insert(newCourse)
                            dismiss()
                        }
                        Divider().frame(maxHeight: 15)
                        Text("Nuvarande hål \(currentHole)")
                        Button("+") {
                            let newHoleMarker = HoleData(num: currentHole + 1, greenPos: holes[currentHole-1].greenPos, teePos: holes[currentHole-1].greenPos)
                            holes.append(newHoleMarker)
                            currentHole += 1
                        }.disabled(holes.count == 18)
                        Button("-") {
                            holes.removeLast()
                            currentHole -= 1
                        }.disabled(holes.count == 1)
                    }.frame(maxWidth: .infinity).padding(.bottom).background(.orange.gradient)
                }
        }
    }
}

#Preview {
    DragHolesView()
}

let eaglekorten = [

    HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
]

enum MarkerType {
    case green, tee
}

struct MarkerView: View {
    var proxy: MapProxy
    
    let type: MarkerType
    @State private var translation: CGSize = .zero
    @State private var isActive: Bool = false
    @Binding var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            
            Image(systemName: type == .green ? "flag.circle.fill" : "t.circle.fill")
                .foregroundStyle(type == .green ? .orange : .yellow)
                .animation(.snappy, body: { content in
                    content.scaleEffect(isActive ? 1.3 : 1)
                })
                .frame(width: frame.width, height: frame.height)
                .onChange(of: isActive, initial: false) { oldValue, newValue in
                    let position = CGPoint(x: frame.midX, y: frame.midY)
                    if let coordinate = proxy.convert(position, from: .global) {
                        self.coordinate = coordinate
                        translation = .zero
                    }
                }
        }
        .frame(width: 70, height: 70)
        .contentShape(.rect)
        .offset(translation)
        .gesture(
            LongPressGesture(minimumDuration: 0.10) // så att man ej råkar ta i den
                .onEnded { isActive = $0 }
                .simultaneously(with: DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if isActive { translation = value.translation }
                    }
                    .onEnded { value in
                        if isActive { isActive = false }
                    }
                )
        )
    }
}

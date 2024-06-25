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
    
    @State var currentHole = 1

    init() {
        markers = [
            HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
        ]
    }
    
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
            
                .safeAreaInset(edge: .top) {
                    HStack {
                        Text("Lägg till hål")
                        Divider().frame(maxHeight: 15)
                        Text("Nuvarande hål \(currentHole)")
                        Button("+") {
                            let newHoleMarker = HoleData(num: currentHole + 1, greenPos: markers[currentHole-1].greenPos, teePos: markers[currentHole-1].greenPos)
                            markers.append(newHoleMarker)
                            currentHole += 1
                        }.disabled(markers.count == 18)
                        Button("-") {
                            markers.removeLast()
                            currentHole -= 1
                        }.disabled(markers.count == 1)
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

@Observable
class HoleData: Identifiable, Equatable {
    static func == (lhs: HoleData, rhs: HoleData) -> Bool {
        lhs.num == rhs.num
    }
    
    let num: Int
    var greenPos: CLLocationCoordinate 2D
    var teePos: CLLocationCoordinate2D
    
   
    // Camera
    var camPos: MapCameraPosition
    
    func resetCamPos() {
        camPos = startCamPos
    }
    var camPosIsDefault: Bool {
        camPos == startCamPos
    }
    
    init(num: Int, greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        self.num = num
        self.greenPos = greenPos
        self.teePos = teePos
        self.camPos = GolfApp.startCamPos(centerPos: centerPos(greenPos: greenPos, teePos: teePos), teePos: teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: teePos, point2: greenPos))
    }
    
    private var startCamPos: MapCameraPosition {
        GolfApp.startCamPos(centerPos: centerPos(greenPos: greenPos, teePos: teePos), teePos: teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: teePos, point2: greenPos))
    }
    
    
    
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

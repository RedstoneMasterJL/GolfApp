//
//  HoleMapView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct HoleMapView: View {
    
    @Binding var hole: Hole
    let modes: MapInteractionModes = [.zoom, .pan, .pitch, .rotate]
    
    @State var coordinate: CLLocationCoordinate2D?
    var body: some View {
        MapReader { proxy in
            Map(position: $hole.startCamPos, interactionModes: modes) {
                UserAnnotation()
                Annotation("", coordinate: hole.greenPos) {
                    Circle().fill(.green)
                }
                Annotation("", coordinate: coordinate ?? hole.centerPos) {
                    DraggablePin(proxy: proxy, coordinate: $coordinate.withDefault(hole.centerPos))
                }
                Annotation("", coordinate: hole.teePos) {
                    Circle().fill(.yellow)
                }
                MapPolyline(MKPolyline(points: [MKMapPoint(hole.teePos), MKMapPoint(coordinate ?? hole.centerPos), MKMapPoint(hole.greenPos)], count: 3))
                    .stroke(.orange, lineWidth: 2)
            }.mapStyle(.imagery(elevation: .realistic))
                .mapControls { MapScaleView() }
                .onChange(of: hole) { oldValue, newValue in
                    coordinate = hole.centerPos
                }
        }
    }
}

#Preview {
    HoleMapView(hole: .constant(holes[0]))
}

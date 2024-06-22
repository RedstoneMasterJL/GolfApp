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
    // VARFÖR FUNKAR INTE MED COORDINATE I HOLE
    // TESTA MED KLAS OCH OBSERVABLE
    var body: some View {
        MapReader { proxy in
            Map(position: $hole.camPos.withDefault(hole.startCamPos), interactionModes: modes) {
                UserAnnotation()
                Annotation("", coordinate: hole.greenPos) {
                    Circle().fill(.green)
                }
                Annotation("", coordinate: hole.scopePos ?? hole.centerPos) {
                    DraggablePin(proxy: proxy, coordinate: $hole.scopePos.withDefault(hole.centerPos))
                }
                Annotation("", coordinate: hole.teePos) {
                    Circle().fill(.yellow)
                }
                MapPolyline(coordinates: [hole.teePos, hole.scopePos ?? hole.centerPos, hole.greenPos], contourStyle: .straight)
                    .stroke(.orange, lineWidth: 3)
            }.mapStyle(.imagery(elevation: .realistic))
                .mapControls { MapScaleView() }
                .onChange(of: hole) { oldValue, newValue in
                    withAnimation { hole.resetHole() }
                    print(hole.scopePos)
                }
        }
    }
}

#Preview {
    HoleMapView(hole: .constant(holes[0]))
}

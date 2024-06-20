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
    
    var body: some View {
        Map(position: Binding<MapCameraPosition>(get: {
            .camera(MapCamera(MKMapCamera(lookingAtCenter: hole.centerPos, fromEyeCoordinate: hole.teePos, eyeAltitude: hole.teeGreenDistance * 2.5)))
        }, set: { newValue in
            
        })) {
            UserAnnotation()
            Annotation("", coordinate: hole.greenPos) {
                Circle().fill(.green)
            }
            Annotation("", coordinate: hole.centerPos) {
                Image(systemName: "scope").foregroundStyle(.blue)
            }
            Annotation("", coordinate: hole.teePos) {
                Circle().fill(.yellow)
            }
        }.mapStyle(.hybrid(elevation: .realistic))
    }
}

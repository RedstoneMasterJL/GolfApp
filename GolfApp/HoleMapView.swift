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
    
    @State private var modes: MapInteractionModes = [.zoom, .pan, .pitch, .rotate]
    @State private var isMarkerDragging = false
    @Binding var markerData: MarkerData?
    
    var body: some View {
        GeometryReader { geometryProxy in
            MapReader { mapProxy in
                Map(position: $hole.camPos, interactionModes: modes) {
                    UserAnnotation()
                    Annotation("", coordinate: hole.greenPos) {
                        Circle().fill(.green)
                    }
                    if let markerData {
                        Annotation("", coordinate: markerData.coordinate) {
                            Image(systemName: "dot.scope")
                                .font(.system(size: 50))
                                .fontWeight(.thin)
                                .foregroundStyle(.orange.gradient)

                        }
                    }
                    Annotation("", coordinate: hole.teePos) {
                        Circle().fill(.yellow)
                    }
                    MapPolyline(coordinates: [hole.teePos, markerData?.coordinate ?? hole.centerPos, hole.greenPos], contourStyle: .straight)
                        .stroke(.orange, lineWidth: 3)
                }.mapStyle(.imagery(elevation: .realistic))
                    .mapControls { MapScaleView() }
                    .onChange(of: hole, initial: true) { oldValue, newValue in
                        withAnimation { hole.resetHole(); self.markerData = mapProxy.markerData(coordinate: hole.centerPos, geometryProxy: geometryProxy) }
                    }
                    .onTapGesture { screenCoordinate in
                        self.markerData = mapProxy.markerData(screenCoordinate: screenCoordinate, geometryProxy: geometryProxy)
                    }
                    .highPriorityGesture(DragGesture(minimumDistance: 1)
                        .onChanged { drag in
                            guard let markerData else { return }
                            if isMarkerDragging {
                                
                            } else if markerData.touchableRect.contains(drag.startLocation) {
                                isMarkerDragging = true
                                setMapInteraction(enabled: false)
                            } else {
                                return
                            }
                            
                            self.markerData = mapProxy.markerData(screenCoordinate: drag.location, geometryProxy: geometryProxy)
                        }
                        .onEnded { drag in
                            setMapInteraction(enabled: true)
                            isMarkerDragging = false
                        }
                    )
                    .onMapCameraChange {
                        guard let markerData else { return }
                        self.markerData = mapProxy.markerData(coordinate: markerData.coordinate, geometryProxy: geometryProxy)
                    }
            }
        }
    }
    private func setMapInteraction(enabled: Bool) {
        if enabled {
            modes = [.zoom, .pan, .pitch, .rotate]
        } else {
            modes = []
        }
    }
}

#Preview {
    HoleView(holes: albatross18holes)
}

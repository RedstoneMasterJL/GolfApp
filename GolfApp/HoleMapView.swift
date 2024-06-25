//
//  HoleMapView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct HoleMapView: View {
    
    @Binding var hole: HoleData
    
    @State private var modes: MapInteractionModes = [.zoom, .pan, .pitch, .rotate]
    @State private var isMarkerDragging = false
    @Binding var scopeData: ScopeData?
    @Binding var camPos: MapCameraPosition

    var body: some View {
        GeometryReader { geometryProxy in
            MapReader { mapProxy in
                Map(position: $camPos, interactionModes: modes) {
                    UserAnnotation()
                    Annotation("", coordinate: hole.greenPos) {
                        Circle().fill(.green)
                    }
                    if let scopeData {
                        Annotation("", coordinate: scopeData.coordinate) {
                            Image(systemName: "dot.scope")
                                .font(.system(size: 50))
                                .fontWeight(.thin)
                                .foregroundStyle(.orange.gradient)

                        }
                    }
                    Annotation("", coordinate: hole.teePos) {
                        Circle().fill(.yellow)
                    }
                    MapPolyline(coordinates: [hole.teePos, scopeData?.coordinate ?? hole.teePos, hole.greenPos], contourStyle: .straight)
                        .stroke(.orange, lineWidth: 3)
                }.mapStyle(.imagery(elevation: .realistic))
                    .mapControls { MapScaleView() }
                    .onChange(of: hole.num, initial: true) { oldValue, newValue in
                        withAnimation { 
                            resetCamPos(&camPos, to: startCamPos(centerPos: centerPos(greenPos: hole.greenPos, teePos: hole.teePos), teePos: hole.teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: hole.teePos, point2: hole.greenPos)))
                            self.scopeData = mapProxy.scopeData(coordinate: centerPos(greenPos: hole.greenPos, teePos: hole.teePos), geometryProxy: geometryProxy)
                        }
                    }
                    .onTapGesture { screenCoordinate in
                        self.scopeData = mapProxy.scopeData(screenCoordinate: screenCoordinate, geometryProxy: geometryProxy)
                    }
                    .highPriorityGesture(DragGesture(minimumDistance: 1)
                        .onChanged { drag in
                            guard let scopeData else { return }
                            if isMarkerDragging {
                                
                            } else if scopeData.touchableRect.contains(drag.startLocation) {
                                isMarkerDragging = true
                                setMapInteraction(enabled: false)
                            } else {
                                return
                            }
                            
                            self.scopeData = mapProxy.scopeData(screenCoordinate: drag.location, geometryProxy: geometryProxy)
                        }
                        .onEnded { drag in
                            setMapInteraction(enabled: true)
                            isMarkerDragging = false
                        }
                    )
                    .onMapCameraChange {
                        guard let scopeData else { return }
                        self.scopeData = mapProxy.scopeData(coordinate: scopeData.coordinate, geometryProxy: geometryProxy)
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

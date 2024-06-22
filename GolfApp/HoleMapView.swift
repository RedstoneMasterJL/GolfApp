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
    @State private var markerData: MarkerData?
    
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
    HoleMapView(hole: .constant(holes[0]))
}

private let rectWidth: Double = 80

private struct MarkerData {
    let coordinate: CLLocationCoordinate2D
    let screenPoint: CGPoint
    
    var touchableRect: CGRect {
        .init(x: screenPoint.x - rectWidth / 2, y: screenPoint.y - rectWidth / 2, width: rectWidth, height: rectWidth)
    }
}
private extension MapProxy {
    
    func markerData(screenCoordinate: CGPoint, geometryProxy: GeometryProxy) -> MarkerData? {
        guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: screenCoordinate)
    }
    
    func markerData(coordinate: CLLocationCoordinate2D, geometryProxy: GeometryProxy) -> MarkerData? {
        guard let point = convert(coordinate, to: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: point)
    }
}

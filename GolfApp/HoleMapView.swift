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
    let modes: MapInteractionModes = [.zoom, .pan, .pitch]
    
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
            }.mapStyle(.hybrid(elevation: .realistic))
                .mapControls { MapScaleView() }
                .onChange(of: hole) { oldValue, newValue in
                    coordinate = hole.centerPos
                }
        }
    }
}

struct DraggablePin: View {
    var proxy: MapProxy
    @Binding var coordinate: CLLocationCoordinate2D
    @State private var isActive = false
    @State private var translation: CGSize = .zero
    
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            
            Image(systemName: "dot.scope")
                .font(.system(size: 50))
                .fontWeight(.thin)
                .foregroundStyle(.orange.gradient)
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
            LongPressGesture(minimumDuration: 0)
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

#Preview {
    HoleMapView(hole: .constant(holes[0]))
}

//
//  MarkerData.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-23.
//

import SwiftUI
import MapKit

let rectWidth: Double = 80

struct ScopeData {
    let coordinate: CLLocationCoordinate2D
    let screenPoint: CGPoint
    
    var touchableRect: CGRect {
        .init(x: screenPoint.x - rectWidth / 2, y: screenPoint.y - rectWidth / 2, width: rectWidth, height: rectWidth)
    }
}

extension MapProxy {
    
    func scopeData(screenCoordinate: CGPoint, geometryProxy: GeometryProxy) -> ScopeData? {
        guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: screenCoordinate)
    }
    
    func scopeData(coordinate: CLLocationCoordinate2D, geometryProxy: GeometryProxy) -> ScopeData? {
        guard let point = convert(coordinate, to: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: point)
    }
}

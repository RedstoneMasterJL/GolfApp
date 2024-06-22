//
//  HoleCameraManager.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-22.
//

import SwiftUI
import MapKit

@Observable
class HoleCameraManager {
    
    var currentHole: Hole
    
    var camPos: MapCameraPosition
    
    let startCamPos: MapCameraPosition
    
    
    init(currentHole: Hole) {
        self.currentHole = currentHole
        self.startCamPos = GolfApp.cameraSetupFor(centerPos: currentHole.centerPos, teePos: currentHole.teePos, teeGreenDistance: currentHole.teeGreenDistance)
        self.camPos = startCamPos
    }
    
    func resetCamPos() {
        camPos = startCamPos
    }
}

func cameraSetupFor(centerPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D, teeGreenDistance: Double) -> MapCameraPosition {
    .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
}


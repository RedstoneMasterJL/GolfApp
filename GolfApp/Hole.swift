//
//  Hole.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-20.
//

import SwiftUI
import MapKit

struct Hole {
    let number: Int
    let greenPos: CLLocationCoordinate2D
    let teePos: CLLocationCoordinate2D
    
    // Center of fairway
    var centerPos: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: (greenPos.latitude + teePos.latitude) / 2, longitude: (greenPos.longitude + teePos.longitude) / 2)
    }
    
    // Distance tee - green
    var teeGreenDistance: Double {
        let greenLoc = CLLocation(latitude: greenPos.latitude, longitude: greenPos.longitude)
        let teeLoc = CLLocation(latitude: teePos.latitude, longitude: teePos.longitude)
        return greenLoc.distance(from: teeLoc)
    }

    var startCamPos: MapCameraPosition {
        .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
    }
}

let holes = [

    Hole(number: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775), teePos: CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)),
    Hole(number: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756)),
    Hole(number: 3, greenPos: CLLocationCoordinate2D(latitude: 57.78476, longitude: 11.94776), teePos: CLLocationCoordinate2D(latitude: 57.78260, longitude: 11.94981)),
    Hole(number: 4, greenPos: CLLocationCoordinate2D(latitude: 57.78211, longitude: 11.94611), teePos: CLLocationCoordinate2D(latitude: 57.78496, longitude: 11.94720))

]

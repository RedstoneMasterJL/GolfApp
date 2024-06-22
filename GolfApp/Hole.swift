//
//  Hole.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-20.
//

import SwiftUI
import MapKit

@Observable
class Hole: Equatable {
    static func == (lhs: Hole, rhs: Hole) -> Bool {
        lhs.number == rhs.number
    } // kanske farligt med number i framtiden
    
    let number: Int
    let greenPos: CLLocationCoordinate2D
    let teePos: CLLocationCoordinate2D
    
    var scopePos: CLLocationCoordinate2D? = nil
    var camPos: MapCameraPosition? = nil
    
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

    var teeScopeDistance: Double {
        let teeLoc = CLLocation(latitude: teePos.latitude, longitude: teePos.longitude)
        let scopeLoc = CLLocation(latitude: scopePos?.latitude ?? centerPos.latitude, longitude: scopePos?.longitude ?? centerPos.longitude)
        return teeLoc.distance(from: scopeLoc)
    }
    
    var scopeGreenDistance: Double {
        let scopeLoc = CLLocation(latitude: scopePos?.latitude ?? centerPos.latitude, longitude: scopePos?.longitude ?? centerPos.longitude)
        let greenLoc = CLLocation(latitude: greenPos.latitude, longitude: greenPos.longitude)
        return scopeLoc.distance(from: greenLoc)
    }
    
    var startCamPos: MapCameraPosition {
        get { .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5))) }
        set { }
    }
    
    func resetScopePos() {
        scopePos = centerPos
    }
    func resetCamPos() {
        camPos = startCamPos
    }
    func resetHole() {
        resetScopePos()
        resetCamPos()
        /*print("Resetted for number \(number)")
        print("New scopePos \(scopePos)")
        if scopePos?.longitude == centerPos.longitude {
            print("Scope pos is equal to centerpos")
        } else {
            print("Scope pos is NOT equal to centerpos")
        }*/
    }
    var isDefault: Bool {
        print("-----------------")
        print("Hole number \(number)")
        let centerScopeLatIsSame = centerPos.latitude == scopePos?.latitude
        print("centerScopeLatIsSame \(centerScopeLatIsSame)")
        print("Center lat: " + String(centerPos.latitude))
        print("Scope lat: " + String(scopePos?.latitude ?? 0))
        let centerScopeLongIsSame = centerPos.longitude == scopePos?.longitude
        print("centerScopeLongIsSame \(centerScopeLongIsSame)")
        let camPosStartCamPosIsSame = camPos == startCamPos
        print("camPosStartCamPosIsSame \(camPosStartCamPosIsSame)")
        print("-----------------")
        return centerScopeLatIsSame && centerScopeLongIsSame && camPosStartCamPosIsSame
    }
    
    init(number: Int, greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        self.number = number
        self.greenPos = greenPos
        self.teePos = teePos
        self.scopePos = centerPos
        self.camPos = startCamPos
    }
}

let holes = [

    Hole(number: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775), teePos: CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)),
    Hole(number: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756)),
    Hole(number: 3, greenPos: CLLocationCoordinate2D(latitude: 57.78476, longitude: 11.94776), teePos: CLLocationCoordinate2D(latitude: 57.78260, longitude: 11.94981)),
    Hole(number: 4, greenPos: CLLocationCoordinate2D(latitude: 57.78211, longitude: 11.94611), teePos: CLLocationCoordinate2D(latitude: 57.78496, longitude: 11.94720)),
    Hole(number: 5, greenPos: CLLocationCoordinate2D(latitude: 57.78102, longitude: 11.94500), teePos: CLLocationCoordinate2D(latitude: 57.78171, longitude: 11.94645))

]

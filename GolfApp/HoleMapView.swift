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
    
    /*init(holeNumber: Binding<Int>, greenPos: Binding<CLLocationCoordinate2D>, teePos: Binding<CLLocationCoordinate2D>) {
        let centerPos = CLLocationCoordinate2D(latitude: (greenPos.latitude + teePos.latitude) / 2, longitude: (greenPos.longitude + teePos.longitude) / 2)
        let greenLoc = CLLocation(latitude: greenPos.latitude, longitude: greenPos.longitude)
        let teeLoc = CLLocation(latitude: teePos.latitude, longitude: teePos.longitude)
        let teeGreenDistance = greenLoc.distance(from: teeLoc)
        print(teeGreenDistance)
        
        startCamPos = .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
        
        self.centerPos = centerPos
        self.greenPos = greenPos
        self.teePos = teePos
        self.teeGreenDistance = teeGreenDistance

    }*/
    
    
    var body: some View {
        Map(initialPosition: hole.startCamPos) {
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
        }.mapStyle(.hybrid(elevation: .realistic))/*.onAppear {
            resetStartCamPos()
        }.onChange(of: holeNumber) {
            resetStartCamPos()
        }*/
    }
    
    /*func resetStartCamPos() {
        startCamPos = .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
    }*/
}

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

//
//  HoleMapView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct HoleMapView: View {
    
    let greenPos: CLLocationCoordinate2D
    let teePos: CLLocationCoordinate2D
    let centerPos: CLLocationCoordinate2D
    
    init(greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        centerPos = CLLocationCoordinate2D(latitude: (greenPos.latitude + teePos.latitude) / 2, longitude: (greenPos.longitude + teePos.longitude) / 2)
        self.greenPos = greenPos
        self.teePos = teePos
        //startCamPos = .camera(MapCamera(centerCoordinate: centerPos, distance: 400, heading: 80, pitch: 0))
        
        let greenLoc = CLLocation(latitude: greenPos.latitude, longitude: greenPos.longitude)
        let teeLoc = CLLocation(latitude: teePos.latitude, longitude: teePos.longitude)
        //let centerLoc = CLLocation(latitude: centerPos.latitude, longitude: centerPos.longitude)
        let distance = greenLoc.distance(from: teeLoc)
        print(distance)
        
        startCamPos = .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: distance * 2.5)))
        // möjligtvis att vi ändrar distance x 2.5 på eyeAltitude
        
    }
    @State var startCamPos: MapCameraPosition
    
    var body: some View {
        Map(position: $startCamPos) {
            Annotation("", coordinate: greenPos) {
                Circle().fill(.green)
            }
            Annotation("", coordinate: centerPos) {
                Image(systemName: "scope").foregroundStyle(.blue)
            }
            Annotation("", coordinate: teePos) {
                Circle().fill(.yellow)
            }
        }.mapStyle(.imagery)
    }
}

#Preview {
    HoleMapView(greenPos: holes[3].greenPos, teePos: holes[3].teePos)
}

// ettans green CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775)
// ettans gul tee CLLocation(latitude: 57.78032, longitude: 11.95332)

/*
 mitten av fairwayt
 
 latitud green - latitud tee
 / 2
 sedan det plus teen
 
 57.78184 - 57.78032
 0.00152 / 2
 
 0,00076
 57.78032 + 0,00076
 57,78108
 
 longitud green - longitud tee
 / 2
 sedan det plus teen

 11.94775 - 11.95332
 
 −0,00557
 / 2
 
 −0,002785
 
 11.95332 +  −0,002785

 11.950535
 
 FUNKAR!
 */

struct Hole {
    let number: Int
    let greenPos: CLLocationCoordinate2D
    let teePos: CLLocationCoordinate2D
}

let holes = [

    Hole(number: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775), teePos: CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)),
    Hole(number: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756)),
    Hole(number: 3, greenPos: CLLocationCoordinate2D(latitude: 57.78476, longitude: 11.94776), teePos: CLLocationCoordinate2D(latitude: 57.78260, longitude: 11.94981)),
    Hole(number: 4, greenPos: CLLocationCoordinate2D(latitude: 57.78211, longitude: 11.94611), teePos: CLLocationCoordinate2D(latitude: 57.78496, longitude: 11.94720))

]

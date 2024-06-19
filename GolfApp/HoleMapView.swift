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
        
        start = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude:  57.78032, longitude:  11.94218),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    }
    
    @State var start: MapCameraPosition
    
    var body: some View {
        Map(position: $start) {
            Annotation("", coordinate: greenPos) {
                Circle().fill(.green)
            }
            Annotation("", coordinate: centerPos) {
                Image(systemName: "scope").foregroundStyle(.blue)
            }
            Annotation("", coordinate: teePos) {
                Circle().fill(.yellow)
            }
        }.mapStyle(.hybrid)
        .onAppear {
            var m: Double = 0
            if teePos.longitude > greenPos.longitude {
                m = (teePos.longitude-greenPos.longitude)/(teePos.latitude-greenPos.latitude)
                print(m)
            } else {
                m = (teePos.latitude-greenPos.latitude)/(teePos.longitude-greenPos.longitude)
                print(m)
            }
            setCameraHeading(heading: m * 20) //-60 funkar
            /*
             (11.95332-11.94775)/(57.78032-57.78184)
             y2 - y1 / x2 - x1
             = -3.66447368421
             1 horisontellt 0 bäring
             60/2 = 30
             borde två vara 30
             1 0
             2 30
             3 60
             4 90
             5 120
             6 150
             7 180
             8 210
             9 240
             10 270
             11 300
             12 330
             kanske??
             blir då - 20
             
             FÅR NOG HITTA ETT BÄTTRE SÄTT
             */
        }
    }
    
    func setCameraHeading(heading: CLLocationDirection) {
        var camera = MapCamera.init(centerCoordinate: centerPos, distance: start.camera?.distance ?? 2000)
        camera.heading = heading
        
        start = MapCameraPosition.camera(camera)
    }
}

#Preview {
    HoleMapView(greenPos: holes[1].greenPos, teePos: holes[1].teePos)
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
    Hole(number: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756))

]

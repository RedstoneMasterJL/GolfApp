//
//  HoleMapView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct HoleMapView: View {
    
    let middleOfGreenPosition = CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775)
    let teePosition = CLLocation(latitude: 57.78032, longitude: 11.95332)
    
    let middleFairway = CLLocationCoordinate2D(latitude:   57.78108, longitude: 11.950535)
    
    
    @State var start = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude:  57.78032, longitude:  11.94218),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

    var body: some View {
        Map(position: $start) {
            
        }.mapStyle(.hybrid)
        .onAppear {
            setCameraHeading(heading: 0) //-60 funkar
        }
    }
    
    func setCameraHeading(heading: CLLocationDirection) {
        var camera = MapCamera.init(centerCoordinate: middleFairway, distance: start.camera?.distance ?? 1000)
        camera.heading = heading
        
        start = MapCameraPosition.camera(camera)
    }
}

#Preview {
    HoleMapView()
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

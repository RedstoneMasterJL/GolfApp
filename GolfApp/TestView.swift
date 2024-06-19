//
//  TestView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct TestView: View {
    
    let middleOfGreenPosition = CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775)
    let teePosition = CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)
    let middleFairway = CLLocationCoordinate2D(latitude: 57.78108, longitude: 11.950535)
    
    @State var start: MapCameraPosition
    
    init() {
        // Calculate the center coordinate
        let centerLatitude = (57.78184 + 57.78032) / 2
        let centerLongitude = (11.94775 + 11.95332) / 2
        let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        // Calculate the span
        let latitudeDelta = abs(57.78184 - 57.78032) * 1.5
        let longitudeDelta = abs(11.94775 - 11.95332) * 1.5
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        
        // Set the initial region
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        _start = State(initialValue: MapCameraPosition.region(region))
    }
    
    var body: some View {
        Map(position: $start) {
            Annotation("", coordinate: middleOfGreenPosition) {
                Circle()
                    .strokeBorder(Color.green, lineWidth: 2)
                    .background(Circle().foregroundColor(.green))
                    .frame(width: 20, height: 20)
            }
            Annotation("", coordinate: teePosition) {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .background(Circle().foregroundColor(.blue))
                    .frame(width: 20, height: 20)
            }
            Annotation("", coordinate: middleFairway) {
                Circle()
                    .strokeBorder(Color.red, lineWidth: 2)
                    .background(Circle().foregroundColor(.red))
                    .frame(width: 20, height: 20)
            }
        }
        .mapStyle(.hybrid)
    }
}

#Preview {
    TestView()
}

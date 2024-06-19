//
//  MapTestView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

struct MapTestView: View {
    
    let position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 57.7770727, longitude: 11.9487221),
            span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
        )
    )
    
   
    var body: some View {
        //Map(initialPosition: position).mapStyle(.hybrid)
        
        Map(initialPosition: position) {
            ForEach(locations) { location in
                //Marker("Green", coordinate: location.coordinate)
                MapPolygon(coordinates: CLLocationCoordinate2D.locations)
                            .stroke(.purple.opacity(0.7), lineWidth: 5)
                            .foregroundStyle(.purple.opacity(0.7))
            }
        }.mapStyle(.hybrid)
    }
}

#Preview {
    MapTestView()
}


struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

let locations = [
    Location(name: "Buckingham Palace", coordinate: CLLocationCoordinate2D(latitude: 51.501, longitude: -0.141)),
    Location(name: "Tower of London", coordinate: CLLocationCoordinate2D(latitude: 51.508, longitude: -0.076)),
    Location(name: "", coordinate: CLLocationCoordinate2D(latitude: 57.7770727, longitude: 11.9487221))
]

extension CLLocationCoordinate2D {
    static let locations = [
        CLLocationCoordinate2D(latitude: 57.7764222, longitude: 11.9455267),
            CLLocationCoordinate2D(latitude: 57.7764032, longitude: 11.9454367),
            CLLocationCoordinate2D(latitude: 57.7763226, longitude: 11.9453027),
            CLLocationCoordinate2D(latitude: 57.7762841, longitude: 11.9452752),
            CLLocationCoordinate2D(latitude: 57.7762471, longitude: 11.9452890),
            CLLocationCoordinate2D(latitude: 57.7762156, longitude: 11.9453852),
            CLLocationCoordinate2D(latitude: 57.7762277, longitude: 11.9454979),
            CLLocationCoordinate2D(latitude: 57.7762768, longitude: 11.9456738),
            CLLocationCoordinate2D(latitude: 57.7763175, longitude: 11.9457116),
            CLLocationCoordinate2D(latitude: 57.7763728, longitude: 11.9456841),
            CLLocationCoordinate2D(latitude: 57.7764127, longitude: 11.9456181),
            CLLocationCoordinate2D(latitude: 57.7764222, longitude: 11.9455267)
    ]
}

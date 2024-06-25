//
//  Hole.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-20.
//

import SwiftUI
import MapKit
import SwiftData

extension CLLocationCoordinate2D: Codable {
    public enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
    }
}

@Model
class HoleData {

    let num: Int
    var greenPos: CLLocationCoordinate2D
    var teePos: CLLocationCoordinate2D
    
   
    // Camera
    var camPos: MapCameraPosition
    
    func resetCamPos() {
        camPos = startCamPos
    }
    var camPosIsDefault: Bool {
        camPos == startCamPos
    }
    
    init(num: Int, greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        self.num = num
        self.greenPos = greenPos
        self.teePos = teePos
        self.camPos = GolfApp.startCamPos(centerPos: centerPos(greenPos: greenPos, teePos: teePos), teePos: teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: teePos, point2: greenPos))
    }
    
    private var startCamPos: MapCameraPosition {
        GolfApp.startCamPos(centerPos: centerPos(greenPos: greenPos, teePos: teePos), teePos: teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: teePos, point2: greenPos))
    }
}

func startCamPos(centerPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D, teeGreenDistance: Double) -> MapCameraPosition {
    .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
}
func centerPos(greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: (greenPos.latitude + teePos.latitude) / 2, longitude: (greenPos.longitude + teePos.longitude) / 2)
}

func distanceBetweenTwoPoints(point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) -> Double {
    let loc1 = CLLocation(latitude: point1.latitude, longitude: point1.longitude)
    let loc2 = CLLocation(latitude: point2.latitude, longitude: point2.longitude)
    return loc1.distance(from: loc2)
}


let albatross18holes = [

    HoleData(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775), teePos: CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)),
    HoleData(num: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756)),
    HoleData(num: 3, greenPos: CLLocationCoordinate2D(latitude: 57.78476, longitude: 11.94776), teePos: CLLocationCoordinate2D(latitude: 57.78260, longitude: 11.94981)),
    HoleData(num: 4, greenPos: CLLocationCoordinate2D(latitude: 57.78211, longitude: 11.94611), teePos: CLLocationCoordinate2D(latitude: 57.78496, longitude: 11.94720)),
    HoleData(num: 5, greenPos: CLLocationCoordinate2D(latitude: 57.78102, longitude: 11.94500), teePos: CLLocationCoordinate2D(latitude: 57.78171, longitude: 11.94645))

]


@Model
class Course {
    let name: String
    var holes: [HoleData]
    
    init(name: String, holes: [HoleData]) {
        self.name = name
        self.holes = holes
    }
}

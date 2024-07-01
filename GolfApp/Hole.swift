//
//  Hole.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-20.
//
//
import SwiftUI
import MapKit
import SwiftData

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
func resetCamPos(_ camPos: inout MapCameraPosition, to defaultCamPos: MapCameraPosition) {
    camPos = defaultCamPos
}
func camPosIsDefault(_ camPos: MapCameraPosition, with defaultCamPos: MapCameraPosition) -> Bool {
    camPos == defaultCamPos
}

let albatross18holes = [

    Hole(num: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78184, longitude: 11.94775), teePos: CLLocationCoordinate2D(latitude: 57.78032, longitude: 11.95332)),
    Hole(num: 2, greenPos: CLLocationCoordinate2D(latitude: 57.78239, longitude: 11.94944), teePos: CLLocationCoordinate2D(latitude: 57.78216, longitude: 11.94756)),
    Hole(num: 3, greenPos: CLLocationCoordinate2D(latitude: 57.78476, longitude: 11.94776), teePos: CLLocationCoordinate2D(latitude: 57.78260, longitude: 11.94981)),
    Hole(num: 4, greenPos: CLLocationCoordinate2D(latitude: 57.78211, longitude: 11.94611), teePos: CLLocationCoordinate2D(latitude: 57.78496, longitude: 11.94720)),
    Hole(num: 5, greenPos: CLLocationCoordinate2D(latitude: 57.78102, longitude: 11.94500), teePos: CLLocationCoordinate2D(latitude: 57.78171, longitude: 11.94645))

]

@Model
class Course {
    var name: String
    @Relationship(deleteRule: .cascade) var holes: [Hole]
    
    init(name: String, holes: [Hole]) {
        self.name = name
        self.holes = holes
    }
}

// HoleData for use in DragHolesView and HoleView, HoleMapView
@Observable
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
    func toHole() -> Hole {
        Hole(num: num, greenPos: greenPos, teePos: teePos)
    }
}

// SwiftData hole
@Model
class Hole {
    let num: Int
    var greenPos: CLLocationCoordinate2D
    var teePos: CLLocationCoordinate2D
    init(num: Int, greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        self.num = num
        self.greenPos = greenPos
        self.teePos = teePos
    }
    
    func toHoleData() -> HoleData {
        HoleData(num: num, greenPos: greenPos, teePos: teePos)
    }
}

// BETTER
extension Array where Element == Hole {
    func toHoleData() -> [HoleData] {
        var holeData: [HoleData] = []
        for hole in self {
            holeData.append(HoleData(num: hole.num, greenPos: hole.greenPos, teePos: hole.teePos))
        }
        return holeData
    }
}

extension Array where Element == HoleData {
    func toHoles() -> [Hole] {
        var holes: [Hole] = []
        for holeData in self {
            holes.append(Hole(num: holeData.num, greenPos: holeData.greenPos, teePos: holeData.teePos))
        }
        return holes
    }
}

extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
    
    // Initialize from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    // Encode to encoder
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

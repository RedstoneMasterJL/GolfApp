//
//  TestView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//
/*
import SwiftUI
import MapKit
import Combine

struct TestView: View {
    
    @ObservedObject var mapSettings = MapSettings()
    @State var mapType = 0
    @State var showElevation = 0
    @State var showEmphasis = 0
    
    var body: some View {
        ZStack {
            
            MapView(greenPos: holes[1].greenPos, teePos: holes[1].teePos)
                .edgesIgnoringSafeArea(.all).environmentObject(mapSettings)
            
        }.overlay(alignment: .bottom) {
            
            VStack {
                Picker("Map Type", selection: $mapType) {
                    Text("Standard").tag(0)
                    Text("Hybrid").tag(1)
                    Text("Image").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
                    .onChange(of: mapType) { newValue in
                        mapSettings.mapType = newValue
                    }.padding([.top, .leading, .trailing], 16)
                
                Picker("Map Elevation", selection: $showElevation) {
                    Text("Realistic").tag(0)
                    Text("Flat").tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showElevation) { newValue in
                        mapSettings.showElevation = newValue
                    }.padding([.leading, .trailing], 16)
                
                Picker("Map Elevation", selection: $showEmphasis) {
                    Text("Default").tag(0)
                    Text("Muted").tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                    .onChange(of: showEmphasis) { newValue in
                        mapSettings.showEmphasisStyle = newValue
                    }.padding([.leading, .trailing], 16)
                
            }.background(.black)
        }
    }
}

struct MapView: UIViewRepresentable {
    
    private var counter = 0
    private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 57.77988, longitude: 11.94977),
                                               span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003))
    let greenPos: CLLocationCoordinate2D
    let teePos: CLLocationCoordinate2D
    let centerPos: CLLocationCoordinate2D
    
    init(greenPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D) {
        centerPos = CLLocationCoordinate2D(latitude: (greenPos.latitude + teePos.latitude) / 2, longitude: (greenPos.longitude + teePos.longitude) / 2)
        self.greenPos = greenPos
        self.teePos = teePos
        
        let greenLoc = CLLocation(latitude: greenPos.latitude, longitude: greenPos.longitude)
        let teeLoc = CLLocation(latitude: teePos.latitude, longitude: teePos.longitude)
        //let centerLoc = CLLocation(latitude: centerPos.latitude, longitude: centerPos.longitude)
        let distance = greenLoc.distance(from: teeLoc)
        print(distance)
        
        startMKCam = MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: distance * 2.5)
        
    }
    @State var startMKCam: MKMapCamera

    
    @EnvironmentObject private var mapSettings: MapSettings

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.camera = startMKCam
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        updateMapType(uiView)
    }
    
    private func updateMapType(_ uiView: MKMapView) {
        switch mapSettings.mapType {
        case 0:
            uiView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: elevationStyle(), emphasisStyle: emphasisStyle())
        case 1:
            uiView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: elevationStyle())
        case 2:
            uiView.preferredConfiguration = MKImageryMapConfiguration(elevationStyle: elevationStyle())
        default:
            break
        }
        
    }
    
    private func elevationStyle() -> MKMapConfiguration.ElevationStyle {
        if mapSettings.showElevation == 0 {
            return MKMapConfiguration.ElevationStyle.realistic
        } else {
            return MKMapConfiguration.ElevationStyle.flat
        }
    }
    
    private func emphasisStyle() -> MKStandardMapConfiguration.EmphasisStyle {
        if mapSettings.showEmphasisStyle == 0 {
            return MKStandardMapConfiguration.EmphasisStyle.default
        } else {
            return MKStandardMapConfiguration.EmphasisStyle.muted
        }
    }
}

final class MapSettings: ObservableObject {
    @Published var mapType = 0
    @Published var showElevation = 0
    @Published var showEmphasisStyle = 0
}
*/ 
/*
 https://stackoverflow.com/questions/77354568/swiftui-mapkit-drag-annotation
//
//  HoleMapView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

private let rectWidth: Double = 80

private struct MarkerData {
    let coordinate: CLLocationCoordinate2D
    let screenPoint: CGPoint

    var touchableRect: CGRect {
        .init(x: screenPoint.x - rectWidth / 2, y: screenPoint.y - rectWidth / 2, width: rectWidth, height: rectWidth)
    }
}

struct HoleMapView: View {

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var modes: MapInteractionModes = [.zoom, .pan, .pitch]
    @State private var isMarkerDragging = false
    @State private var markerData: MarkerData?

    @Binding var hole: Hole

    var body: some View {
        GeometryReader { geometryProxy in
            MapReader { mapProxy in
                Map(position: Binding<MapCameraPosition>(get: {
                    .camera(MapCamera(MKMapCamera(lookingAtCenter: hole.centerPos, fromEyeCoordinate: hole.teePos, eyeAltitude: hole.teeGreenDistance * 2.5)))
                }, set: { newValue in }), interactionModes: modes) {
                    UserAnnotation()
                    Annotation("", coordinate: hole.greenPos) {
                        Circle().fill(.green)
                    }
                    if let markerData {
                        Marker("Start", coordinate: markerData.coordinate)
//                        Annotation("", coordinate: markerData.coordinate) {
//                            Image(systemName: "scope").foregroundStyle(.blue)
//                        }
                    }
                    Annotation("", coordinate: hole.teePos) {
                        Circle().fill(.yellow)
                    }
                }.mapStyle(.hybrid(elevation: .realistic))
                .onTapGesture { screenCoordinate in
                    self.markerData = mapProxy.markerData(screenCoordinate: screenCoordinate, geometryProxy: geometryProxy)
                }
                .highPriorityGesture(DragGesture(minimumDistance: 1)
                    .onChanged { drag in
                        guard let markerData else { return }
                        if isMarkerDragging {

                        } else if markerData.touchableRect.contains(drag.startLocation) {
                            isMarkerDragging = true
                            setMapInteraction(enabled: false)
                        } else {
                            return
                        }

                        self.markerData = mapProxy.markerData(screenCoordinate: drag.location, geometryProxy: geometryProxy)
                    }
                    .onEnded { drag in
                        setMapInteraction(enabled: true)
                        isMarkerDragging = false
                    }
                )
                .onMapCameraChange {
                    guard let markerData else { return }
                    self.markerData = mapProxy.markerData(coordinate: markerData.coordinate, geometryProxy: geometryProxy)
                }
                .onAppear {
                    self.markerData = mapProxy.markerData(coordinate: hole.centerPos, geometryProxy: geometryProxy)
                }
            }
        }
    }

    private func setMapInteraction(enabled: Bool) {
        if enabled {
            modes = [.zoom, .pan, .pitch]
        } else {
            modes = []
        }
    }
}

private extension MapProxy {

    func markerData(screenCoordinate: CGPoint, geometryProxy: GeometryProxy) -> MarkerData? {
        guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: screenCoordinate)
    }

    func markerData(coordinate: CLLocationCoordinate2D, geometryProxy: GeometryProxy) -> MarkerData? {
        guard let point = convert(coordinate, to: .local) else { return nil }
        return .init(coordinate: coordinate, screenPoint: point)
    }
}
*/



/*
 https://www.youtube.com/watch?v=5Z7kYPnPbUE
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
     let modes: MapInteractionModes = [.zoom, .pitch]
     
     @State var coordinate: CLLocationCoordinate2D = holes[0].centerPos
     
     var body: some View {
         MapReader { proxy in
             Map(position: Binding<MapCameraPosition>(get: {
                 .camera(MapCamera(MKMapCamera(lookingAtCenter: hole.centerPos, fromEyeCoordinate: hole.teePos, eyeAltitude: hole.teeGreenDistance * 2.5)))
             }, set: { newValue in
                 
             }), interactionModes: modes) {
                 UserAnnotation()
                 Annotation("", coordinate: hole.greenPos) {
                     Circle().fill(.green)
                 }
                 Annotation("", coordinate: hole.centerPos) {
                     //Image(systemName: "scope").foregroundStyle(.blue)
                     Pin(proxy: proxy, coordinates: $coordinate)
                 }
                 Annotation("", coordinate: hole.teePos) {
                     Circle().fill(.yellow)
                 }
             }.mapStyle(.hybrid(elevation: .realistic))
         }
     }
 }

 #Preview {
     HoleMapView(hole: .constant(holes[0]))
 }

 struct Pin: View {
     var proxy: MapProxy
     @Binding var coordinates: CLLocationCoordinate2D
     @State private var isActive = false
     @State private var translation: CGSize = .zero
     
     var body: some View {
         GeometryReader { geometry in
             let frame = geometry.frame(in: .global)
             
             Image(systemName: "location.circle.fill")
                 .font(.largeTitle)
                 .foregroundColor(isActive ? .blue : .red)
                 .scaleEffect(isActive ? 1.3 : 1)
                 .animation(.bouncy, value: isActive)
                 .frame(width: 30, height: 30)
                 .contentShape(Rectangle())
                 .offset(translation)
                 .gesture(
                     LongPressGesture(minimumDuration: 0.2)
                         .onEnded { _ in
                             isActive = true
                         }
                         .simultaneously(with: DragGesture()
                             .onChanged { value in
                                 if isActive {
                                     translation = value.translation
                                 }
                             }
                             .onEnded { value in
                                 if isActive {
                                     isActive = false
                                     
                                     // Update coordinates and call the callback
                                     let position = CGPoint(x: frame.midX + translation.width, y: frame.midY + translation.height)
                                     if let coordinate = proxy.convert(position, from: .global) {
                                         self.coordinates = coordinate
                                         translation = .zero
                                     }
                                 }
                             }
                         )
                 )
         }
     }
 }


 */



/*
 21 juni 17:42
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
     @State var modes: MapInteractionModes = [.zoom, .pitch]
     @State private var cameraPosition: MapCameraPosition = .automatic
     @State private var isMarkerDragging = false
     @State private var markerData: MarkerData?
     
     var body: some View {
         GeometryReader { geometryProxy in
             MapReader { mapProxy in
                 Map(position: Binding<MapCameraPosition>(get: {
                     .camera(MapCamera(MKMapCamera(lookingAtCenter: hole.centerPos, fromEyeCoordinate: hole.teePos, eyeAltitude: hole.teeGreenDistance * 2.5)))
                 }, set: { newValue in
                     
                 }), interactionModes: modes) {
                     if let markerData {
                         Annotation("", coordinate: markerData.coordinate) {
                             Image(systemName: "scope").foregroundStyle(.blue)
                         }
                     }
                     UserAnnotation()
                     Annotation("", coordinate: hole.greenPos) {
                         Circle().fill(.green)
                     }
                     Annotation("", coordinate: hole.teePos) {
                         Circle().fill(.yellow)
                     }
                 }.mapStyle(.hybrid(elevation: .realistic))
                     .mapControls { MapScaleView() }
                     .onTapGesture { screenCoordinate in
                         self.markerData = mapProxy.markerData(screenCoordinate: screenCoordinate, geometryProxy: geometryProxy)
                     }
                     .highPriorityGesture(DragGesture(minimumDistance: 1)
                         .onChanged { drag in
                             guard let markerData else { return }
                             if isMarkerDragging {
                                 
                             } else if markerData.touchableRect.contains(drag.startLocation) {
                                 isMarkerDragging = true
                                 setMapInteraction(enabled: false)
                             } else {
                                 return
                             }
                             
                             self.markerData = mapProxy.markerData(screenCoordinate: drag.location, geometryProxy: geometryProxy)
                         }
                         .onEnded { drag in
                             setMapInteraction(enabled: true)
                             isMarkerDragging = false
                         }
                     )
                     .onMapCameraChange {
                         guard let markerData else { return }
                         self.markerData = mapProxy.markerData(coordinate: markerData.coordinate, geometryProxy: geometryProxy)
                     }
             }
         }
     }
     private func setMapInteraction(enabled: Bool) {
         if enabled {
             modes = [.zoom, .pitch]
         } else {
             modes = []
         }
     }
 }



 #Preview {
     HoleMapView(hole: .constant(holes[0]))
 }

 private let rectWidth: Double = 80

 private struct MarkerData {
     let coordinate: CLLocationCoordinate2D
     let screenPoint: CGPoint
     
     var touchableRect: CGRect {
         .init(x: screenPoint.x - rectWidth / 2, y: screenPoint.y - rectWidth / 2, width: rectWidth, height: rectWidth)
     }
 }

 private extension MapProxy {
     
     func markerData(screenCoordinate: CGPoint, geometryProxy: GeometryProxy) -> MarkerData? {
         guard let coordinate = convert(screenCoordinate, from: .local) else { return nil }
         return .init(coordinate: coordinate, screenPoint: screenCoordinate)
     }
     
     func markerData(coordinate: CLLocationCoordinate2D, geometryProxy: GeometryProxy) -> MarkerData? {
         guard let point = convert(coordinate, to: .local) else { return nil }
         return .init(coordinate: coordinate, screenPoint: point)
     }
 }

 */

/*
 19:48
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
     let modes: MapInteractionModes = [.zoom, .pan, .pitch]
     
     @State var coordinate: CLLocationCoordinate2D?
     @State var position: MapCameraPosition?
     
     var body: some View {
         MapReader { proxy in
             Map(position: Binding<MapCameraPosition>(get: {
                 .camera(MapCamera(MKMapCamera(lookingAtCenter: hole.centerPos, fromEyeCoordinate: hole.teePos, eyeAltitude: hole.teeGreenDistance * 2.5)))
             }, set: { newValue in
                 position = newValue
                 print(position?.camera?.centerCoordinate)
             }), interactionModes: modes) {
                 UserAnnotation()
                 Annotation("", coordinate: hole.greenPos) {
                     Circle().fill(.green)
                 }
                 Annotation("", coordinate: coordinate ?? hole.centerPos) {
                     DraggablePin(proxy: proxy, coordinate: $coordinate.withDefault(hole.centerPos))
                 }
                 Annotation("", coordinate: hole.teePos) {
                     Circle().fill(.yellow)
                 }
             }.mapStyle(.hybrid(elevation: .realistic))
                 .mapControls { MapScaleView(); Button("test") {  } }
                 .onChange(of: hole) { oldValue, newValue in
                     coordinate = hole.centerPos
                 }
                 .onMapCameraChange(frequency: .continuous) {
                     let centerPos = hole.centerPos
                     let regionRadius: Double = 500 // meter
                     let northEastCoordinate = CLLocationCoordinate2D(latitude: centerPos.latitude + regionRadius / 111000.0, longitude: centerPos.longitude + regionRadius / (111000.0 * cos(centerPos.latitude * .pi / 180.0)))
                     let southWestCoordinate = CLLocationCoordinate2D(latitude: centerPos.latitude - regionRadius / 111000.0, longitude: centerPos.longitude - regionRadius / (111000.0 * cos(centerPos.latitude * .pi / 180.0)))
                     
                     var region = position?.region
                     
                     if region?.center.latitude ?? centerPos.latitude > northEastCoordinate.latitude {
                         position = .region(MKCoordinateRegion(center: centerPos, span: MKCoordinateSpan(latitudeDelta: northEastCoordinate.latitude, longitudeDelta: region?.center.longitude ?? centerPos.longitude)))
                     }
                     if region?.center.latitude ?? centerPos.latitude < southWestCoordinate.latitude {
                         position = .region(MKCoordinateRegion(center: centerPos, span: MKCoordinateSpan(latitudeDelta: northEastCoordinate.latitude, longitudeDelta: region?.center.longitude ?? centerPos.longitude)))
                     }
                     if region?.center.longitude ?? centerPos.latitude > northEastCoordinate.longitude {
                         position = .region(MKCoordinateRegion(center: centerPos, span: MKCoordinateSpan(latitudeDelta: region?.center.latitude ?? centerPos.longitude, longitudeDelta: northEastCoordinate.latitude)))
                     }
                     if region?.center.longitude ?? centerPos.latitude < southWestCoordinate.longitude {
                         position = .region(MKCoordinateRegion(center: centerPos, span: MKCoordinateSpan(latitudeDelta: region?.center.latitude ?? centerPos.longitude, longitudeDelta: northEastCoordinate.latitude)))
                     }
                     
                 }
         }
     }
     
     func checkCanPan() {
         let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
         let region = MKCoordinateRegion(center: hole.centerPos, span: span)
         if position?.region?.span.longitudeDelta ?? 0.1 > span.longitudeDelta {
             position = .region(region)
         }
     }
 }

 struct DraggablePin: View {
     var proxy: MapProxy
     @Binding var coordinate: CLLocationCoordinate2D
     @State private var isActive = false
     @State private var translation: CGSize = .zero
     
     var body: some View {
         GeometryReader {
             let frame = $0.frame(in: .global)
             
             Image(systemName: "dot.scope")
                 .font(.system(size: 50))
                 .fontWeight(.thin)
                 .foregroundStyle(.orange.gradient)
                 .animation(.snappy, body: { content in
                     content.scaleEffect(isActive ? 1.3 : 1)
                 })
                 .frame(width: frame.width, height: frame.height)
                 .onChange(of: isActive, initial: false) { oldValue, newValue in
                     let position = CGPoint(x: frame.midX, y: frame.midY)
                     if let coordinate = proxy.convert(position, from: .global) {
                         self.coordinate = coordinate
                         translation = .zero
                     }
                 }
         }
         .frame(width: 70, height: 70)
         .contentShape(.rect)
         .offset(translation)
         .gesture(
             LongPressGesture(minimumDuration: 0)
                 .onEnded { isActive = $0 }
                 .simultaneously(with: DragGesture(minimumDistance: 0)
                     .onChanged { value in
                         if isActive { translation = value.translation }
                     }
                     .onEnded { value in
                         if isActive { isActive = false }
                     }
                 )
         )
     }
 }

 #Preview {
     HoleMapView(hole: .constant(holes[0]))
 }

 extension Binding {
   func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
     return Binding<T>(get: {
       self.wrappedValue ?? defaultValue
     }, set: { newValue in
       self.wrappedValue = newValue
     })
   }
 }

 */

/*
 TEST 22 juni 21:14
 //
 //  HoleCameraManager.swift
 //  GolfApp
 //
 //  Created by Jonathan Linder on 2024-06-22.
 //

 import SwiftUI
 import MapKit

 @Observable
 class HoleCameraManager {
     
     var currentHole: Hole
     
     var camPos: MapCameraPosition
     
     let startCamPos: MapCameraPosition
     
     
     init(currentHole: Hole) {
         self.currentHole = currentHole
         self.startCamPos = GolfApp.cameraSetupFor(centerPos: currentHole.centerPos, teePos: currentHole.teePos, teeGreenDistance: currentHole.teeGreenDistance)
         self.camPos = startCamPos
     }
     
     func resetCamPos() {
         camPos = startCamPos
     }
 }

 func cameraSetupFor(centerPos: CLLocationCoordinate2D, teePos: CLLocationCoordinate2D, teeGreenDistance: Double) -> MapCameraPosition {
     .camera(MapCamera(MKMapCamera(lookingAtCenter: centerPos, fromEyeCoordinate: teePos, eyeAltitude: teeGreenDistance * 2.5)))
 }


 */

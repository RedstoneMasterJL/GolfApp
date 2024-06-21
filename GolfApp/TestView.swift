//
//  TestView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

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

//
//  DragHolesView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-24.
//

import SwiftUI
import MapKit

struct DragHolesView: View {
    @State var translation: CGSize = .zero
    @State private var isActive = false
    @State private var coordinate: CLLocationCoordinate2D = .init(latitude: 57.78191, longitude: 11.95473)
    
    @State private var position: MapCameraPosition = .automatic
    
    @State var markers: [HoleMarkerData]
    
    @State var currentHole = 1

    init() {
        markers = [
            //HoleMarkerData(holeNum: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
            HoleMarkerData(holeNum: 1, greenMarkerPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teeMarkerPos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
        ]
    }
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
                
//                ForEach(markers) { marker in
//                    @Bindable var marker = marker
//                    Annotation(String(marker.holeNum), coordinate: marker.greenMarkerPos) {
//                        MarkerView(proxy: proxy, type: .green, coordinate: $marker.greenMarkerPos)
//                        //DraggablePin(proxy: proxy, coordinate: $coordinate)
//                    }
//                    Annotation(String(marker.holeNum), coordinate: marker.teeMarkerPos) {
//                        MarkerView(proxy: proxy, type: .tee, coordinate: $marker.teeMarkerPos)
//                    }
//                }
                
                // detta funkar!
                Annotation(String(markers[0].holeNum), coordinate: markers[0].teeMarkerPos) {
                    MarkerView(proxy: proxy, type: .tee, coordinate: $markers[0].teeMarkerPos)
                }
                
                // for each med index är bättre, funkar!!!!
                // https://developer.apple.com/documentation/swift/range
                ForEach(0..<markers.count, id: \.self) { i in
                    Annotation(String(markers[i].holeNum), coordinate: markers[i].greenMarkerPos) {
                        MarkerView(proxy: proxy, type: .green, coordinate: $markers[i].greenMarkerPos)
                    }
                    Annotation(String(markers[i].holeNum), coordinate: markers[i].teeMarkerPos) {
                        MarkerView(proxy: proxy, type: .tee, coordinate: $markers[i].teeMarkerPos)
                    }
                    MapPolyline(coordinates: [markers[i].greenMarkerPos, markers[i].teeMarkerPos])
                        .stroke(.orange, lineWidth: 2)
                }
                
            }.mapStyle(.imagery(elevation: .realistic))
            
                .safeAreaInset(edge: .top) {
                    HStack {
                        Text("Lägg till hål")
                        Divider().frame(maxHeight: 15)
                        Text("Nuvarande hål \(currentHole)")
                        Button("+") {
                            //markers.append(HoleMarkerData(holeNum: 2, greenPos: proxy.convert(.init(x: rectWidth/4, y: rectWidth/4), from: .global) ?? CLLocationCoordinate2D(latitude: 1, longitude: 1), teePos: proxy.convert(.init(x: rectWidth/4, y: rectWidth/4), from: .global) ?? CLLocationCoordinate2D(latitude: 1, longitude: 1))) // TESTADE HÄR MED SCREENPOINT OCH SÅMT
                            
                            //let newHoleMarker = HoleMarkerData(holeNum: currentHole + 1, greenPos: markers[currentHole-1].greenMarker.coordinate, teePos: markers[currentHole-1].greenMarker.coordinate)
                            let newHoleMarker = HoleMarkerData(holeNum: currentHole + 1, greenMarkerPos: markers[currentHole-1].greenMarkerPos, teeMarkerPos: markers[currentHole-1].greenMarkerPos)
                            markers.append(newHoleMarker)
                            currentHole += 1
                            // FUNKAR NOG BÄTTRE, sedan kan man även ändra så att den nya markeringen är lite bredvid den andra kanske
                            
                            // VERKAR BLI KONSTIGT I UPPDATERINGEN AV MARKÖRERNA KANSKE NÅGOT MED BINDABLE OCH OBSERVABLE OCH ATT GREENMARKER OCH TEEMARKER ÄR PROPERTYS AV HOLEMARKERDATA, FÅR KOLLA PÅ RElATIONSHIPS OCH SWIFTDATA KANSKE?
                            
                        }.disabled(markers.count == 18)
                        Button("-") {
                            markers.removeLast()
                            currentHole -= 1
                        }.disabled(markers.count == 1)
                    }.frame(maxWidth: .infinity).padding(.bottom).background(.orange.gradient)
                }
        }
    }
}

#Preview {
    DragHolesView()
}

let eaglekorten = [

    Hole(number: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
]

enum MarkerType {
    case green, tee
}

@Observable
class HoleMarkerData: Identifiable {
    let holeNum: Int
    var greenMarkerPos: CLLocationCoordinate2D
    var teeMarkerPos: CLLocationCoordinate2D
    
    init(holeNum: Int, greenMarkerPos: CLLocationCoordinate2D, teeMarkerPos: CLLocationCoordinate2D) {
        self.holeNum = holeNum
        self.greenMarkerPos = greenMarkerPos
        self.teeMarkerPos = teeMarkerPos
    }
}

///@Observable
///class HoleMarker {
///    let type: MarkerType
///    var coordinate: CLLocationCoordinate2D
///    init(type: MarkerType, coordinate: CLLocationCoordinate2D) {
///        self.type = type
///        self.coordinate = coordinate
///    }
///}


struct MarkerView: View {
    var proxy: MapProxy
    //@Binding var marker: HoleMarker
    
    let type: MarkerType
    @State private var translation: CGSize = .zero
    @State private var isActive: Bool = false
    @Binding var coordinate: CLLocationCoordinate2D
    
    var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .global)
            
            Image(systemName: type == .green ? "flag.circle.fill" : "t.circle.fill")
                .foregroundStyle(type == .green ? .orange : .yellow)
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
            LongPressGesture(minimumDuration: 0.10) // så att man ej råkar ta i den
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

/*
 // Green
 Annotation("1", coordinate: coordinate) {
     GeometryReader {
         let frame = $0.frame(in: .global)
         Image(systemName: "flag.circle.fill")
             .foregroundStyle(.orange)
             .animation(.snappy, body: { content in
                 content.scaleEffect(isActive ? 1.3 : 1)
             })
             .onChange(of: isActive) { oldValue, newValue in
                 let position = CGPoint(x: frame.midX, y: frame.midY)
                 if let coordinate = proxy.convert(position, from: .global) {
                     self.coordinate = coordinate
                     translation = .zero
                 }
             }
     }
     .offset(translation)
     .gesture(
         LongPressGesture(minimumDuration: 0.10) // så att man ej råkar ta i den
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
 // Tee
 Annotation("1", coordinate: coordinate2) {
     GeometryReader {
         let frame = $0.frame(in: .global)
         Image(systemName: "t.circle.fill")
             .foregroundStyle(.yellow)
             .animation(.snappy, body: { content in
                 content.scaleEffect(isActive ? 1.3 : 1)
             })
             .onChange(of: isActive) { oldValue, newValue in
                 let position = CGPoint(x: frame.midX, y: frame.midY)
                 if let coordinate = proxy.convert(position, from: .global) {
                     self.coordinate2 = coordinate
                     translation2 = .zero
                 }
             }
     }
     .offset(translation2)
     .gesture(
         LongPressGesture(minimumDuration: 0.10) // så att man ej råkar ta i den
             .onEnded { isActive = $0 }
             .simultaneously(with: DragGesture(minimumDistance: 0)
                 .onChanged { value in
                     if isActive { translation2 = value.translation }
                 }
                 .onEnded { value in
                     if isActive { isActive = false }
                 }
             )
     )
 }
 */

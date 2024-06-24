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
    @State var translation2: CGSize = .zero
    @State private var isActive = false
    @State private var coordinate: CLLocationCoordinate2D = .init(latitude: 57.78191, longitude: 11.95473)
    @State private var coordinate2: CLLocationCoordinate2D = .init(latitude: 57.78120, longitude: 11.95568)

//    @State private var position: MapCameraPosition = .camera(MapCamera(centerCoordinate: .init(latitude: 57.78191, longitude: 11.95473), distance: 3000))
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        MapReader { proxy in
            Map(position: $position) {
//                Annotation("", coordinate: coordinate) {
//                    GeometryReader {
//                        let frame = $0.frame(in: .global)
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 20).fill(.blue.gradient)
//                                .frame(width: frame.width, height: frame.height)
//                            Text("Hål 1").foregroundStyle(.white)
//                        }
//                        .onChange(of: isActive) { oldValue, newValue in
//                            let position = CGPoint(x: frame.midX, y: frame.midY)
//                            if let coordinate = proxy.convert(position, from: .global) {
//                                self.coordinate = coordinate
//                                translation = .zero
//                            }
//                        }
//                    }
//                    .frame(width: 70, height: 40)
//                    .contentShape(.rect)
//                    .offset(translation)
//                    .gesture(
//                        LongPressGesture(minimumDuration: 0.10) // så att man ej råkar ta i den
//                            .onEnded { isActive = $0 }
//                            .simultaneously(with: DragGesture(minimumDistance: 0)
//                                .onChanged { value in
//                                    if isActive { translation = value.translation }
//                                }
//                                .onEnded { value in
//                                    if isActive { isActive = false }
//                                }
//                            )
//                    )
//                }
                //Marker("Green 1", coordinate: coordinate)
                    
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
                    
                //Marker("Tee 1", coordinate: coordinate2)
                
            }.mapStyle(.imagery(elevation: .realistic))
        }
    }
}

#Preview {
    DragHolesView()
}

let eaglekorten = [

    Hole(number: 1, greenPos: CLLocationCoordinate2D(latitude: 57.78191, longitude: 11.95473), teePos: CLLocationCoordinate2D(latitude: 57.78120, longitude: 11.95568))
]



//let dictionary: String,

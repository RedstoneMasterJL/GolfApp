//
//  HoleView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-22.
//

import SwiftUI
import MapKit

struct HoleView: View {
    
    @State var currentHole = 1
    
    @State var hole: HoleData
    
    let holes: [HoleData] // Hole array
    
    init(holes: [HoleData]) {
        self.hole = holes[0] // First hole
        self.holes = holes
        self.camPos = startCamPos(centerPos: centerPos(greenPos: holes[0].greenPos, teePos: holes[0].teePos), teePos: holes[0].teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: holes[0].teePos, point2: holes[0].greenPos))
    }
    
    @State var scopeData: ScopeData?
    @State var camPos: MapCameraPosition
    
    
    var body: some View {
        HoleMapView(hole: $hole, scopeData: $scopeData)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    ZStack {
                        OpacityRectangle()
                        Button {
                            withAnimation {
                                currentHole -= 1
                                hole = holes[currentHole-1]
                            }
                        } label: {
                            Image(systemName: "arrow.left").font(.title).frame(width: 50, height: 50)
                        }.disabled(currentHole == 1)
                    }.frame(maxWidth: 60)
                    Spacer()
                    ZStack {
                        OpacityRectangle()
                        Button {
                            withAnimation {
                                currentHole += 1
                                hole = holes[currentHole-1]
                            }
                        } label: {
                            Image(systemName: "arrow.right").font(.title).frame(width: 50, height: 50)
                        }.disabled(currentHole == holes.count)
                    }.frame(maxWidth: 60)
                    
                }.frame(maxHeight: 60).padding()
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    ZStack {
                        OpacityRectangle()
                        Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                    }.frame(maxWidth: 60)
                    ZStack {
                        OpacityRectangle()
                        Button {
                            withAnimation { hole.resetCamPos() }
                        } label: {
                            Image(systemName: "arrow.circlepath").font(.title).frame(width: 50, height: 50)
                        }.disabled(hole.camPosIsDefault)
                    }.frame(maxWidth: 60)
                    Spacer()
                    ZStack {
                        OpacityRectangle()
                        VStack {
                            if let scopeData = scopeData {
                                Text("To scope").font(.footnote)
                                Text("\(distanceBetweenTwoPoints(point1: hole.teePos, point2: scopeData.coordinate), specifier: "%.0f")").font(.title)
                            } else {
                                Text("Place scope")
                                Text("---").font(.title)
                            }
                        }
                    }.frame(maxWidth: 100)
                }.frame(maxHeight: 60).padding()
            }
    }
    
    @Environment(\.colorScheme) var clrScheme
    
    
}

#Preview {
    HoleView(holes: toHoleDataArray(holes: albatross18holes))
}

struct OpacityRectangle: View {
    @Environment(\.colorScheme) var clrScheme
    var body: some View {
        RoundedRectangle(cornerRadius: 25.0).foregroundStyle(clrScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.6))
    }
}

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
        let sortedHoles = holes.sorted {
            $0.num < $1.num
        }
        self.hole = sortedHoles[0] // First hole
        self.holes = sortedHoles
        self.camPos = startCamPos(centerPos: centerPos(greenPos: sortedHoles[0].greenPos, teePos: sortedHoles[0].teePos), teePos: sortedHoles[0].teePos, teeGreenDistance: distanceBetweenTwoPoints(point1: sortedHoles[0].teePos, point2: sortedHoles[0].greenPos))
    }
    
    @State var scopeData: ScopeData?
    @State var camPos: MapCameraPosition
    
    
    var body: some View {
        HoleMapView(hole: $hole, scopeData: $scopeData)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        withAnimation {
                            currentHole -= 1
                            hole = holes[currentHole-1]
                        }
                    } label: {
                        Image(systemName: "arrow.left").font(.title)
                    }.disabled(currentHole == 1)
                        .rectBg()
                    Spacer()
                    Button {
                        withAnimation {
                            currentHole += 1
                            hole = holes[currentHole-1]
                        }
                    } label: {
                        Image(systemName: "arrow.right").font(.title)
                    }.disabled(currentHole == holes.count)
                        .rectBg()
                }.padding()
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                        .rectBg()
                    Button {
                        withAnimation { hole.resetCamPos() }
                    } label: {
                        Image(systemName: "arrow.circlepath").font(.title)
                    }.disabled(hole.camPosIsDefault).rectBg()
                    Spacer()
                    VStack {
                        if let scopeData = scopeData {
                            Text("To scope").font(.footnote)
                            Text("\(distanceBetweenTwoPoints(point1: hole.teePos, point2: scopeData.coordinate), specifier: "%.0f")").font(.title)
                        } else {
                            Text("Place scope").font(.footnote)
                            Text("--").font(.title)
                        }
                    }.rectBg(expandable: true)
                }.padding()
            }
    }
    
    @Environment(\.colorScheme) var clrScheme
    
    
}

#Preview {
    HoleView(holes: albatross18holes.toHoleData())
}

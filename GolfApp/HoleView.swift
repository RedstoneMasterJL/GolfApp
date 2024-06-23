//
//  HoleView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-22.
//

import SwiftUI

struct HoleView: View {
    
    @State var currentHole = 1
    
    @State var hole: Hole
    
    let holes: [Hole] // Hole array
    
    init(holes: [Hole]) {
        self.hole = holes[0] // First hole
        self.holes = holes
    }
    
    @State var markerData: MarkerData?
    
    var body: some View {
        HoleMapView(hole: $hole, markerData: $markerData)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    ZStack {
                        rectangle
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
                        rectangle
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
                        rectangle
                        Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                    }.frame(maxWidth: 60)
                    ZStack {
                        rectangle
                        Button {
                            withAnimation { hole.resetHole() }
                        } label: {
                            Image(systemName: "arrow.circlepath").font(.title).frame(width: 50, height: 50)
                        }.disabled(hole.isDefault)
                    }.frame(maxWidth: 60)
                    Spacer()
                    ZStack {
                        rectangle
                        VStack {
                            Text("To scope").font(.footnote)
                            Text("\(distanceBetweenTwoPoints(point1: hole.teePos, point2: markerData?.coordinate ?? hole.centerPos), specifier: "%.0f")").font(.title)
                        }
                    }.frame(maxWidth: 100)
                }.frame(maxHeight: 60).padding()
            }
    }
    
    @Environment(\.colorScheme) var clrScheme
    
    private var rectangle: some View {
        RoundedRectangle(cornerRadius: 25.0).foregroundStyle(clrScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.6))

    }
}

#Preview {
    HoleView(holes: albatross18holes)
}

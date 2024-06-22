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
    
    init() {
        self.hole = holes[0] // First hole
    }
    
    var body: some View {
        HoleMapView(hole: $hole)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button(action: {
                        withAnimation {
                            currentHole -= 1
                            hole = holes[currentHole-1]
                        }
                    }, label: {
                        Image(systemName: "arrow.left")
                    }).buttonStyle(.borderedProminent).disabled(currentHole == 1)
                    Spacer()
                    Button(action: {
                        withAnimation{
                            currentHole += 1
                            hole = holes[currentHole-1]
                        }
                    }, label: {
                        Image(systemName: "arrow.right")
                    }).buttonStyle(.borderedProminent).disabled(currentHole == holes.count)
                }.padding()//.background(.green)
            }
            .safeAreaInset(edge: .top) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.white.opacity(0.6)).frame(width: 60, height: 60)
                        Text(String(currentHole)).font(.largeTitle).fontDesign(.rounded)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.white.opacity(0.6)).frame(width: 60, height: 60)
                        Button {
                            withAnimation { hole.resetHole() }
                        } label: {
                            Image(systemName: "arrow.circlepath").font(.title).frame(width: 50, height: 50)
                        }
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 25.0).foregroundStyle(.white.opacity(0.6))
                        VStack {
                            Text("To scope")
                            Text("\(hole.teeScopeDistance, specifier: "%.0f")")
                        }
                    }.frame(maxHeight: 60)
                }.padding()
            }
    }
}

#Preview {
    HoleView()
}

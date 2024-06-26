//
//  OpacityRect.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-26.
//

import SwiftUI

private struct OpacityRectangleModifier: ViewModifier {
    let expandable: Bool
    @Environment(\.colorScheme) var clrScheme
    func body(content: Content) -> some View {
        content
            .frame(height: 50)
            .if(!expandable) {
                $0.frame(width: 50)
            }
            .if(expandable) {
                $0.padding(.horizontal)
            }
            
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 25.0)
                    .foregroundStyle(
                        clrScheme == .dark ? .black.opacity(0.6) : .white.opacity(0.6)
                    )
                    
            )
    }
}

extension View {
    func rectBg(expandable: Bool = false) -> some View {
        modifier(OpacityRectangleModifier(expandable: expandable))
    }
}

//
//  Binding+.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-21.
//

import SwiftUI

extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}

extension View {
    // https://ma7moudalaa.medium.com/conditional-modifiers-in-swiftui-a-guide-to-if-iflet-and-modifierif-2409fda506ab
    
    /// - Parameters:
    ///   - condition: A Boolean value determining whether the transformation should be applied.
    ///   - transform: A closure taking the original view and returning a modified content.
    /// - Returns: If the condition is true, returns the transformed content; otherwise, returns the original view.
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// - Parameters:
    ///   - value: An optional value that determines whether the transformation should be applied.
    ///   - transform: A closure taking the original view and the unwrapped value, returning a modified content.
    /// - Returns: If the optional value is non-nil, returns the transformed content; otherwise, returns the original view.
    @ViewBuilder
    func `ifLet`<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
    
    /// - Parameters:
    ///   - condition: A Boolean value determining whether the modifier should be applied.
    ///   - modifier: The custom view modifier to be applied if the condition is true.
    /// - Returns: If the condition is true, returns the view with the applied modifier; otherwise, returns the original view.
    @ViewBuilder
    func `modifierIf`<Modifier: ViewModifier>(_ condition: Bool, modifier: Modifier) -> some View {
        if condition {
            self.modifier(modifier)
        } else {
            self
        }
    }
}

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

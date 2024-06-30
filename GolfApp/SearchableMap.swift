//
//  TestView.swift
//  GolfApp
//
//  Created by Jonathan Linder on 2024-06-19.
//

import SwiftUI
import MapKit

 struct SearchableMap: View {
     @State private var position = MapCameraPosition.automatic
     @State private var searchResults = [SearchResult]()
     @State private var selectedLocation: SearchResult?
     @State private var isSheetPresented: Bool = true

     @Binding var showDragHolesView: Bool
     @Environment(\.dismiss) var dismiss
     @Environment(\.modelContext) var moc
     var body: some View {
         Map(position: $position, selection: $selectedLocation) {
             ForEach(searchResults) { result in
                 Marker(result.title, coordinate: result.location)
                 .tag(result)
             }
         }.mapStyle(.hybrid(elevation: .realistic))
         .ignoresSafeArea()
         .onChange(of: selectedLocation) {
             isSheetPresented = selectedLocation == nil
         }
         .onChange(of: searchResults) {
             if let firstResult = searchResults.first, searchResults.count == 1 {
                 selectedLocation = firstResult
             }
         }
         .sheet(isPresented: $isSheetPresented) {
             SheetView(searchResults: $searchResults)
         }
         .safeAreaInset(edge: .bottom) {
             if let selectedLocation = selectedLocation {
                 HStack {
                     Text(selectedLocation.title)
                     Button(action: {
                         withAnimation { showDragHolesView = true }
                     }, label: {
                         Image(systemName: "arrow.right")
                     })
                 }.rectBg(expandable: true)
             }
         }
         .overlay {
             if let selectedLocation = selectedLocation {
                 if showDragHolesView {
                     DragHolesView("", [HoleData(num: 1, greenPos: selectedLocation.location, teePos: selectedLocation.location)]) { holeDataArray, name in
                         let newCourse = Course(name: name, holes: holeDataArray.toHoles())
                         moc.insert(newCourse)
                     }
                 }
             }
         }
         .safeAreaInset(edge: .top) {
             HStack {
                 Button {
                     dismiss()
                 } label: {
                     Image(systemName: "arrow.left").font(.title)
                         .rectBg()
                 }
                 Spacer()
             }.padding()
         }
     }
 }

 #Preview(body: {
     SearchableMap(showDragHolesView: .constant(false))
 })

 struct SheetView: View {
     @State private var locationService = LocationService(completer: .init())
     @State private var search: String = ""
     @Binding var searchResults: [SearchResult]

     var body: some View {
         VStack {
             HStack {
                 Image(systemName: "magnifyingglass")
                 TextField("Search for a golf club", text: $search)
                     .autocorrectionDisabled()
                     .onSubmit {
                         Task {
                             searchResults = (try? await locationService.search(with: search)) ?? []
                         }
                     }
             }
             .modifier(TextFieldGrayBackgroundColor())

             Spacer()

             List {
                 ForEach(locationService.completions) { completion in
                     Button(action: { didTapOnCompletion(completion) }) {
                         VStack(alignment: .leading, spacing: 4) {
                             Text(completion.title)
                                 .font(.headline)
                                 .fontDesign(.rounded)
                             Text(completion.subTitle)
                             if let url = completion.url {
                                 Link(url.absoluteString, destination: url)
                                     .lineLimit(1)
                             }
                         }
                     }
                     .listRowBackground(Color.clear)
                 }
             }
             .listStyle(.plain)
             .scrollContentBackground(.hidden)
         }
         .onChange(of: search) {
             locationService.update(queryFragment: search)
         }
         .padding()
         .interactiveDismissDisabled()
         .presentationDetents([.height(200), .large])
         .presentationBackground(.regularMaterial)
         .presentationBackgroundInteraction(.enabled(upThrough: .large))
     }

     private func didTapOnCompletion(_ completion: SearchCompletions) {
         Task {
             if let singleLocation = try? await locationService.search(with: "\(completion.title) \(completion.subTitle)").first {
                 searchResults = [singleLocation]
             }
         }
     }
 }

 struct SearchCompletions: Identifiable {
     let id = UUID()
     let title: String
     let subTitle: String
     var url: URL?
 }

 struct SearchResult: Identifiable, Hashable {
     let id = UUID()
     let location: CLLocationCoordinate2D
     let title: String

     static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
         lhs.id == rhs.id
     }

     func hash(into hasher: inout Hasher) {
         hasher.combine(id)
     }
 }

 @Observable
 class LocationService: NSObject, MKLocalSearchCompleterDelegate {
     private let completer: MKLocalSearchCompleter
     var completions = [SearchCompletions]()

     init(completer: MKLocalSearchCompleter) {
         self.completer = completer
         super.init()
         self.completer.delegate = self
     }

     func update(queryFragment: String) {
         completer.resultTypes = .pointOfInterest
         completer.queryFragment = queryFragment
     }

     func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
         completions = completer.results.map { completion in
             let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
             return .init(
                 title: completion.title,
                 subTitle: completion.subtitle,
                 url: mapItem?.url
             )
         }
     }

     func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResult] {
         let request = MKLocalSearch.Request()
         request.naturalLanguageQuery = "\(query) golf"
         request.resultTypes = .pointOfInterest
         if let coordinate {
             request.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
         }
         let search = MKLocalSearch(request: request)
         let response = try await search.start()

         return response.mapItems.compactMap { mapItem in
             guard let location = mapItem.placemark.location?.coordinate else { return nil }
             return .init(location: location, title: mapItem.name ?? "")
         }
     }
 }

 struct TextFieldGrayBackgroundColor: ViewModifier {
     func body(content: Content) -> some View {
         content
             .padding(12)
             .background(Color.gray.opacity(0.1))
             .cornerRadius(8)
             .foregroundColor(.primary)
     }
 }

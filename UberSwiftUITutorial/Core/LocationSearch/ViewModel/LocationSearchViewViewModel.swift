//
//  LocationSearchViewViewModel.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 09/06/23.
//

import Foundation
import MapKit

class LocationSearchViewViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedLocationCoordinate: CLLocationCoordinate2D?
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFragment = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - Helpers
    func selectLocation(_ localSearch: MKLocalSearchCompletion) {
        Task {
            do {
                let response = try await locationSearch(forLocationSearchCompletion: localSearch)
                guard let item = response.mapItems.first else { return }
                let coordinate = item.placemark.coordinate
                DispatchQueue.main.async { [weak self] in
                    self?.selectedLocationCoordinate = coordinate
                }
                print("DEBUG: Location coordinates: \(coordinate)")
            } catch {
                print("DEBUG: Location search failed with error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func locationSearch(forLocationSearchCompletion localSearch: MKLocalSearchCompletion) async throws -> MKLocalSearch.Response {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        let response = try await search.start()
        return response
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchViewViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
}

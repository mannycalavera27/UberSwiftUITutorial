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
    @Published var selectedUberLocation: UberLocation?
    @Published var pickupTime: String?
    @Published var dropOffTime: String?
    
    private let searchCompleter = MKLocalSearchCompleter()
    
    var queryFragment = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var userLocation: CLLocationCoordinate2D?
    
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
                    self?.selectedUberLocation = UberLocation(title: localSearch.title, coordinate: coordinate)
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
    
    func computeRidePrice(for type: RideType) -> Double {
        guard let destCoordinate = selectedUberLocation?.coordinate else { return 0.0 }
        guard let userCoordinate = self.userLocation else { return 0.0 }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude,
                                      longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: destCoordinate.latitude,
                                     longitude: destCoordinate.longitude)
        let tripDistanceInMeters = userLocation.distance(from: destination)
        return type.computePrice(for: tripDistanceInMeters)
    }
    
    func getDestinationRoute(
        from userLocation: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async throws -> MKRoute? {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        let directions = MKDirections(request: request)
        guard let route = try await directions.calculate().routes.first else { return nil }
        configurePickupAndDropOffTimes(with: route.expectedTravelTime)
        return route
    }
    
    func configurePickupAndDropOffTimes(with expedtedTravelTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickupTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expedtedTravelTime)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension LocationSearchViewViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }
}

//
//  UberMapViewRepresentable.swift
//  UberSwiftUITutorial
//
//  Created by Tiziano Cialfi on 09/06/23.
//

import SwiftUI
import MapKit

struct UberMapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    @Binding var mapState: MapViewState
    @EnvironmentObject var locationSearchViewViewModel: LocationSearchViewViewModel
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch mapState {
            case .noInput:
                context.coordinator.clearMapViewAndRecenterOnUserLocation()
                break
            case .searchingForLocation:
                break
            case .locationSelected:
                if let coordinate = locationSearchViewViewModel.selectedUberLocation?.coordinate {
                    context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                    context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)
                }
                break
            case .polylineAdded:
                break
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(parent: self)
    }
}

extension UberMapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properties
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        
        // MARK: - Lifecycle
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            userLocationCoordinate = userLocation.coordinate
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation.coordinate.latitude,
                    longitude: userLocation.coordinate.longitude
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            currentRegion = region
            parent.mapView.setRegion(region, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        // MARK: - Helpers
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            parent.mapView.addAnnotation(annotation)
            parent.mapView.selectAnnotation(annotation, animated: true)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocationCoordinate = self.userLocationCoordinate else { return }
            Task {
                do {
                    guard let route = try await parent.locationSearchViewViewModel.getDestinationRoute(
                        from: userLocationCoordinate,
                        to: coordinate
                    ) else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.parent.mapView.addOverlay(route.polyline)
                        strongSelf.parent.mapState = .polylineAdded
                        let rect = strongSelf.parent.mapView.mapRectThatFits(
                            route.polyline.boundingMapRect,
                            edgePadding: .init(top: 64, left: 32, bottom: 500, right: 32)
                        )
                        strongSelf.parent.mapView.setRegion(.init(rect), animated: true)
                    }
                } catch {
                    print("DEBUG: Failed to get directions with error: \(error.localizedDescription)")
                }
            }
            
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            if let currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
    }
}

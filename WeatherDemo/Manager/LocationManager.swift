import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    
    @Published var isLoading = false
    @Published var location: CLLocationCoordinate2D? // Stores latest coordinates
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isLoading = true
        
        // Request authorization if not determined
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        
        // Request single location update
        manager.requestLocation()
    }
    
    // Called when location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        isLoading = false
    }
    
    // Called on failure
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location:", error)
        isLoading = false
    }
    
    // Called when permission changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

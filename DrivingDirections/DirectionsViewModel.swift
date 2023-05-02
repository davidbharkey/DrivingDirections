//
//  DirectionsViewModel.swift
//  DrivingDirections
//
//  Created by David Harkey on 12/27/21.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
class DirectionsViewModel: ObservableObject {
    
    @Published var steps: [MKRoute.Step] = []
    @Published var eta: String = ""
    @Published var distance: String = ""
    
    func calculateETA(time: TimeInterval) -> String {
        var returnString = ""
        let timeInt = Int(time)
        
        let hours = timeInt / 60 / 60
        if hours >= 1 {
            returnString += "\(hours) hours, "
        }
        
        let minutes = (timeInt - (hours * 60 * 60)) / 60
        if minutes >= 1 {
            returnString += "\(minutes) minutes"
        }
        return returnString
    }
    
    func calculateDirections(from: String, to: String) async {
        do {
            guard let startPlacemark = try await getPlacemarkBy(address: from),
                  let destinationPlacemark = try await getPlacemarkBy(address: to) else {
                      return
                  }
            
            let directionsRequest = MKDirections.Request()
            directionsRequest.transportType = .automobile
            directionsRequest.source = MKMapItem(placemark: MKPlacemark(placemark: startPlacemark))
            directionsRequest.destination = MKMapItem(placemark: MKPlacemark(placemark: destinationPlacemark))
          
            let directions = MKDirections(request: directionsRequest)
            let response = try await directions.calculate()
            
            guard let route = response.routes.first else {
                return
            }
            
            eta = calculateETA(time: route.expectedTravelTime)
            steps = route.steps
            distance = String(format: "%.2f miles", (route.distance * 0.000621))
            
        } catch {
            print(error)
        }
    }
    
    private func getPlacemarkBy(address: String) async throws -> CLPlacemark? {
        let geocoder = CLGeocoder()
        let placemark = try await geocoder.geocodeAddressString(address)
        return placemark.first
    }
}

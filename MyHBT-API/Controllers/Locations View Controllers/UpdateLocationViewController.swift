//
//  UpdateLocationViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/27/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Mapbox

class UpdateLocationViewController: UITableViewController, MGLMapViewDelegate {
    // The map view which will show last updated location of the user
    @IBOutlet weak var lastUpdatedLocationMapView: MGLMapView!
    
    // The map view which will show current location of the user
    @IBOutlet weak var currentLocationMapView: MGLMapView!
    
    // The text field which will hold description of the current location of the user
    @IBOutlet weak var locationDescription: UITextField!
    
    // The update location button
    @IBAction func updateLocationButton(_ sender: UIButton) {
        // Get current latitude and longitude of the user
        let userCurrentLatitude = Double (currentLocationMapView.userLocation!.coordinate.latitude)
        let userCurrentLongitude = Double (currentLocationMapView.userLocation!.coordinate.longitude)
        
        // Call the function to update user's location
        updateUserLocation(userLocationLatitude: userCurrentLatitude, userLocationLongitude: userCurrentLongitude, userLocationDescription: locationDescription.text!)
    }
    
    // Location repository
    let locationRepository = LocationRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate map
        currentLocationMapView.delegate = self
        lastUpdatedLocationMapView.delegate = self
        
        //------------------------ SHOW USER'S CURRENT LOCATION ------------------------
        currentLocationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Enable heading tracking mode so that the arrow will appear.
        currentLocationMapView.userTrackingMode = .followWithHeading

        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        currentLocationMapView.showsUserHeadingIndicator = true
        //------------------------ END SHOW USER'S CURRENT LOCATION ------------------------
        
        // Call the function to pin last updated location of the user on the map
        getInfoOfCurrentUserAndPinLastUdpatedLocation()
    }
    
    //********************************************* DELEGATE METHODS FOR THE MAP VIEW *********************************************
    // The function to show location's description when the marker is tapped
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always allow callouts to popup when annotations are tapped.
        return true
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // Substitute our custom view for the user location annotation. This custom view is defined below.
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            return CustomUserLocationAnnotationView()
        }
        return nil
    }

    /*
    // Optional: tap the user location annotation to toggle heading tracking mode.
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if mapView.userTrackingMode != .followWithHeading {
            mapView.userTrackingMode = .followWithHeading
        } else {
            mapView.resetNorth()
        }

        // We're borrowing this method as a gesture recognizer, so reset selection state.
        mapView.deselectAnnotation(annotation, animated: false)
    }
    */
    //********************************************* END DELEGATE METHODS FOR THE MAP VIEW *********************************************
    
    //********************************************* GET LAST UPDATED LOCATION OF THE USER SEQUENCE *********************************************
    /*
     In this sequence, we will do 2 things
     1. Get info of the currently logged in user
     2. Get the user's location
     3. Pin it on the map
     */
    
    // The function to get info of the currently logged in user
    func getInfoOfCurrentUserAndPinLastUdpatedLocation() {
        // Call the function to get last updated location of the currently logged in user and pin it on map
        self.locationRepository.getLocationInfoOfLastUpdatedLocationOfCurrentUser {(userFullName, userLocationDescription, userLatitude, userLongitude) in
            DispatchQueue.main.async {
                // Call the function to pin user on map
                self.pinUserOnMap(latitude: userLatitude, longitude: userLongitude, locationDescription: userLocationDescription, userFullName: userFullName)
            }
        }
    }
    
    // The function to pin user on the map
    func pinUserOnMap(latitude: Double, longitude: Double, locationDescription: String, userFullName: String) {
        // Add a point annotation
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        annotation.title = userFullName
        annotation.subtitle = locationDescription
        lastUpdatedLocationMapView.addAnnotation(annotation)
    }
    //********************************************* END GET LAST UPDATED LOCATION OF THE USER SEQUENCE *********************************************
    
    //********************************************* UPDATE LOCATION SEQUENCE *********************************************
    /*
     In this sequence, we will do 2 things
     1. Get info of the current user
     2. Update location of the user
     */
    
    // The function to update user location
    func updateUserLocation(userLocationLatitude: Double, userLocationLongitude: Double, userLocationDescription: String) {
        // Call the function to update location of the currently logged in user
        locationRepository.updateCurrentUserLocation(userLocationLongitude: userLocationLongitude, userLocationLatitude: userLocationLatitude, userLocationDescription: userLocationDescription)
    }
    //********************************************* END UPDATE LOCATION SEQUENCE *********************************************
}

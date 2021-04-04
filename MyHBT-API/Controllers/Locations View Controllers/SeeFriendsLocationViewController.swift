//
//  SeeFriendsLocationViewController.swift
//  MyHBT-API
//
//  Created by Vũ Trương on 11/26/20.
//  Copyright © 2020 beta. All rights reserved.
//

import UIKit
import Mapbox

class SeeFriendsLocationViewController: UIViewController, MGLMapViewDelegate {
    // The map view which will be used to display friends location
    @IBOutlet weak var seeFriendsLocationMapView: MGLMapView!
    
    // Location repository
    let locationRepository = LocationRepository()
    
    // Follow repository
    let followRepository = FollowRepository()
    
    // User repository
    let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate map
        seeFriendsLocationMapView.delegate = self
        
        //------------------------ SHOW USER'S CURRENT LOCATION ------------------------
        seeFriendsLocationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Enable heading tracking mode so that the arrow will appear.
        seeFriendsLocationMapView.userTrackingMode = .followWithHeading

        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        seeFriendsLocationMapView.showsUserHeadingIndicator = true
        //------------------------ END SHOW USER'S CURRENT LOCATION ------------------------
        
        // Add a point annotation
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.77014, longitude: -73.97480)
        annotation.title = "Central Park"
        annotation.subtitle = "The biggest park in New York City!"
        seeFriendsLocationMapView.addAnnotation(annotation)
        
        // Call the function to get list of following of the user and pin them on the map
        getListOfFollowingOfCurrentUserAndPinOnMap()
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
    
    //********************************************* GET FRIENDS LOCATION SEQUENCE *********************************************
    /*
     In this sequence, we will do 3 things
     1. Get info of the currently logged in user
     2. Get list of following of the user
     3. Get their location
     4. Pin them on the map
     */
    
    // The function to get list of following of the currently logged in user and pin them on map
    func getListOfFollowingOfCurrentUserAndPinOnMap() {
        // Call the function to get info of the currently logged in user
        userRepository.getInfoOfCurrentUser { (userObject) in
            // Call the function to get list of following of the currently logged in user
            self.userRepository.getListOfFollowing(follower: userObject._id) { (arrayOfFollow) in
                // Loop through the array of following and pin them on map
                for follow in arrayOfFollow {
                    // Call the function to get user location info based on user id and pin them on map
                    self.getUserLocationInfoBasedOnIdAndPinOnMap(userId: follow.following)
                }
            }
        }
    }
    
    // The function to get user location info based on user id and pin on map
    func getUserLocationInfoBasedOnIdAndPinOnMap(userId: String) {
        // Call the function to get location info of user with specified user id
        self.locationRepository.getLocationInfoOfUserBasedOnId(userId: userId) { (userFullName, userLocationDescription, userLatitude, userLongitude) in
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
        seeFriendsLocationMapView.addAnnotation(annotation)
    }
    //********************************************* GET FRIENDS LOCATION SEQUENCE *********************************************
}

// Create a subclass of MGLUserLocationAnnotationView.
// This is created in order to pin user on the map
class CustomUserLocationAnnotationView: MGLUserLocationAnnotationView {
    let size: CGFloat = 48
    var dot: CALayer!
    var arrow: CAShapeLayer!

    // -update is a method inherited from MGLUserLocationAnnotationView. It updates the appearance of the user location annotation when needed. This can be called many times a second, so be careful to keep it lightweight.
    override func update() {
        if frame.isNull {
            frame = CGRect(x: 0, y: 0, width: size, height: size)
            return setNeedsLayout()
        }

        // Check whether we have the user’s location yet.
        if CLLocationCoordinate2DIsValid(userLocation!.coordinate) {
            // GET COORDINATE OF THE USER AT THIS POINT HERE :)))))))))))))
            let userLocationParam = userLocation!.coordinate
            print(userLocationParam)
            
            setupLayers()
            updateHeading()
        }
    }

    private func updateHeading() {
        // Show the heading arrow, if the heading of the user is available.
        if let heading = userLocation!.heading?.trueHeading {
            arrow.isHidden = false

            // Get the difference between the map’s current direction and the user’s heading, then convert it from degrees to radians.
            let rotation: CGFloat = -MGLRadiansFromDegrees(mapView!.direction - heading)

            // If the difference would be perceptible, rotate the arrow.
            if abs(rotation) > 0.01 {
                // Disable implicit animations of this rotation, which reduces lag between changes.
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                arrow.setAffineTransform(CGAffineTransform.identity.rotated(by: rotation))
                CATransaction.commit()
            }
        } else {
            arrow.isHidden = true
        }
    }

    private func setupLayers() {
        // This dot forms the base of the annotation.
        if dot == nil {
            dot = CALayer()
            dot.bounds = CGRect(x: 0, y: 0, width: size, height: size)

            // Use CALayer’s corner radius to turn this layer into a circle.
            dot.cornerRadius = size / 2
            dot.backgroundColor = super.tintColor.cgColor
            dot.borderWidth = 4
            dot.borderColor = UIColor.white.cgColor
            layer.addSublayer(dot)
        }

        // This arrow overlays the dot and is rotated with the user’s heading.
        if arrow == nil {
            arrow = CAShapeLayer()
            arrow.path = arrowPath()
            arrow.frame = CGRect(x: 0, y: 0, width: size / 2, height: size / 2)
            arrow.position = CGPoint(x: dot.frame.midX, y: dot.frame.midY)
            arrow.fillColor = dot.borderColor
            layer.addSublayer(arrow)
        }
    }

    // Calculate the vector path for an arrow, for use in a shape layer.
    private func arrowPath() -> CGPath {
        let max: CGFloat = size / 2
        let pad: CGFloat = 3

        let top =    CGPoint(x: max * 0.5, y: 0)
        let left =   CGPoint(x: 0 + pad,   y: max - pad)
        let right =  CGPoint(x: max - pad, y: max - pad)
        let center = CGPoint(x: max * 0.5, y: max * 0.6)

        let bezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addLine(to: center)
        bezierPath.addLine(to: right)
        bezierPath.addLine(to: top)
        bezierPath.close()

        return bezierPath.cgPath
    }
}

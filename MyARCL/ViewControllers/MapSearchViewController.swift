//
//  MapSearchViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import MapKit
import ARKit

protocol MapSearchVCDelegate: AnyObject {
    func navigateInAR(with routeData: [RouteLeg])
}

class MapSearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = MKMapView()
    private let instructionsLabel = UILabel()
    
    private var currRouteLegs = [[CLLocationCoordinate2D]]()
    private var routeLegs = [RouteLeg]()
    private var routeSteps = [MKRoute.Step]()
    var routeData: [RouteLeg]!
    
    private var mapAnnotations = [Annotation]()
    
    private var locations = [CLLocation]()
    
    private var startLocation: CLLocation! {
        didSet {
            centerInitialMap()
            locManager.locationManager?.stopUpdatingLocation()
        }
    }
    
    private var destinationLocation: CLLocationCoordinate2D! {
        didSet {
            createRouteToDestination()
        }
    }
    
    private var locManager = Location()
    
    weak var delegate: MapSearchVCDelegate?
    
    private var pointColor = UIColor.systemPink
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Methods
    
    func setupUI() {
        navigationController?.isNavigationBarHidden = true
        setupMapView()
        setupInstructionsLabel()
        
        if ARConfiguration.isSupported {
            locManager.delegate = self
            locManager.startUpdatingLocation(locationManager: locManager.locationManager!)
            
            let screenPress = UILongPressGestureRecognizer(target: self, action: #selector(setDestinationLocationOnMap))
            screenPress.minimumPressDuration = 0.3
            mapView.addGestureRecognizer(screenPress)
            mapView.delegate = self
        } else {
            print("ARKit functionality is not supported by your phone :(")
            return
        }
    }
    
    @objc func setDestinationLocationOnMap(_ gesture: UIGestureRecognizer) {
        instructionsLabel.isHidden = true
        
        if gesture.state != UIGestureRecognizer.State.began { return }
        let tapPoint = gesture.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        destinationLocation = coordinate
    }
    
    func setupMapView() {
        mapView.isZoomEnabled = true
        mapView.isPitchEnabled = true
        mapView.isUserInteractionEnabled = true
        mapView.showsBuildings = true
        mapView.isRotateEnabled = true
        mapView.showsCompass = true
        mapView.showsUserLocation = true
        self.view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setupInstructionsLabel() {
        instructionsLabel.text = "Press on a place\nyou wanna go"
        instructionsLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        instructionsLabel.textColor = .lightGray
        instructionsLabel.textAlignment = .center
        instructionsLabel.numberOfLines = 0
        self.mapView.addSubview(instructionsLabel)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor).isActive = true
        instructionsLabel.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor).isActive = true
    }
    
    private func createRouteToDestination() {
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            if let destinationLocation = self.destinationLocation {
                
                let request = MKDirections.Request()
                destinationLocation.getRouteStepsTo(with: request) { steps in
                    steps.forEach {
                        let annotation = Annotation(title: "T " + $0.instructions, coordinate: $0.locationFromStep().coordinate)
                        self.mapAnnotations.append(annotation)
                    }
                    
                    self.routeSteps.append(contentsOf: steps)
                    group.leave()
                }
            }
            group.wait()
            self.splitRouteIntoLegs()
        }
    }
    
    private func splitRouteIntoLegs() {
        for (index, step) in routeSteps.enumerated() {
            self.createRouteLeg(to: step, at: index)
        }
        
        for leg in routeLegs { updateArrays(with: leg.coordinates) }
        for leg in currRouteLegs { updateArrays(with: leg) }
        
        self.updateRoute(with: self.routeLegs)
    }
    
    func createRouteLeg(to nextRouteStep: MKRoute.Step, at stepIndex: Int) {
        if stepIndex == 0 {
            let nextLocation = CLLocation(latitude: nextRouteStep.polyline.coordinate.latitude,
                                          longitude: nextRouteStep.polyline.coordinate.longitude)
            
            let intermediateSteps = CLLocationCoordinate2D.getIntermediateLocations(from: startLocation, to: nextLocation)
            currRouteLegs.append(intermediateSteps)
            
            let routeLeg = RouteLeg(directions: nextRouteStep.instructions, coordinates: intermediateSteps)
            if !routeLegs.contains(routeLeg) { routeLegs.append(routeLeg) }
        } else {
            let prevStep = routeSteps[stepIndex - 1]
            let prevLocation = CLLocation(latitude: prevStep.polyline.coordinate.latitude,
                                          longitude: prevStep.polyline.coordinate.longitude)
            
            let nextLocation = CLLocation(latitude: nextRouteStep.polyline.coordinate.latitude,
                                          longitude: nextRouteStep.polyline.coordinate.longitude)
            
            let intermediateSteps = CLLocationCoordinate2D.getIntermediateLocations(from: prevLocation, to: nextLocation)
            currRouteLegs.append(intermediateSteps)
            
            let routeLeg = RouteLeg(directions: nextRouteStep.instructions, coordinates: intermediateSteps)
            if !routeLegs.contains(routeLeg) { routeLegs.append(routeLeg) }
        }
    }
    
    // Add calculated distances to mapAnnotations and locations arrays.
    private func updateArrays(with locations: [CLLocationCoordinate2D]) {
        for location in locations {
            let annotation = Annotation(title: String(describing: location), coordinate: location)
            self.mapAnnotations.append(annotation)
            
            let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
            self.locations.append(location)
        }
    }
    
    func updateRoute(with legs: [RouteLeg]) {
        routeData = legs
        
        for (index, leg) in legs.enumerated() {
            
            // Select starting location from all.
            if index == 0 && leg.coordinates.count == 0 {
                let startAnnotation = Annotation(title: "T" + leg.directions, coordinate: self.startLocation.coordinate)
                self.mapAnnotations.append(startAnnotation)
            }
            
            for coordinate in leg.coordinates {
                let annotation = Annotation(title: String(describing: coordinate), coordinate: coordinate)
                self.mapAnnotations.append(annotation)
            }
        }
        
        createRouteOnMap(with: legs)
        addAnnotationsToMap()
        showConfirmationAlert()
    }
    
    func createRouteOnMap(with currRouteLegs: [RouteLeg]) {
        mapView.removeAnnotations(mapView.annotations)
        
        for routeLeg in currRouteLegs {
            for coordinate in routeLeg.coordinates {
                let annotation = Annotation(title: String(describing: coordinate), coordinate: coordinate)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addAnnotationsToMap() {
        for annotation in mapAnnotations {
            DispatchQueue.main.async {
                if let title = annotation.title, title.hasPrefix("T") {
                    self.pointColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                } else {
                    self.pointColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                }
                
                self.mapView.addAnnotation(annotation)
                
                let circle = MKCircle(center: annotation.coordinate, radius: 0.2)
                self.mapView.addOverlay(circle)
            }
        }
    }
    
    private func showConfirmationAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let alert = UIAlertController(title: "Navigate to selected destination?", message: "😊", preferredStyle: .alert)
            
            // Selected route is canceled.
            let chooseAnotherAction = UIAlertAction(title: "Choose another", style: .cancel, handler: { action in
                self.removeAll()
            })
            
            // Proceed with selected route.
            let okayAction = UIAlertAction(title: "Let's go!", style: .default, handler: { action in
                if self.routeData != nil {
                    self.delegate?.navigateInAR(with: self.routeData)
                }
            })
            
            alert.addAction(chooseAnotherAction)
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func removeAll() {
        DispatchQueue.main.async {
            self.destinationLocation = nil
            self.locations.removeAll()
            self.currRouteLegs.removeAll()
            self.mapAnnotations.removeAll()
            self.routeSteps.removeAll()
            self.routeLegs.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
}

// MARK: - LocationDelegate

extension MapSearchViewController: LocationDelegate, AlertMessage {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    func trackingLocationDidFail(with error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
    
    func trackingLocation(for currentLocation: CLLocation) {
        startLocation = currentLocation
        centerInitialMap()
    }
    
    func centerInitialMap() {
        if startLocation != nil {
            self.mapView.setCenter(self.startLocation.coordinate, animated: true)
            let span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            let region = MKCoordinateRegion(center: self.startLocation.coordinate, span: span)
            self.mapView.setRegion(region, animated: false)
        }
    }
}

// MARK: - MKMapViewDelegate

extension MapSearchViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let mapCircle = MKCircleRenderer(overlay: overlay)
        mapCircle.strokeColor = pointColor
        mapCircle.lineWidth = 2
        return mapCircle
    }
}

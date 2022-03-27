//
//  MapSearchViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import MapKit
import ARKit

protocol MapSearchVCDelegate: class {
    func navigateInAR(data: [RouteLeg])
}

class MapSearchViewController: UIViewController {
    
    // MARK: - Properties
    
    private var currRouteLegs: [[CLLocationCoordinate2D]] = []
    
    private var routeLegs: [RouteLeg] = []
    
    private var locations: [CLLocation] = []
    
    private var routeSteps: [MKRoute.Step] = []
    
    var routeData: [RouteLeg]!
    
    private var points: [Annotation] = []
    
    private var startLocation: CLLocation! {
        didSet {
            self.centerInitialMap()
            locationMngr.locationManager?.stopUpdatingLocation()
        }
    }
    
    private var locationMngr = Location()
    
    private var destLocation: CLLocationCoordinate2D! {
        didSet {
            createStepsRoute()
        }
    }
    
    weak var delegate: MapSearchVCDelegate?
    
    private var pointColor = UIColor.systemPink
    
    let mapView = MKMapView()
    let instructionsLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Methods
    
    func setup() {
        navigationController?.isNavigationBarHidden = true
        setupMapView()
        setupLabel()
        
        if ARConfiguration.isSupported {
            locationMngr.delegate = self
            locationMngr.startUpdatingLocation(locationManager: locationMngr.locationManager!)
            
            let screenPress = UILongPressGestureRecognizer(target: self, action: #selector(setDestLocationOnMap(_:)))
            screenPress.minimumPressDuration = 0.3
            mapView.addGestureRecognizer(screenPress)
            mapView.delegate = self
        } else {
            print("ARKit functionality is not supported by your phone :(")
            return
        }
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
    
    func setupLabel() {
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
    
    @objc func setDestLocationOnMap(_ gesture: UIGestureRecognizer) {
        
        instructionsLabel.isHidden = true
        
        if gesture.state != UIGestureRecognizer.State.began { return }
        let tapPoint = gesture.location(in: mapView)
        let coordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        destLocation = coordinate
    }
    
    private func createStepsRoute() {
        
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.global(qos: .default).async {
            
            if self.destLocation != nil {
                
                self.getStepsBetweenLocs(destLocation: self.destLocation,
                                         req: MKDirections.Request()) { steps in
                    
                    for step in steps {
                        self.points.append(Annotation(title: "T " + step.instructions,
                                           coordinate: step.locationFromStep().coordinate))
                    }
                    
                    self.routeSteps.append(contentsOf: steps)
                    group.leave()
                }
            }
            group.wait()
            
            self.formLegs()
        }
    }
    
    func formLegs() {
        
        for (index, step) in self.routeSteps.enumerated() {
            self.createRouteLegFrom(step, index)
        }
        
        for leg in routeLegs { update(interLocs: leg.coordinates) }
        
        for leg in currRouteLegs { update(interLocs: leg) }
        
        self.updateRoute(with: self.routeLegs)
    }
    
    func updateRoute(with legs: [RouteLeg]) {
        
        routeData = legs
        
        for (index, leg) in legs.enumerated() {
            
            /// select starting location from all
            if index == 0 && leg.coordinates.count == 0 {
                self.points.append(Annotation(title: "T" + leg.directions, // turn point
                                              coordinate: self.startLocation.coordinate))
            }
            
            for coord in leg.coordinates {
                self.points.append(Annotation(title: String(describing: coord),
                                              coordinate: coord))
            }
        }
        
        createRouteOnMap(currRouteLegs: legs)
        addPointsOnMap()
        
        showConfirmation()
    }
    
    private func showConfirmation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            let alert = UIAlertController(title: "Navigate to selected destination?", message: "😊", preferredStyle: .alert)
            
            /// selected route is canceled
            let chooseAnotherAction = UIAlertAction(title: "Choose another", style: .cancel, handler: { action in
                self.removeAll()
            })
            
            /// proceed with selected route
            let okayAction = UIAlertAction(title: "Let's go!", style: .default, handler: { action in
                if self.routeData != nil {
                    self.delegate?.navigateInAR(data: self.routeData)
                }
            })
            
            alert.addAction(chooseAnotherAction)
            alert.addAction(okayAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func removeAll() {
        DispatchQueue.main.async {
            self.destLocation = nil
            self.locations.removeAll()
            self.currRouteLegs.removeAll()
            self.points.removeAll()
            self.routeSteps.removeAll()
            self.routeLegs.removeAll()
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
        }
    }
}

// MARK: -
extension MapSearchViewController {
    
    /// add calculated distances to points and locations arrays
    private func update(interLocs: [CLLocationCoordinate2D]) {
        for loc in interLocs {
            points.append(Annotation(title: String(describing: loc),
                                     coordinate: loc))
            
            self.locations.append(CLLocation(latitude: loc.latitude,
                                             longitude: loc.longitude))
        }
    }
    
    func createRouteOnMap(currRouteLegs: [RouteLeg]) {
        mapView.removeAnnotations(mapView.annotations)
        
        for routeLeg in currRouteLegs {
            for coordinate in routeLeg.coordinates {
                let annotation = Annotation(title: String(describing: coordinate),
                                            coordinate: coordinate)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func addPointsOnMap() {
        for point in points {
            DispatchQueue.main.async {
                if let title = point.title, title.hasPrefix("T") { self.pointColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1) }
                else { self.pointColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) }
                
                self.mapView.addAnnotation(point)
                self.mapView.addOverlay(MKCircle(center: point.coordinate, radius: 0.2))
            }
        }
    }
}

// MARK: - LocationDelegate

extension MapSearchViewController: LocationDelegate, AlertMessage {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    /// once location is tracking - zoom in and center map
    func trackingLocation(for currentLocation: CLLocation) {
        startLocation = currentLocation
        centerInitialMap()
    }
    
    func trackingLocationDidFail(with error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
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
        let cr = MKCircleRenderer(overlay: overlay)
        cr.strokeColor = pointColor
        cr.lineWidth = 2
        return cr
    }
}

// MARK: -
extension MapSearchViewController {
    
    func createRouteLegFrom(_ routeStep: MKRoute.Step, _ index: Int) {
        
        // first leg
        if index == 0 {
            let nextLocation = CLLocation(latitude: routeStep.polyline.coordinate.latitude,
                                          longitude: routeStep.polyline.coordinate.longitude)
            
            let interSteps = CLLocationCoordinate2D.getInterLocs(currLocation: startLocation,
                                                                 destLocation: nextLocation)
            currRouteLegs.append(interSteps)
            
            let routeLeg = RouteLeg(directions: routeStep.instructions, coordinates: interSteps)
            
            if !routeLegs.contains(routeLeg) { routeLegs.append(routeLeg) }
        }
        // another legs
        else {
            let prevStep = routeSteps[index - 1]
            let prevLocation = CLLocation(latitude: prevStep.polyline.coordinate.latitude,
                                          longitude: prevStep.polyline.coordinate.longitude)
            
            let nextLocation = CLLocation(latitude: routeStep.polyline.coordinate.latitude,
                                          longitude: routeStep.polyline.coordinate.longitude)
            
            let interSteps = CLLocationCoordinate2D.getInterLocs(currLocation: prevLocation,
                                                                 destLocation: nextLocation)
            currRouteLegs.append(interSteps)
            
            let routeLeg = RouteLeg(directions: routeStep.instructions, coordinates: interSteps)
            
            if !routeLegs.contains(routeLeg) { routeLegs.append(routeLeg) }
        }
    }
}

// MARK: -
extension MapSearchViewController {
    
    // MKRoute - whole route from start to the end
    // MKRoute.Step - each step of this route
    // MKPlacemark - info about coordinate (city, address)
    // MKMapItem - point on the map (its address and description)
    // MKDirections - directions based on the route
    // MKDirections.Request - to get those directions from server
    
    func getStepsBetweenLocs(destLocation: CLLocationCoordinate2D, req: MKDirections.Request,
                             completion: @escaping ([MKRoute.Step]) -> Void) {
        
        var steps: [MKRoute.Step] = []
        
        let dest = MKPlacemark(coordinate: destLocation)
        
        req.destination = MKMapItem.init(placemark: dest)
        req.source = MKMapItem.forCurrentLocation()
        req.transportType = .walking
        req.requestsAlternateRoutes = false
        
        // calculate route steps using directions
        MKDirections(request: req).calculate { res, err  in
            
            for route in res!.routes { steps.append(contentsOf: route.steps) }
            
            completion(steps)
        }
    }
}

//
//  NavigationViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import ARKit
import MapKit

class NavigationViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Properties

    private let sceneView = ARSCNView()
    private let instructionsLabel = UILabel()
    private let lastLocationInLegLabel = UILabel()
    private let userLocationLabel = UILabel()
    private let consoleLabel = UILabel()
    private var miniMap: MKMapCompassView!
    
    private var sphereNodes: [SphereNode] = []
    private var spheresAnchors: [ARAnchor] = []
    
    internal var startLocation: CLLocation!
    private var updatedLocations: [CLLocation] = []
    
    private var currentLeg: Int = 1
    private var currentLocation = CLLocation()
    
    private var routeUpdated = false
    
    var routeData: [RouteLeg]!
    
    private var configuration = ARWorldTrackingConfiguration()
    
    private var locationService = Location()
    let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        screenTouched()
    }
    
    // MARK: - Methods
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        sceneView.preferredFramesPerSecond = 30
        sceneView.showsStatistics = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.isUserInteractionEnabled = true
        self.view.addSubview(sceneView)
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        instructionsLabel.text = "Tap to create a route"
        instructionsLabel.textColor = .white
        instructionsLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.sceneView.addSubview(instructionsLabel)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.centerYAnchor.constraint(equalTo: self.sceneView.centerYAnchor).isActive = true
        instructionsLabel.centerXAnchor.constraint(equalTo: self.sceneView.centerXAnchor).isActive = true
        
        lastLocationInLegLabel.textColor = .white
        lastLocationInLegLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.sceneView.addSubview(lastLocationInLegLabel)
        lastLocationInLegLabel.translatesAutoresizingMaskIntoConstraints = false
        lastLocationInLegLabel.bottomAnchor.constraint(equalTo: self.sceneView.bottomAnchor, constant: -60).isActive = true
        lastLocationInLegLabel.trailingAnchor.constraint(equalTo: self.sceneView.trailingAnchor, constant: -10).isActive = true
        
        userLocationLabel.textColor = .white
        userLocationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.sceneView.addSubview(userLocationLabel)
        userLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        userLocationLabel.bottomAnchor.constraint(equalTo: self.lastLocationInLegLabel.topAnchor, constant: -10).isActive = true
        userLocationLabel.trailingAnchor.constraint(equalTo: self.sceneView.trailingAnchor, constant: -10).isActive = true
        
        consoleLabel.textColor = .white
        consoleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.sceneView.addSubview(consoleLabel)
        consoleLabel.translatesAutoresizingMaskIntoConstraints = false
        consoleLabel.bottomAnchor.constraint(equalTo: self.userLocationLabel.topAnchor, constant: -10).isActive = true
        consoleLabel.trailingAnchor.constraint(equalTo: self.sceneView.trailingAnchor, constant: -10).isActive = true
        
        miniMap = MKMapCompassView(frame: CGRect(x: 20, y: 20, width: view.bounds.width / 2.7, height: view.bounds.width / 2.7))
        miniMap.tintColor = .black
        miniMap.delegate = self
        view.insertSubview(miniMap, aboveSubview: sceneView)
        miniMap.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
        miniMap.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12).isActive = true
        miniMap.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
        miniMap.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3).isActive = true
    }
    
    private func setupLocating() {
        locationService.startUpdatingLocation(locationManager: locationService.locationManager!)
        locationService.delegate = self
        
        runARSession()
    }
    
    private func runARSession() {
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = false
        configuration.videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats[1]
        /* 0 - imageResolution=(1920, 1440) framesPerSecond=(60)
           1 - imageResolution=(1920, 1080) framesPerSecond=(60)
           2 - imageResolution=(1280, 720) framesPerSecond=(60) */
        
        sceneView.session.run(configuration)
    }
    
    private func updateARRoute() {
        if updatedLocations.count > 0 {
            startLocation = CLLocation().mostAccurateLocationFrom(updatedLocations)
            updateNodesLocations()
        }
    }
    
    private func updateNodesLocations() {
        for sphere in sphereNodes {
            let transformationMatrix = TransformationMatrix.transformCoordinates(initialLocation: startLocation, location: sphere.location)
            sphere.anchor = ARAnchor(transform: transformationMatrix)
            sphere.position = SCNVector3.transformVectorCoordinates(by: transformationMatrix)
        }
    }
    
    func screenTouched() {
        instructionsLabel.isHidden = true
        
        if updatedLocations.count > 0 {
            startLocation = CLLocation().mostAccurateLocationFrom(updatedLocations)
            
            if startLocation != nil  {
                self.removeAllSphereNodes()
                self.addRouteSpheres(steps: self.routeData)
            }
        }
    }
    
    private func removeAllSphereNodes() {
        for node in self.sphereNodes {
            node.removeFromParentNode()
        }
        self.sphereNodes = []
    }
}

// MARK: - ARSCNViewDelegate

extension NavigationViewController: ARSCNViewDelegate {
    
    private func addLabelSphere(for routeStep: RouteLeg) {
        let stepLocation = CLLocation(latitude: routeStep.coordinates[0].latitude,
                                      longitude: routeStep.coordinates[0].longitude)
        
        let transformedLocation = TransformationMatrix.transformCoordinates(initialLocation: startLocation, location: stepLocation)
        
        let sphereAnchor = ARAnchor(transform: transformedLocation)
        spheresAnchors.append(sphereAnchor)
        
        let sphereNode = SphereNode(title: routeStep.directions, location: stepLocation)
        sphereNode.anchor = sphereAnchor
        sphereNode.location = stepLocation
        sphereNode.addLabelSphere(radius: 0.15,
                                  text: routeStep.directions,
                                  color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        
        sceneView.session.add(anchor: sphereAnchor)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        sphereNodes.append(sphereNode)
    }
    
    private func addSphere(at location: CLLocation) {
        let transformedLocation = TransformationMatrix.transformCoordinates(initialLocation: startLocation, location: location)
        
        let sphereAnchor = ARAnchor(transform: transformedLocation)
        spheresAnchors.append(sphereAnchor)
        
        let sphereNode = SphereNode(title: "Title", location: location)
        sphereNode.anchor = sphereAnchor
        sphereNode.location = location
        sphereNode.addSphere(radius: 0.15, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        
        sceneView.session.add(anchor: sphereAnchor)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        sphereNodes.append(sphereNode)
    }
}

// MARK: - ARSessionDelegate

extension NavigationViewController: ARSessionDelegate {
    
    private func addRouteSpheres(steps: [RouteLeg]) {
        if steps.count == 0 && startLocation == nil { return }
        
        locatingLogic()
        
        let currentLeg = routeData[currentLeg]
        
        for (index, location) in currentLeg.coordinates.enumerated() {
            if index == 0 {
                addLabelSphere(for: currentLeg)
            } else {
                let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
                addSphere(at: location)
            }
        }
    }
    
    private func locatingLogic() {
        if routeUpdated == true && currentLeg < routeData.count {
            currentLeg += 1
        }
        
        /// set bool to next update draw next leg ->  draw only first node -> tap -> update (method fire again) -> getting next leg - drawing next leg
        let currLegLast = routeData[currentLeg].coordinates.last
        guard let currLegLastLoc = currLegLast else { routeUpdated = true; return }
        let lastLocationInCurrLeg = CLLocation(latitude: currLegLastLoc.latitude, longitude: currLegLastLoc.longitude)
        
        // Compare current location with last Location in leg.
        let lastLocationInLeg = lastLocationInCurrLeg.coordinate
        let lastLatitude = lastLocationInLeg.latitude.roundToDouble()
        let lastLongitude = lastLocationInLeg.longitude.roundToDouble()
        
        let currLocation = currentLocation.coordinate
        let currLatitude = currLocation.latitude.roundToDouble()
        let currLongitude = currLocation.longitude.roundToDouble()
        
        lastLocationInLegLabel.text = "Last loc: \(lastLatitude), \(lastLongitude)"
        userLocationLabel.text = "Curr loc: \(currLatitude), \(currLongitude)"
        
        if lastLatitude == currLatitude || lastLongitude == currLongitude {
            if currentLeg < routeData.count {
                currentLeg += 1
                
                let label = "Starting new route leg."
                print("Curr leg: \(currentLeg)")
                consoleLabel.text = label
            } else {
                let label = "You've archived your destionation!"
                print(label)
                consoleLabel.text = label
            }
        } else {
            let label = "Navigating..."
            print(label)
            consoleLabel.text = label
        }
    }
}

// MARK: - LocationDelegate

extension NavigationViewController: LocationDelegate, AlertMessage {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    // Update locations.
    func trackingLocation(for currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 100.0 {
            updatedLocations.append(currentLocation)
            updateARRoute()
            self.currentLocation = currentLocation
        }
    }
    
    func trackingLocationDidFail(with error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
}

extension NavigationViewController {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("Session Failed - probably due to lack of camera access")
        locationService.stopUpdatingLocation(locationManager: locationManager)
        showAlert(title: "Problem while scanning your surroundings!", message: "Please restart the app")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
        sceneView.session.pause()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        sceneView.session.run(session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }
}

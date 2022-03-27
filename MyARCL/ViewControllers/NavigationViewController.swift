//
//  NavigationViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import ARKit
import MapKit

class NavigationViewController: UIViewController {
    
    // MARK: - Properties

    private var sphereNodes: [SphereNode] = []
    
    internal var startLocation: CLLocation!
    
    private var spheresAnchors: [ARAnchor] = []
    
    private var updatedLocs: [CLLocation] = []
    
    private var currLeg: Int = 1
    private var currLocation = CLLocation()
    
    private var methodFiredAgain = false
    
    var routeData: [RouteLeg]!
    
    private var configuration = ARWorldTrackingConfiguration()
    
    private var locationService = Location()
    let locationManager = CLLocationManager()
    
    private var miniMap: MKMapCompassView!
    
    let sceneView = NavView()
    let instructionsLabel = UILabel()
    let lastLocationInLegLabel = UILabel()
    let userLocationLabel = UILabel()
    let consoleLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    func setupUI() {
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
    }
    
    func setup() {
        sceneView.preferredFramesPerSecond = 30
        
        miniMap = MKMapCompassView(frame: CGRect(x: 20, y: 20, width: view.bounds.width / 2.7,
                                                               height: view.bounds.width / 2.7))
        miniMap.tintColor = .black
        miniMap.delegate = self
        view.insertSubview(miniMap, aboveSubview: sceneView)
        setCompassConstraints()
        
        sceneView.showsStatistics = true
        sceneView.delegate = self
        
        locationService.startUpdatingLocation(locationManager: locationService.locationManager!)
        locationService.delegate = self
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        runARSession()
    }
    
    func setCompassConstraints() {
        miniMap.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,
                                                constant: 12).isActive = true
        
        miniMap.topAnchor.constraint(equalTo: view.topAnchor,
                                            constant: 12).isActive = true
        
        let mult: CGFloat = 0.3
        miniMap.heightAnchor.constraint(equalTo: view.widthAnchor,
                                               multiplier: mult).isActive = true
        
        miniMap.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: mult).isActive = true
    }
    
    func runARSession() {
        
        configuration.videoFormat = ARWorldTrackingConfiguration.supportedVideoFormats[1]
        // 0 - imageResolution=(1920, 1440) framesPerSecond=(60)
        // 1 - imageResolution=(1920, 1080) framesPerSecond=(60)
        // 2 - imageResolution=(1280, 720) framesPerSecond=(60)
        print(configuration.videoFormat)
        
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = false
        sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// update positions of spheres on route
    private func updateArRoute() {
        if updatedLocs.count > 0 {
            startLocation = CLLocation().mostAccurateLocationFrom(updatedLocs)
            transNodesLocations()
        }
    }
    
    private func transNodesLocations() {
        for sphere in sphereNodes {
            
            let transformationMatrix = TransformationMatrix.transformCoordinates(initialLocation: startLocation,
                                                                                 location: sphere.location)
            
            sphere.anchor = ARAnchor(transform: transformationMatrix)
            sphere.position = SCNVector3.transformVectorCoordinates(by: transformationMatrix)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        screenTouched()
    }
    
    func screenTouched() {
        instructionsLabel.isHidden = true
        
        if updatedLocs.count > 0 {
            
            startLocation = CLLocation().mostAccurateLocationFrom(updatedLocs)
            
            if startLocation != nil  {
                self.cleanup()
                self.addRouteSpheres(steps: self.routeData)
            }
        }
    }
    
    private func cleanup() {
        for node in self.sphereNodes {
            node.removeFromParentNode()
        }
        self.sphereNodes = []
    }
}

// MARK: - ARSCNViewDelegate

extension NavigationViewController: ARSCNViewDelegate {
    
    private func addLabelSphere(routeStep: RouteLeg) {
        let stepLoc = CLLocation(latitude: routeStep.coordinates[0].latitude,
                                 longitude: routeStep.coordinates[0].longitude)
        
        let locTrans = TransformationMatrix.transformCoordinates(initialLocation: startLocation,
                                                                 location: stepLoc)
        
        let sphereAnchor = ARAnchor(transform: locTrans)
        spheresAnchors.append(sphereAnchor)
        
        let sphereNode = SphereNode(title: routeStep.directions, location: stepLoc)
        
        sphereNode.addLabelSphere(radius: 0.15,
                              text: routeStep.directions,
                              color: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        
        sphereNode.anchor = sphereAnchor
        
        sphereNode.location = stepLoc
        
        sceneView.session.add(anchor: sphereAnchor)
        sceneView.scene.rootNode.addChildNode(sphereNode)
        
        sphereNodes.append(sphereNode)
    }
    
    private func addSphere(location: CLLocation) {
        
        let locTrans = TransformationMatrix.transformCoordinates(initialLocation: startLocation,
                                                                 location: location)
        
        let sphereAnchor = ARAnchor(transform: locTrans)
        spheresAnchors.append(sphereAnchor)
        
        let sphereNode = SphereNode(title: "Title", location: location)
        sphereNode.addSphere(radius: 0.15, color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
        sphereNode.anchor = sphereAnchor
        sphereNode.location = location
        
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
        
        let localCurrLeg = routeData[currLeg]
        
        for (index, location) in localCurrLeg.coordinates.enumerated() {
            
            if index == 0 { addLabelSphere(routeStep: localCurrLeg) }
            else {
                let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
                addSphere(location: loc)
            }
        }
    }
    
    private func locatingLogic() {
        
        print("currLegNum: \(currLeg)")
        
        if methodFiredAgain == true && currLeg < routeData.count {
            currLeg += 1
        }
        
        let currLegLast2DD = routeData[currLeg].coordinates.last
        guard let currLegLast2D = currLegLast2DD else { methodFiredAgain = true; return }
        /// set bool to next update draw next leg ->  draw only first node -> tap -> update (method fire again) -> getting next leg - drawing next leg
        
        let currLegLastLocation = CLLocation(latitude: currLegLast2D.latitude, longitude: currLegLast2D.longitude)
        
        /// get current location - compare with lastLegLocation
        let lastLoc = currLegLastLocation.coordinate
        let shortLLa = makePrettyCoord(lastLoc.latitude)
        let shortLLo = makePrettyCoord(lastLoc.longitude)
        
        let currLoc = currLocation.coordinate
        let shortCLa = makePrettyCoord(currLoc.latitude)
        let shortCLo = makePrettyCoord(currLoc.longitude)
        
        lastLocationInLegLabel.text = "last: \(shortLLa), \(shortLLo)"
        userLocationLabel.text = "curr: \(shortCLa), \(shortCLo)"
        
        if shortLLa == shortCLa || shortLLo == shortCLo {
            
            if currLeg < routeData.count {
                let label = "starting new leg"
                
                currLeg += 1
                print("\(label): \(currLeg)")
                consoleLabel.text = label
            } else {
                let label = "you've archived your destionation"
                print(label)
                consoleLabel.text = label
            }
        } else {
            print("not yet")
            consoleLabel.text = "not yet"
        }
    }
    
    // from latitude/longitude to rounded double
    private func makePrettyCoord(_ coord: CLLocationDegrees) -> Double {
        return Double(coord).rounded(to: 6)
    }
}

// MARK: - LocationDelegate, AlertMessage

extension NavigationViewController: LocationDelegate, AlertMessage {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    // update locations
    func trackingLocation(for currentLocation: CLLocation) {
        if currentLocation.horizontalAccuracy <= 100.0 {
            print("location updated")
            updatedLocs.append(currentLocation)
            updateArRoute()
            currLocation = currentLocation
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
        showAlert(title: "Problem while scanning your surroundings!",
                       message: "Please restart the app")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session interrupted")
        sceneView.session.pause()
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session resumed")
        sceneView.session.run(session.configuration!, options: [.resetTracking,
                                                                .removeExistingAnchors])
    }
}

extension NavigationViewController: MKMapViewDelegate {}
class NavView: ARSCNView {}

//
//  ARScreenController.swift
//  Thesis02
//
//  Created by Kim Seyoung & Chloe Gao on 4/1/18.
//  Copyright © 2018 SeyoungKim&ChloeGao. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    fileprivate let locationManager = CLLocationManager()
    //    fileprivate var places = [Place]()
    
    var startedLoadingPOIs = false
    var POInames = [String]()
    
    var i = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        let tapGestureBtn = UIButton(frame: CGRect(x:135, y:600, width: 100, height: 30))
        tapGestureBtn.setTitle("Near By", for: .normal)
        tapGestureBtn.setTitleColor(UIColor.white, for: .normal)
        tapGestureBtn.backgroundColor = UIColor.purple
        self.view.addSubview(tapGestureBtn)
        tapGestureBtn.addTarget(self, action: #selector(touchLocation), for: .touchUpInside)
        
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary:dict2)
                sceneView.technique = technique
            }
        }
        
    }
    
    func createTextNode(_ text: String) {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.0)
        
        textGeometry.font = UIFont(name: "Neon Glow", size: 7)
        
        textGeometry.flatness = 0.0
        
        textGeometry.firstMaterial?.isDoubleSided = true
        
        guard let pov = sceneView.pointOfView else {
            print("Unable to get pov")
            return
        }
        
        let textNode = SCNNode(geometry: textGeometry)
        
        textNode.simdPosition = pov.simdPosition + pov.simdWorldFront * 0.5
        textNode.simdRotation = pov.simdRotation
        
        textNode.scale = SCNVector3Make(0.01, 0.01, 0.01)
        textNode.categoryBitMask = 2
        let (minVec, maxVec) = textNode.boundingBox
        textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    //    func showInfoView(forPlace place: Place) {
    //        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
    //        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    //    }
    
    @objc
    func touchLocation(_ gestureRecognize: UIGestureRecognizer) {
        createTextNode(POInames[i])
        i = i+1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0 {
            let location = locations.last!
            
            if location.horizontalAccuracy < 100 {
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    
                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
                        
                        if let dict = placesDict {
                            print(dict)
                            guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
                            
                            for placeDict in placesArray {
                                
//                                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
//                                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
//                                let reference = placeDict.object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
//                                let address = placeDict.object(forKey: "vicinity") as! String
                                
//                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                self.POInames.append(name)
                                
                            }
                        }
                    }
                }
            }
        }
    }
}



//
//  MapViewController.swift
//  UmbrellaSharing-iOS
//
//  Created by Katselenbogen, Igor on 2020/06/10.
//  Copyright © 2020 Katselenbogen, Igor. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class MapViewController: UIViewController, MapDataModelDelegate {
 
    @IBOutlet weak var proceedButton: UmbrellaButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var timeAndPriceLabel: MapCounterLabel!
    
    private let mapViewModel = MapViewModel()
    
    var timer: Timer?
    var counter = 0.0
    
    var mapView: GMSMapView?
    var mapMode: UmbrellaUtil.MapMode?
    
    var orderInformation: OrderInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        loadLocations()
        initButtons()
        initMap()
        initCounter()
    }
    
    private func loadLocations() {
        mapViewModel.delegate = self
        mapViewModel.load()
    }
    
    private func initCounter() {
        timeAndPriceLabel.isHidden = true
        if let mapMode = mapMode, mapMode == UmbrellaUtil.MapMode.rentalMode {
            timeAndPriceLabel.isHidden = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateTimerLabel() {
        counter += 1
        timeAndPriceLabel.text = prepareTextForTimeAndPriceLabel(counter)
    }
    
    private func normilizeTimeValue(_ rawTimeValue: Int) -> String {
        if rawTimeValue < 10 {
            let result = "0" + String(rawTimeValue)
            return result
        }
        return String(rawTimeValue)
    }
    
    // TODO: Level 2 - Put it in a model class
    private func prepareTextForTimeAndPriceLabel(_ counter: Double) -> String {
        let hours = normilizeTimeValue(Int(counter) / 3600)
        let minutes = normilizeTimeValue(Int(counter) / 60 % 60)
        let seconds = normilizeTimeValue(Int(counter) % 60)
        var timeString = "00:00"
        if (Int(hours) == 0) {
            timeString = "\(minutes):\(seconds)"
        } else {
            timeString = "\(hours):\(minutes):\(seconds)"
        }
        
        // TODO: Level 1 - Implement Price calculation
        let priceString = "Price"
        return timeString + " " + priceString
    }
    
    private func initMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 55.76, longitude: 37.62, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        if let mapView = mapView {
            self.view.addSubview(mapView)
            self.view.sendSubviewToBack(mapView)
        }
    }
    
    private func initMarkers(_ mapView: GMSMapView, _ locations: [LocationPointEntity]) {
        // TODO: Level 2 - Ask Ilia about the title for each location. Now it is default.
        for location in locations {
            print(location)
            let currentMarker = GMSMarker()
            currentMarker.position = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            currentMarker.title = "Marker"
            currentMarker.snippet = location.description
            currentMarker.map = mapView
        }
    }
    
    private func initButtons() {
        if let mapMode = mapMode {
            switch mapMode {
            case .locationsMode:
                proceedButton.setTitle("Rent an Umbrella", for: .normal)
                proceedButton.setTitle("Back to Home", for: .normal)
            case .rentalMode:
                proceedButton.setTitle("Return an Umbrella", for: .normal)
                backButton.isHidden = true
            }
        }
    }
    
    @IBAction func `continue`(_ sender: Any) {
        if let mapMode = mapMode {
            switch mapMode {
            case .locationsMode:
                // TODO: Level 1 - Ask Ilya what shold be done in this case if we need actually to send a user for the next screen
                print("Locations Mode")
            case .rentalMode:
                openQRScreenToReturnUmbrella()
                print("Rental mode")
            }
        }
    }
    
    private func openQRScreenToReturnUmbrella() {
        // TODO: Level 2 - Think better about which kind of orderInformation we should pass here and what kind of QR should be generated there
        let storyBoard: UIStoryboard = UIStoryboard(name: "QRCodeScreen", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "QRCodeScreenViewController") as! QRCodeScreenViewController
        newViewController.modalPresentationStyle = .fullScreen
        if let orderInformation = orderInformation {
            newViewController.orderInformation = orderInformation
        }
        newViewController.operationType = UmbrellaUtil.OperationType.returnUmbrella
        self.present(newViewController, animated: true, completion: nil)
    }
    
    @IBAction func backToHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: MapViewModel Delegate
    
    func didLoadLocations(locations: [LocationPointEntity]) {
         initMarkers(mapView!, locations)
     }
     
}

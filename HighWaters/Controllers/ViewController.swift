
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floodButton: UIButton! 
    
    private lazy var locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestAlwaysAuthorization()
        return manager
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        setupUI()
        
    }
    
    @IBAction func addFloodButtonPressed() {
        
        guard let location = self.locationManager.location else {
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.title = "Flooded"
        annotation.subtitle = "Reported on 12/10/2018 8:50 AM"
        annotation.coordinate = location.coordinate
        
        self.mapView.addAnnotation(annotation)
        
    }
    
    private func setupUI() {
        self.floodButton.layer.cornerRadius = 6.0
        self.floodButton.layer.masksToBounds = true
    }


}


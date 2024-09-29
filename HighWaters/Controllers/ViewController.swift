
import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floodButton: UIButton!
    
    private var documentRef: DocumentReference!
    
    private lazy var db: Firestore = {
        
        let firestoreDB = Firestore.firestore()
        return firestoreDB
    }()
    
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
        self.mapView.delegate = self
        
        setupUI()
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
    }
    
    @IBAction func addFloodButtonPressed() {
        
        saveFloodToFirebase()
    }
    
    private func addFloodToMap(_ flood: Flood) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: flood.latitude, longitude: flood.longitude)
        annotation.title = "Flooded"
        annotation.subtitle = flood.reportedDate.formatAsString()
        self.mapView.addAnnotation(annotation)
        
    }
    
    private func saveFloodToFirebase() {
        
        guard let location = self.locationManager.location else {
            return
        }
        
        var flood = Flood(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.documentRef = self.db.collection("flooded-regions").addDocument(data: flood.toDictionary()) { [weak self] error in
            
            if let error = error {
                print(error)
            } else {
                flood.documentId = self?.documentRef.documentID
                self?.addFloodToMap(flood)
            }
            
        }
        
    }
    
    private func setupUI() {
        self.floodButton.layer.cornerRadius = 6.0
        self.floodButton.layer.masksToBounds = true
    }


}


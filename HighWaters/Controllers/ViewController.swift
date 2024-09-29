
import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var floodButton: UIButton!

    private(set) var floods = [Flood]()

    private var documentRef: DocumentReference!
    
    private lazy var db = Firestore.firestore()

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
        configureObservers()

    }

    private func updateAnnotations() {

        DispatchQueue.main.async {
            self.mapView.removeAnnotations((self.mapView.annotations))
            self.floods.forEach {
                self.addFloodToMap($0)
            }
        }

    }

    private func configureObservers() {

        self.db.collection("flooded-regions").addSnapshotListener { [weak self] snapshot, error in

            guard let snapshot = snapshot,
                  error == nil else {
                print("Error fetching document")
                return
            }

            snapshot.documentChanges.forEach { diff in

                if diff.type == .added {
                    if let flood = Flood(diff.document) {
                        self?.floods.append(flood)
                        self?.updateAnnotations()
                    }

                } else if diff.type == .removed {
                    if let flood = Flood(diff.document) {
                        if let floods = self?.floods {
                            self?.floods = floods.filter { $0.documentId != flood.documentId }
                            self?.updateAnnotations()
                        }
                    }
                }

            }

        }
    }

    @IBAction func addFloodButtonPressed() {
        
        saveFloodToFirebase()

    }
    
    private func addFloodToMap(_ flood: Flood) {
        
        let annotation = FloodAnnotation(flood)
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

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        let region = MKCoordinateRegion(center: self.mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.mapView.setRegion(region, animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "FloodAnnotationView")

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "FloodAnnotationView")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "flood-annotation")!.resizeImageTo(size: CGSize(width: 40, height: 40))
            annotationView?.rightCalloutAccessoryView = UIButton.buttonForRightAccessoryView()

        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(view.annotation.debugDescription)
        if let floodAnnotation = view.annotation as? FloodAnnotation {
            print("Document successfully casted!")
            let flood = floodAnnotation.flood

            self.db.collection("flooded-regions").document(flood.documentId!).delete() { error in
                if let error = error {
                    print("Error removing document \(error)")
                }
            }

        }

    }
}


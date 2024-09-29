
import Foundation
import FirebaseFirestore

struct Flood {
    
    var documentId: String?
    let latitude: Double
    let longitude: Double
    var reportedDate: Date = Date()
}

extension Flood {

    init?(_ snapshot: QueryDocumentSnapshot) {

        guard let latitude = snapshot["latitude"] as? Double,
            let longitude = snapshot["longitude"] as? Double else {
                return nil
        }

        self.latitude = latitude
        self.longitude = longitude
        self.documentId = snapshot.documentID

    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
}

extension Flood {
    
    func toDictionary() -> [String:Any] {
        return [
            "latitude": self.latitude,
            "longitude": self.longitude,
            "reportedDate": self.reportedDate.formatAsString()
        ]
    }
    
}



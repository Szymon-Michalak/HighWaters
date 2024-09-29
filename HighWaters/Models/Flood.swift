
import Foundation

struct Flood {
    
    var documentId: String?
    let latitude: Double
    let longitude: Double
    var reportedDate: Date = Date()
}

extension Flood {
    
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



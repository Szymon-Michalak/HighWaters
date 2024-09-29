import Foundation
import MapKit
import UIKit

class FloodAnnotation: MKPointAnnotation {
    
    let flood: Flood
    
    init(_ flood: Flood) {
        self.flood = flood
    }
    
}

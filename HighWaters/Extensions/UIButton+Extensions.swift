
import Foundation
import UIKit

extension UIButton {
    
    static func buttonForRightAccessoryView() -> UIButton {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 18, height: 22)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        return button
        
    }
    
}

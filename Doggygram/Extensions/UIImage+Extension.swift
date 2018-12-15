import UIKit

extension UIImage {
    
    static func `init`(color: UIColor,
                       size: CGSize = .init(width: 1.0, height: 1.0)) -> UIImage? {
        
        var rect = CGRect.zero
        rect.size = size
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

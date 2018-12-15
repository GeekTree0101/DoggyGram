import Foundation
import Vetty

class User: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return id
    }
    
    var id: Int = -1
    var imagePath: String?
    var bio: String?
    var username: String?
    var isFollow: Bool = false
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case imagePath = "image_url"
        case bio
        case username
        case isFollow = "is_follow"
    }
    
    func commitSubModelIfNeeds() {
        // ignore
    }
}

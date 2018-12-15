import Foundation
import Vetty

class Dog: VettyProtocol {
    
    var uniqueKey: VettyIdentifier {
        return id
    }
    
    var id: String = ""
    var imagePath: String?
    var desc: String?
    var user: User?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case imagePath = "image_url"
        case desc
        case user
    }
    
    func commitSubModelIfNeeds() {
        
        Vetty.shared.commitIfNeeds(self.user)
    }
}

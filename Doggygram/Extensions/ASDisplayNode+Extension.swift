import AsyncDisplayKit
import Hero

extension ASDisplayNode {
    
    enum HeroIdentifier {
        case doggyImage(String)
        
        var identifier: String {
            switch self {
            case .doggyImage(let id):
                return "doggy-image-\(id)"
            }
        }
    }
    
    func applyHero(id: HeroIdentifier, modifier: [HeroModifier]?) {
        guard ASDisplayNodeThreadIsMain() else {
            fatalError("This method must be called on the main thread")
        }
        self.view.hero.id = id.identifier
        self.view.hero.modifiers = modifier
    }
}

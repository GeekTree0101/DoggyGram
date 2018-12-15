import Foundation
import AsyncDisplayKit
import RxCocoa_Texture
import RxCocoa
import RxSwift
import Vetty

extension Reactive where Base: HelloDoggyCellNode {
    
    var didLoadedDoggyFeed: ASBinder<Void> {
        return ASBinder(base) { node, _ in
            node.transitionLayout(withAnimation: true,
                                  shouldMeasureAsync: false,
                                  measurementCompletion: nil)
        }
    }
}

class HelloDoggyCellNode: ASCellNode {
    
    struct Const {
        
        static let insets: UIEdgeInsets =
            .init(top: 30.0, left: 30.0, bottom: 30.0, right: .infinity)
        static var titleAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 50.0, weight: .bold),
                    .foregroundColor: UIColor.gray]
        }
    }
    
    let titleNode: ASTextNode = {
        
        let node = ASTextNode.init()
        node.attributedText =
            NSAttributedString(string: "Hello Doggy!",
                               attributes: Const.titleAttribute)
        return node
    }()
    
    let disposeBag = DisposeBag()
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        UIView.transition(with: self.titleNode.view,
                          duration: 0.2,
                          options: .transitionCrossDissolve, animations: {
            self.titleNode.attributedText =
                NSAttributedString(string: "Welcome!",
                                   attributes: Const.titleAttribute)
        }, completion: nil)
    }
    
    override init() {
        
        super.init()
        self.automaticallyManagesSubnodes = true
        self.automaticallyRelayoutOnSafeAreaChanges = true
        self.selectionStyle = .none
        self.backgroundColor = .white
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        return ASInsetLayoutSpec(insets: Const.insets,
                                 child: titleNode)
    }
}

import AsyncDisplayKit

class LoadingIndicatorNode: ASDisplayNode {
    
    let circleNode: ASDisplayNode = {
        
        let node = ASDisplayNode()
        node.style.preferredSize = .init(width: 15.0, height: 15.0)
        node.cornerRadius = 7.4
        node.backgroundColor = .purple
        return node
    }()
    
    let circleNode2: ASDisplayNode = {
        
        let node = ASDisplayNode()
        node.style.preferredSize = .init(width: 15.0, height: 15.0)
        node.cornerRadius = 7.4
        node.backgroundColor = .purple
        return node
    }()
    
    let railNode: ASDisplayNode = {
        
        let node = ASDisplayNode()
        node.style.preferredSize = .init(width: 50.0, height: 50.0)
        node.cornerRadius = 25.0
        node.backgroundColor = .clear
        return node
    }()
    
    private var rotateAnimation: CABasicAnimation {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0.0
        rotation.toValue = CGFloat(2.0 * Float.pi)
        rotation.duration = 1.0
        rotation.fillMode = CAMediaTimingFillMode.forwards
        rotation.isAdditive = true
        rotation.isRemovedOnCompletion = false
        rotation.repeatCount = .infinity
        return rotation
    }
    
    override init() {
        super.init()
        self.automaticallyManagesSubnodes = true
        self.backgroundColor = .clear
        self.isHidden = true
        self.style.preferredSize = .init(width: 50.0, height: 50.0)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let relativeLayout = ASRelativeLayoutSpec(horizontalPosition: .center,
                                                  verticalPosition: .start,
                                                  sizingOption: .minimumSize,
                                                  child: circleNode)
        
        let relativeLayout2 = ASRelativeLayoutSpec(horizontalPosition: .center,
                                                  verticalPosition: .end,
                                                  sizingOption: .minimumSize,
                                                  child: circleNode2)
        
        let circleOverlayedRailLayout =
            ASOverlayLayoutSpec(child: railNode, overlay: relativeLayout)
        let circleOverlayedRailLayout2 =
            ASOverlayLayoutSpec(child: circleOverlayedRailLayout, overlay: relativeLayout2)

        return ASWrapperLayoutSpec(layoutElement: circleOverlayedRailLayout2)
    }

    func start() {
        self.isHidden = false
        self.alpha = 0.0
        self.layer.removeAllAnimations()
        self.layer.add(self.rotateAnimation, forKey: "transform.rotation")
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1.0
        })
    }
    
    func stop() {
        self.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0.0
        }, completion: { fin in
            guard fin else { return }
            self.isHidden = true
        })
    }
}

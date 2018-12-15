import Foundation
import RxSwift
import RxCocoa
import RxCocoa_Texture
import AsyncDisplayKit
import Hero
import Vetty

class DoggyShowNodeController: ASViewController<ASDisplayNode> {
    
    struct Const {
        
        static var descAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 15.0, weight: .light),
                    .foregroundColor: UIColor.gray]
        }
        
        static var usernameAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 20.0, weight: .bold),
                    .foregroundColor: UIColor.darkGray]
        }
        
        static var bioAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 15.0, weight: .bold),
                    .foregroundColor: UIColor.darkGray]
        }
        
        static var copyRightAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 10.0, weight: .bold),
                    .foregroundColor: UIColor.gray]
        }
    }
    
    lazy var imageNode: ASImageNode = {
        let node = ASImageNode()
        node.backgroundColor = .lightGray
        return node
    }()
    
    lazy var descNode = ASTextNode()
    
    lazy var contentAreaNode: ASScrollNode = {
        let node = ASScrollNode()
        node.backgroundColor = .white
        node.automaticallyManagesContentSize = true
        node.automaticallyManagesSubnodes = true
        node.automaticallyRelayoutOnSafeAreaChanges = true
        return node
    }()
    
    lazy var closeButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(UIImage.init(named: "close"), for: .normal)
        node.backgroundColor = .purple
        node.cornerRadius = 20.0
        node.style.preferredSize = .init(width: 40.0, height: 40.0)
        node.alpha = 0.0
        return node
    }()
    
    lazy var userProfileNode: ASImageNode = {
        let node = ASImageNode()
        node.cornerRadius = 35.0
        node.clipsToBounds = true
        node.style.preferredSize = .init(width: 70.0, height: 70.0)
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        return node
    }()
    
    lazy var usernameNode = ASTextNode()
    
    lazy var bioNode = ASTextNode()
    
    lazy var followButton: ASButtonNode = {
        
        let node = ASButtonNode()
        node.style.height = .init(unit: .points, value: 50.0)
        node.style.minWidth = .init(unit: .points, value: 120.0)
        node.cornerRadius = 5.0
        node.setTitle("Follow", with: UIFont.systemFont(ofSize: 12.0, weight: .bold),
                      with: .white,
                      for: .normal)
        node.setTitle("UnFollow", with: UIFont.systemFont(ofSize: 12.0, weight: .bold),
                      with: .white,
                      for: .selected)
        node.setBackgroundImage(UIImage.init(color: .purple), for: .normal)
        node.setBackgroundImage(UIImage.init(color: .darkGray), for: .selected)
        node.backgroundColor = .white
        node.clipsToBounds = true
        node.contentEdgeInsets = .init(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
        return node
    }()
    
    lazy var copyRightNode: ASTextNode = {
        let node = ASTextNode()
        node.attributedText = .init(string: "Copyright © 2018 Geektree0101. All rights reserved",
                                    attributes: Const.copyRightAttribute)
        return node
    }()
    
    let viewModel: DoggyViewModel
    let disposeBag = DisposeBag()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    lazy var dismissGestureRecognizer: UIPanGestureRecognizer = {
        let panne = UIPanGestureRecognizer()
        panne.addTarget(self, action: #selector(dismissHandler))
        panne.delegate = self
        return panne
    }()
    
    init(_ repoId: VettyIdentifier) {
        self.viewModel = DoggyViewModel.init(repoId)
        super.init(node: .init())
        self.hero.isEnabled = true
        self.setupBackgroundNode()
        self.rxBind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard self.closeButtonNode.alpha < 1.0 else { return }
        self.closeButtonNode.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
        UIView.animate(withDuration: 0.5,
                       delay: 0.2,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.closeButtonNode.transform = CATransform3DIdentity
            self.closeButtonNode.alpha = 1.0
        }, completion: nil)
    }
    
    private func setupBackgroundNode() {
        self.node.automaticallyManagesSubnodes = true
        self.node.automaticallyRelayoutOnSafeAreaChanges = true
        self.node.backgroundColor = .white
        self.node.layoutSpecBlock = { [weak self] (_, constrainedSize) -> ASLayoutSpec in
            return self?.layoutSpecThatFits(constrainedSize) ?? ASLayoutSpec()
        }
        self.contentAreaNode.layoutSpecBlock = { [weak self] (_, constrainedSize) -> ASLayoutSpec in
            return self?.contentAreaLayoutSpec() ?? ASLayoutSpec()
        }
        self.imageNode.onDidLoad({ [weak self] node in
            
            node.applyHero(id: .doggyImage(self?.viewModel.doggyId.id ?? ""), modifier: [])
        })
        self.contentAreaNode.onDidLoad({ [weak self] node in
            guard let scrollView = node.view as? UIScrollView else { return }
            scrollView.delegate = self
        })
        self.node.onDidLoad({ [weak self] node in
            guard let gesture = self?.dismissGestureRecognizer else { return }
            node.view.addGestureRecognizer(gesture)
        })
    }
    
    private func rxBind() {
        
        viewModel.image
            .bind(to: imageNode.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.desc
            .bind(to: descNode.rx.text(Const.descAttribute),
                  setNeedsLayout: self.node)
            .disposed(by: disposeBag)
        
        viewModel.profileImage
            .bind(to: userProfileNode.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.username
            .bind(to: usernameNode.rx.text(Const.usernameAttribute),
                  setNeedsLayout: self.node)
            .disposed(by: disposeBag)
        
        viewModel.bio
            .bind(to: bioNode.rx.text(Const.bioAttribute),
                  setNeedsLayout: self.node)
            .disposed(by: disposeBag)
        
        viewModel.isFollow
            .bind(to: followButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        followButton.rx.tap
            .bind(to: viewModel.didTapFollowRelay)
            .disposed(by: disposeBag)
        
        closeButtonNode.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}
extension DoggyShowNodeController: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard self.contentAreaNode.view.contentOffset.y <= 0.0,
            self.dismissGestureRecognizer.translation(in: nil).y > 0.0 else { return false }
        return true
    }
    
    @objc func dismissHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: nil)
        let progress = translation.y / view.bounds.height
        
        switch gestureRecognizer.state {
        case .began:
            self.dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(progress)
        default:
            if progress > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel(animate: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y < 0.0 else { return }
        scrollView.setContentOffset(.zero, animated: false)
    }
}

extension DoggyShowNodeController {
    
    func layoutSpecThatFits(_ constraintedSize: ASSizeRange) -> ASLayoutSpec {
        let imageLayout = imageLayoutSpec()
        let contentAreaLayout = contentAreaNode
        
        imageLayout.style.flexBasis = .init(unit: .fraction, value: 0.4)
        contentAreaLayout.style.flexBasis = .init(unit: .fraction, value: 0.6)
        
        let stackLayout = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 0.0,
                                            justifyContent: .start,
                                            alignItems: .stretch,
                                            children: [imageLayout,
                                                       contentAreaLayout])
        return ASInsetLayoutSpec(insets: .zero, child: stackLayout)
    }
    
    private func contentAreaLayoutSpec() -> ASLayoutSpec {
        return ASStackLayoutSpec(direction: .vertical,
                                 spacing: 0.0,
                                 justifyContent: .start,
                                 alignItems: .stretch,
                                 children: [contentLayoutSpec(),
                                            userAreaLayoutSpec(),
                                            copyRightLayoutSpec()])
    }
    
    private func imageLayoutSpec() -> ASLayoutSpec {
        var insets: UIEdgeInsets = .zero
        insets.left = .infinity
        insets.top = self.node.safeAreaInsets.top + 20.0
        insets.bottom = .infinity
        insets.right = 20.0
        let closeButtonLayout = ASInsetLayoutSpec(insets: insets, child: closeButtonNode)
        return ASOverlayLayoutSpec(child: imageNode,
                                   overlay: closeButtonLayout)
    }
    
    private func contentLayoutSpec() -> ASLayoutSpec {
        let insets: UIEdgeInsets = .init(top: 20.0, left: 15.0, bottom: 0.0, right: 15.0)
        return ASInsetLayoutSpec(insets: insets, child: descNode)
    }
    
    private func userAreaLayoutSpec() -> ASLayoutSpec {
        let insets: UIEdgeInsets = .init(top: 150.0, left: 15.0, bottom: 40.0, right: 15.0)
        
        let elements: [ASLayoutElement] = [userProfileNode,
                                           usernameNode,
                                           bioNode,
                                           followButton]
        
        let stackLayout = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 15.0,
                                            justifyContent: .start,
                                            alignItems: .center,
                                            children: elements)
        stackLayout.style.alignSelf = .stretch
        return ASInsetLayoutSpec(insets: insets, child: stackLayout)
    }
    
    private func copyRightLayoutSpec() -> ASLayoutSpec {
        let insets: UIEdgeInsets = .init(top: 100.0, left: .infinity, bottom: 40.0, right: .infinity)
        return ASInsetLayoutSpec(insets: insets, child: copyRightNode)
    }
}

import Foundation
import AsyncDisplayKit
import RxCocoa_Texture
import RxCocoa
import RxSwift
import Vetty

class DoggyCellNode: ASCellNode {
    
    struct Const {
        
        static var descAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 15.0, weight: .light),
                    .foregroundColor: UIColor.gray]
        }
        
        static var usernameAttribute: [NSAttributedString.Key: Any] {
            return [.font: UIFont.systemFont(ofSize: 15.0, weight: .bold),
                    .foregroundColor: UIColor.darkGray]
        }
        
        static let insets: UIEdgeInsets =
            .init(top: 15.0, left: 15.0, bottom: 30.0, right: 15.0)
    }
    
    lazy var imageNode: ASImageNode = {
        
        let node = ASImageNode()
        node.cornerRadius = 10.0
        node.backgroundColor = .lightGray
        return node
    }()
    
    lazy var descNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 2
        return node
    }()
    
    lazy var userProfileNode: ASImageNode = {
        
        let node = ASImageNode()
        node.cornerRadius = 25.0
        node.clipsToBounds = true
        node.style.preferredSize = .init(width: 50.0, height: 50.0)
        node.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        node.borderWidth = 0.5
        return node
    }()
    
    lazy var followButton: ASButtonNode = {
        
        let node = ASButtonNode()
        node.style.height = .init(unit: .points, value: 40.0)
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
    
    lazy var usernameNode = ASTextNode()
    private var imageRatio: CGFloat = 0.5
    
    let viewModel: DoggyViewModel
    let disposeBag = DisposeBag()
    
    init(doggyId: VettyIdentifier) {
        viewModel = DoggyViewModel.init(doggyId)
        
        super.init()
        self.automaticallyManagesSubnodes = true
        self.automaticallyRelayoutOnSafeAreaChanges = true
        self.selectionStyle = .none
        self.backgroundColor = .white
        
        viewModel.image
            .bind(to: imageNode.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.imageRatio
            .subscribe(onNext: { [weak self] ratio in
                self?.imageRatio = ratio
                self?.rx_setNeedsLayout()
            }).disposed(by: disposeBag)
        
        viewModel.desc
            .bind(to: descNode.rx.text(Const.descAttribute))
            .disposed(by: disposeBag)
        
        viewModel.profileImage
            .bind(to: userProfileNode.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.username
            .bind(to: usernameNode.rx.text(Const.usernameAttribute))
            .disposed(by: disposeBag)
        
        viewModel.isFollow
            .bind(to: followButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        followButton.rx.tap
            .bind(to: viewModel.didTapFollowRelay)
            .disposed(by: disposeBag)
    }
    
    override func didLoad() {
        super.didLoad()
        self.imageNode.applyHero(id: .doggyImage(self.viewModel.doggyId.id), modifier: nil)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let stackLayout = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 15.0,
                                            justifyContent: .start,
                                            alignItems: .stretch,
                                            children: [profileAreaLayoutSpec(),
                                                       imageLayoutSpec(),
                                                       descNode])
        
        return ASInsetLayoutSpec(insets: Const.insets, child: stackLayout)
        
    }
    
    func imageLayoutSpec() -> ASLayoutSpec {
        
        return ASRatioLayoutSpec(ratio: self.imageRatio, child: imageNode)
    }
    
    func profileAreaLayoutSpec() -> ASLayoutSpec {
        
        let infoAreaStackLayout = ASStackLayoutSpec(direction: .horizontal,
                                                    spacing: 10.0,
                                                    justifyContent: .start,
                                                    alignItems: .center,
                                                    children: [userProfileNode, usernameNode])
        
        return ASStackLayoutSpec(direction: .horizontal,
                                 spacing: 10.0,
                                 justifyContent: .spaceBetween,
                                 alignItems: .center,
                                 children: [infoAreaStackLayout, followButton])
    }
}

import Foundation
import RxSwift
import RxCocoa
import AsyncDisplayKit
import Vetty

class FeedNodeController: ASViewController<ASDisplayNode> {
    
    enum Section: Int, CaseIterable {
        
        case intro
        case doggyList
        case copyright
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    let feedIdRelay = BehaviorRelay<[VettyIdentifier]>(value: [])
    
    lazy var tableNode: ASTableNode = {
        
        let node = ASTableNode()
        node.dataSource = self
        node.delegate = self
        node.backgroundColor = .white
        return node
    }()
    
    lazy var indicatorNode = LoadingIndicatorNode()
    
    let disposeBag = DisposeBag()
    
    init() {
        
        super.init(node: .init())
        
        self.node.automaticallyManagesSubnodes = true
        self.node.automaticallyRelayoutOnSafeAreaChanges = true
        self.node.backgroundColor = .white
        self.node.isOpaque = true
        
        self.node.layoutSpecBlock = { [weak self] (_, _) -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            let tableLayout = ASInsetLayoutSpec(insets: self.node.safeAreaInsets,
                                     child: self.tableNode)
            let indicatorLayout = ASCenterLayoutSpec(centeringOptions: .XY,
                                                     sizingOptions: [],
                                                     child: self.indicatorNode)
            
            return ASOverlayLayoutSpec(child: tableLayout, overlay: indicatorLayout)
        }
        
        self.node.onDidLoad({ [weak self] _ in
            self?.tableNode.view.separatorStyle = .none
            self?.tableNode.view.showsVerticalScrollIndicator = false
        })
        
        // reload table items
        self.feedIdRelay
            .filter { !$0.isEmpty }
            .distinctUntilChanged({ $0.count == $1.count })
            .subscribe(onNext: { [weak self] _ in
                self?.indicatorNode.stop()
                var indexSet = IndexSet.init()
                indexSet.insert(Section.doggyList.rawValue)
                indexSet.insert(Section.copyright.rawValue)
                self?.tableNode.reloadSections(indexSet, with: .fade)
            }).disposed(by: disposeBag)
        
        // load feed
        Service.feed()
            .map { [weak self] doggys -> [Dog] in
                self?.indicatorNode.start()
                return doggys
            }
            .delay(2.0, scheduler: MainScheduler.instance) // force lazy load
            .asObservable()
            .commits(ignoreSubModel: false)
            .bind(to: feedIdRelay)
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FeedNodeController: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.feedIdRelay.value.count else { return }
        let id = self.feedIdRelay.value[indexPath.row]
        let vc = DoggyShowNodeController(id)
        self.present(vc, animated: true, completion: nil)
    }
}

extension FeedNodeController: ASTableDataSource {
    
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        
        return Section.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        guard let section = Section.init(rawValue: section) else { return 0 }
        
        switch section {
        case .intro: return 1
        case .doggyList: return feedIdRelay.value.count
        case .copyright: return feedIdRelay.value.isEmpty ? 0: 1
        }
    }
    
    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            guard let section = Section.init(rawValue: indexPath.section) else {
                return ASCellNode()
            }
            
            switch section {
            case .intro:
                let cellNode = HelloDoggyCellNode()
                
                self.feedIdRelay.filter({ !$0.isEmpty })
                    .take(1)
                    .map { _ in return }
                    .bind(to: cellNode.rx.didLoadedDoggyFeed)
                    .disposed(by: cellNode.disposeBag)
                
                return cellNode
            case .doggyList:
                guard indexPath.row < self.feedIdRelay.value.count else {
                    return ASCellNode()
                }
                return DoggyCellNode(doggyId: self.feedIdRelay.value[indexPath.row])
            case .copyright:
                let cellNode = ASTextCellNode.init()
                cellNode.text = "Copyright © 2018 Geektree0101. All rights reserved"
                cellNode.textAttributes = [.font: UIFont.systemFont(ofSize: 10.0, weight: .bold),
                                           .foregroundColor: UIColor.gray]
                cellNode.textInsets = .init(top: 50.0, left: .infinity, bottom: 50.0, right: .infinity)
                return cellNode
            }
        }
    }
}

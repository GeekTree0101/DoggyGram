import Foundation
import RxSwift
import RxCocoa
import Vetty

class DoggyViewModel {
    
    // output
    var image: Observable<UIImage?>
    var desc: Observable<String?>
    var imageRatio: Observable<CGFloat>
    
    var profileImage: Observable<UIImage?>
    var username: Observable<String?>
    var bio: Observable<String?>
    var isFollow: Observable<Bool>
    
    // input
    let editDoggyDescriptionRelay = PublishRelay<String>()
    let didTapFollowRelay = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    let doggyId: VettyIdentifier
    
    init(_ doggyId: VettyIdentifier) {
        self.doggyId = doggyId
        
        let doggyObservable = Vetty.rx.observer(type: Dog.self, uniqueKey: doggyId)
        let userObservable = doggyObservable.map({ $0?.user }).asObserver(type: User.self)
        
        self.profileImage = userObservable
            .map({ UIImage.init(named: $0?.imagePath ?? "")})
        self.username = userObservable.map { $0?.username }
        self.bio = userObservable.map { $0?.bio }
        self.isFollow = userObservable.map { $0?.isFollow ?? false }
        
        self.image = doggyObservable
            .map { $0?.imagePath }
            .map { UIImage.init(named: $0 ?? "") }
        self.imageRatio = image.map { image -> CGFloat in
            guard let image = image else { return 0.5 }
            return image.size.height / image.size.width
        }
        self.desc = doggyObservable.map { $0?.desc }
        
        self.didTapFollowRelay
            .withLatestFrom(isFollow)
            .mutate(with: userObservable, { user, isFollow -> User? in
                user?.isFollow = !isFollow
                return user
            }).disposed(by: disposeBag)
        
        self.editDoggyDescriptionRelay
            .throttle(1.0, scheduler: MainScheduler.instance)
            .mutate(with: doggyObservable, { doggy, newDesc -> Dog? in
                doggy?.desc = newDesc
                return doggy
            }).disposed(by: disposeBag)
    }
}

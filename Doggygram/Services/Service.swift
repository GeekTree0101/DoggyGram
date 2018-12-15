import Foundation
import RxSwift
import RxCocoa

class Service {
    
    static func feed() -> Single<[Dog]> {
        
        let bundle = Bundle(for: self)
        let url = bundle.url(forResource: "feed", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let dogs = try! JSONDecoder().decode([Dog].self, from: data)
        return Single.just(dogs)
    }
}

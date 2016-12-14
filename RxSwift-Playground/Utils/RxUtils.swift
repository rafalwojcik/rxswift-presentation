import Foundation
import RxSwift

extension ObservableType {
    public func observeOnMain() -> Observable<Self.E> {
        return observeOn(MainScheduler.instance)
    }

    public func debugSubscribe() -> Disposable {
        return self.subscribe(onNext: { value in
            print("RxDEBUG - next value: \(value)")
        }, onError: { error in
            print("RxDEBUG - error: \(error)")
        }, onCompleted: { _ in
            print("RxDEBUG - completed")
        }, onDisposed: { _ in
            print("RxDEBUG - disposed")
        })
    }
}

infix operator >>>
func >>> (lhs: Disposable, rhs: DisposeBag) {
    lhs.addDisposableTo(rhs)
}

public protocol Optionable {
    associatedtype WrappedType
    func unwrap() -> WrappedType
    func isEmpty() -> Bool
}

extension Optional : Optionable {
    public typealias WrappedType = Wrapped
    public func unwrap() -> WrappedType {
        return self!
    }
    public func isEmpty() -> Bool {
        return self == nil
    }
}

extension ObservableType where E : Optionable {
    public func unwrap() -> Observable<E.WrappedType> {
        return self.filter({ !$0.isEmpty() }).map({ $0.unwrap() })
    }
}

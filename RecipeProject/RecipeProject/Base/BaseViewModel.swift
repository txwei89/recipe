//
//  BaseViewModel.swift
//  RecipeProject
//
//  Created by Teh Xiang Wei on 11/04/2021.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate var disposeBagContext: UInt8 = 0

class BaseViewModel: NSObject {
//    let loading = ActivityIndicator()
//    let headerLoading = ActivityIndicator()
//    let footerLoading = ActivityIndicator()
    let showLoading = BehaviorRelay.init(value: false)
    let showSuccess = BehaviorRelay.init(value: false)
//    let errorTracker = ErrorTracker()
    var page = BehaviorRelay<Int>.init(value: 1)
    let itemCount = BehaviorRelay<Int>.init(value: 0)
    
    func count(from: Int, to: Int, quickStart: Bool) -> Observable<Int> {
        return Observable<Int>
            .timer(quickStart ? 0 : 1, period: 1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { from - $0 }
    }
    
    deinit {
        print(String(describing: type(of: self)) + "-deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
//    func handleError(error: ApiErrorMessage) {
//        print(error.msg ?? "")
//    }
    
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

// MARK: AnyObject + Reactive
extension Reactive where Base: AnyObject {
    func synchronizedBag<T>( _ action: () -> T) -> T {
        objc_sync_enter(self.base)
        let result = action()
        objc_sync_exit(self.base)
        return result
    }
}

public extension Reactive where Base: AnyObject {

    /// a unique DisposeBag that is related to the Reactive.Base instance only for Reference type
    var disposeBag: DisposeBag {
        get {
            return synchronizedBag {
                if let disposeObject = objc_getAssociatedObject(base, &disposeBagContext) as? DisposeBag {
                    return disposeObject
                }
                let disposeObject = DisposeBag()
                objc_setAssociatedObject(base, &disposeBagContext, disposeObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return disposeObject
            }
        }

        set {
            synchronizedBag {
                objc_setAssociatedObject(base, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

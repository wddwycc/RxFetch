//
//  Fetch.swift
//  RxFetchTests
//
//  Created by duan on 2019/05/16.
//

import RxSwift
import RxCocoa

public typealias Trigger<Payload> = Observable<Payload>
public typealias TaskGen<Payload, Resp> = (Payload) -> Observable<Resp>


public func fetch<Payload, Resp>(
    trigger: Trigger<Payload>,
    taskGen: @escaping TaskGen<Payload, Resp>,
    disposedBy: DisposeBag
) -> (
    data: Driver<Resp>,
    loading: Driver<Bool>,
    erroring: Driver<Bool>
) {
    let data = PublishRelay<Resp>()
    let loading = BehaviorRelay(value: false)
    let erroring = BehaviorRelay(value: false)

    trigger
        .do(onNext: { _ in
            erroring.accept(false)
            loading.accept(true)
        })
        .flatMapLatest { taskGen($0).materialize() }
        .subscribe(onNext: {
            switch $0 {
            case .next(let val):
                data.accept(val)
                loading.accept(false)
            case .error:
                erroring.accept(true)
                loading.accept(false)
            case .completed: return
            }
        })
        .disposed(by: disposedBy)

    return (
        data: data.asDriver { _ in .empty() },
        loading: loading.asDriver().distinctUntilChanged(),
        erroring: erroring.asDriver().distinctUntilChanged()
    )
}

public func fetch<Resp>(
    taskGen: @escaping TaskGen<(), Resp>,
    disposedBy: DisposeBag
) -> (
    data: Driver<Resp>,
    loading: Driver<Bool>,
    erroring: Driver<Bool>
) {
    return fetch(trigger: Observable.just(()), taskGen: taskGen, disposedBy: disposedBy)
}

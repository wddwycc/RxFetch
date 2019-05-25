//
//  InfiniteFetch.swift
//  RxFetch
//
//  Created by duan on 2019/05/17.
//

import RxSwift
import RxCocoa


func infiniteFetch<Payload, Resp>(
    reloadTrigger: Trigger<Payload>,
    loadMoreTrigger: (Resp) -> Observable<Resp>,
    taskGen: @escaping TaskGen<Payload, Resp>,
    disposedBy: DisposeBag
) {
    
}

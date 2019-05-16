//
//  fetchTests.swift
//  RxFetchTests
//
//  Created by duan on 2019/05/16.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxFetch

func scheduledTaskGen(_ scheduler: TestScheduler, asSuccess: Bool = true) -> TaskGen<String, String> {
    return { str in
        let data = scheduler.createColdObservable([
            asSuccess ? .next(500, str + str) : .error(500, NSError())
            ])
        return data.asObservable()
    }
}

func scheduledFetch(
    scheduler: TestScheduler,
    trigger: Trigger<String>,
    taskGen: @escaping TaskGen<String, String>,
    disposedBy: DisposeBag
) -> (
    data: TestableObserver<String>,
    loading: TestableObserver<Bool>,
    erroring: TestableObserver<Bool>
) {
    // TODO: Refactor to reduce duplication
    let (data, loading, erroring) = fetch(trigger: trigger, taskGen: taskGen, disposedBy: disposedBy)
    let dataObserver = scheduler.createObserver(String.self)
    let loadingObserver = scheduler.createObserver(Bool.self)
    let erroringObserver = scheduler.createObserver(Bool.self)
    data.drive(dataObserver).disposed(by: disposedBy)
    loading.drive(loadingObserver).disposed(by: disposedBy)
    erroring.drive(erroringObserver).disposed(by: disposedBy)
    return (
        data: dataObserver,
        loading: loadingObserver,
        erroring: erroringObserver
    )
}

class fetchTests: XCTestCase {

    var scheduler: TestScheduler!
    var disposeBag: DisposeBag!

    override func setUp() {
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }

    func scheduled(_ triggerEvents: [Recorded<Event<String>>], taskGenAsSuccess: Bool = true) -> (
        data: TestableObserver<String>,
        loading: TestableObserver<Bool>,
        erroring: TestableObserver<Bool>
    ) {
        let trigger = scheduler.createColdObservable(triggerEvents)
        return scheduledFetch(
            scheduler: scheduler,
            trigger: trigger.asObservable(),
            taskGen: scheduledTaskGen(scheduler, asSuccess: taskGenAsSuccess),
            disposedBy: disposeBag)
    }

    func testSuccess() {
        let (data, loading, erroring) = scheduled([.next(10, "🍎")])
        scheduler.start()

        XCTAssertEqual(data.events, [.next(510, "🍎🍎")])
        XCTAssertEqual(loading.events, [
            .next(0, false),
            .next(10, true),
            .next(510, false),
            ])
        XCTAssertEqual(erroring.events, [
            .next(0, false),
            ])
    }

    func testFailure() {
        let (data, loading, erroring) = scheduled([
            .next(10, "🍎")
            ], taskGenAsSuccess: false)
        scheduler.start()

        XCTAssertEqual(data.events, [])
        XCTAssertEqual(loading.events, [
            .next(0, false),
            .next(10, true),
            .next(510, false),
            ])
        XCTAssertEqual(erroring.events, [
            .next(0, false),
            .next(510, true)
            ])
    }

    func testTaskOverride() {
        let (data, loading, erroring) = scheduled([
            .next(10, "🍎"),
            .next(110, "🍎"),
            ])
        scheduler.start()

        XCTAssertEqual(data.events, [.next(610, "🍎🍎")])
        XCTAssertEqual(loading.events, [
            .next(0, false),
            .next(10, true),
            .next(610, false),
            ])
        XCTAssertEqual(erroring.events, [
            .next(0, false),
            ])
    }
}

@testable import AnyTask

import XCTest

final class Task_AnyTaskTests: XCTestCase {

    func test_Erasure() {
        XCTAssertEqual(Task {}.erased().options, [.automaticallyCancelOnDenit])
    }

    func test_StoreInCollection() {
        var collection: [AnyTask] = []
        XCTAssertEqual(collection.count, 0)

        let taskA = Task {}.store(in: &collection)
        XCTAssertEqual(collection.count, 1)
        XCTAssertEqual(collection.last, taskA)
        XCTAssertEqual(taskA.options, [.automaticallyCancelOnDenit])

        let taskB = Task {}.store(in: &collection)
        XCTAssertEqual(collection.count, 2)
        XCTAssertEqual(collection.first, taskA)
        XCTAssertEqual(collection.last, taskB)
        XCTAssertEqual(taskB.options, [.automaticallyCancelOnDenit])

        let taskC = Task {}.store(in: &collection, options: [])
        XCTAssertEqual(collection.count, 3)
        XCTAssertEqual(collection.first, taskA)
        XCTAssertEqual(collection.last, taskC)
        XCTAssertEqual(taskC.options, [])
    }

    func test_StoreInSet() {
        var set: Set<AnyTask> = []
        XCTAssertEqual(set.count, 0)

        let taskA = Task {}.store(in: &set)
        XCTAssertTrue(taskA.inserted)
        XCTAssertEqual(set.count, 1)
        XCTAssertTrue(set.contains(taskA.memberAfterInsert))
        XCTAssertEqual(taskA.memberAfterInsert.options, [.automaticallyCancelOnDenit])

        let taskB = Task {}.store(in: &set)
        XCTAssertTrue(taskB.inserted)
        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(taskB.memberAfterInsert))
        XCTAssertEqual(taskB.memberAfterInsert.options, [.automaticallyCancelOnDenit])

        let taskC = Task {}.store(in: &set, options: [])
        XCTAssertTrue(taskC.inserted)
        XCTAssertEqual(set.count, 3)
        XCTAssertTrue(set.contains(taskC.memberAfterInsert))
        XCTAssertEqual(taskC.memberAfterInsert.options, [])
    }
}

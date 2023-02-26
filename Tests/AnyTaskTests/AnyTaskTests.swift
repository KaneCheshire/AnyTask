@testable import AnyTask

import XCTest

final class AnyTaskTests: XCTestCase {

    func test_GivenOptions_WhenConstructing_ThenOptionsSet() {
        XCTAssertEqual(AnyTask(Task {}, options: []).options, [])
        XCTAssertEqual(AnyTask(Task {}, options: [.assertOnOverCancellation]).options, [.assertOnOverCancellation])
        XCTAssertEqual(AnyTask(Task {}, options: [.automaticallyCancelOnDenit]).options, [.automaticallyCancelOnDenit])
        XCTAssertEqual(AnyTask(Task {}).options, [.automaticallyCancelOnDenit])
    }

    func test_GivenTaskNotCancelled_ThenIsCancelledFalse() {
        // Given
        let task = Task {}
        let sut = AnyTask(task, options: .assertOnOverCancellation, assertionFailureHandler: { _, _, _ in })

        // When
        XCTAssertFalse(task.isCancelled)

        // Then
        XCTAssertFalse(sut.isCancelled)
    }

    func test_GivenTaskCancelled_ThenIsCancelledTrue() {
        // Given
        let task = Task {}
        task.cancel()
        let sut = AnyTask(task, options: .assertOnOverCancellation, assertionFailureHandler: { _, _, _ in })

        // When
        XCTAssertTrue(task.isCancelled)

        // Then
        XCTAssertTrue(sut.isCancelled)
    }

    func test_GivenNotAlreadyCancelled_WhenCancelCalled_ThenTaskCancelled() {
        // Given
        let task = Task {}
        let sut = AnyTask(task, options: .assertOnOverCancellation, assertionFailureHandler: { _, _, _ in XCTFail("Assertion handler should not be called") })

        // When
        XCTAssertFalse(task.isCancelled)
        sut.cancel()

        // Then
        XCTAssertTrue(task.isCancelled)
    }

    func test_GivenNotAlreadyCancelled_WhenDeinitted_ThenTaskCancelled() {
        // Given
        let task = Task {}
        var sut: AnyTask? = AnyTask(task, options: .automaticallyCancelOnDenit, assertionFailureHandler: { _, _, _ in XCTFail("Assertion handler should not be called") })

        // When
        XCTAssertFalse(task.isCancelled)
        sut = nil

        // Then
        XCTAssertNil(sut)
        XCTAssertTrue(task.isCancelled)
    }

    func test_GivenNotAlreadyCancelled_WhenDeinitted_ThenTaskNotCancelled() {
        // Given
        let task = Task {}
        var sut: AnyTask? = AnyTask(task, options: [], assertionFailureHandler: { _, _, _ in XCTFail("Assertion handler should not be called") })

        // When
        XCTAssertFalse(task.isCancelled)
        sut = nil

        // Then
        XCTAssertNil(sut)
        XCTAssertTrue(task.isCancelled)
    }

    func test_GivenAlreadyCancelled_WhenDeinitted_ThenAssertionHandlerNotCalled() {
        // Given
        let task = Task {}
        task.cancel()
        var sut: AnyTask? = AnyTask(task, options: [.automaticallyCancelOnDenit, .assertOnOverCancellation], assertionFailureHandler: { _, _, _ in XCTFail("Should not be called") })

        // When
        XCTAssertTrue(task.isCancelled)
        sut = nil

        // Then
        XCTAssertNil(sut)
    }

    func test_GivenAlreadyCancelled_WhenCancelCalled_ThenAssertionHandlerCalled() {
        // Given
        let task = Task {}
        task.cancel()
        let expectation = expectation(description: "assertion handler")
        let sut = AnyTask(task, options: .assertOnOverCancellation, assertionFailureHandler: { message, file, line in
            XCTAssertEqual(message(), "The task was cancelled more than once! You're receiving this assertion because this AnyTask is configured to assert on over cancellation.")
            expectation.fulfill()
        })

        // When
        sut.cancel()

        // Then
        waitForExpectations(timeout: 0)
    }

    func test_GivenAlreadyCancelled_WhenCancelCalled_ThenAssertionHandlerNotCalled() {
        // Given
        let task = Task {}
        task.cancel()
        let sut = AnyTask(task, options: [], assertionFailureHandler: { _, _, _ in XCTFail("Should not be called") })

        // When
        sut.cancel()

        // Then
        XCTAssertTrue(sut.isCancelled)
    }

    func test_EquatableConformance() {
        let taskA = Task {}
        let taskB = Task {}
        XCTAssertEqual(AnyTask(taskA), AnyTask(taskA))
        XCTAssertNotEqual(AnyTask(taskA), AnyTask(taskB))
    }

    func test_HashableConformance() {
        let taskA = Task {}
        let taskB = Task {}
        XCTAssertEqual(AnyTask(taskA).hashValue, AnyTask(taskA).hashValue)
        XCTAssertNotEqual(AnyTask(taskA).hashValue, AnyTask(taskB).hashValue)
    }
}

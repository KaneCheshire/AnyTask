import Foundation

/// A type-erased task that you can use to easily store in a collection of tasks, similar to Combine's `AnyCancellable`.
///
/// By configuring the task with `automaticallyCancelOnDenit` you will get cancellation of the task for free
/// when the `AnyTask` is destroyed, however you can choose to opt out of this behaviour if you prefer to control cancellation manually.
///
/// Since the task is type-erased, there is no API to retrieve the result of the task, but you can check if it is cancelled.
public final class AnyTask {

    /// Whether the task is cancelled.
    public var isCancelled: Bool { isCancelledBlock() }
    /// The `Options` the task is configured with.
    public let options: Options

    private let onCancel: () -> Void
    private let isCancelledBlock: () -> Bool
    private let hashValueBlock: () -> Int
    private let assertionFailureHandler: (@autoclosure () -> String, StaticString, UInt) -> Void

    /// Creates a new `AnyTask` by erasing the `Task` passed as the `task` parameter.
    /// - Parameters:
    ///   - task: The task to erase.
    ///   - options: The options to configure the erased task with,
    public convenience init<Success, Failure>(
        _ task: Task<Success, Failure>,
        options: Options = .default
    ) {
        self.init(
            task,
            options: options,
            assertionFailureHandler: assertionFailure
        )
    }

    init<Success, Failure>(
        _ task: Task<Success, Failure>,
        options: Options,
        assertionFailureHandler: @escaping (@autoclosure () -> String, StaticString, UInt) -> Void
    ) {
        self.options = options
        onCancel = task.cancel
        isCancelledBlock = { task.isCancelled }
        hashValueBlock = { task.hashValue }
        self.assertionFailureHandler = assertionFailureHandler
    }

    deinit { if !isCancelled { cancel() } }

    /// Cancels the task if it isn't already cancelled.
    /// If `options` is configured with `.assertOnOverCancellation` and `cancel` is called when `isCancelled` is already true,
    /// then an assertion failure will be made, crashing the application in debug mode.
    public func cancel() {
        guard !isCancelled else { return assertCancellationIfRequired() }
        onCancel()
    }

    private func assertCancellationIfRequired() {
        guard options.contains(.assertOnOverCancellation) else { return }
        assertionFailureHandler("The task was cancelled more than once! You're receiving this assertion because this AnyTask is configured to assert on over cancellation.", #file, #line)
    }
}

extension AnyTask {

    /// Represents a set of options available to configure an `AnyTask` with.
    public struct Options: OptionSet {
        /// Configures the task to automatically cancel itself when it is destroyed.
        public static let automaticallyCancelOnDenit: Self = .init(rawValue: 1 << 0)
        /// Configures the task to assert when a call to cancel it occurs when it is already cancelled.
        public static let assertOnOverCancellation: Self = .init(rawValue: 1 << 1)
        /// The default set of options, comprising of `.automaticallyCancelOnDenit`
        public static let `default`: Self = [.automaticallyCancelOnDenit]

        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }
    }
}

extension AnyTask: Hashable {

    public func hash(into hasher: inout Hasher) { hasher.combine(hashValueBlock()) }
    public static func == (lhs: AnyTask, rhs: AnyTask) -> Bool { lhs.hashValue == rhs.hashValue }
}

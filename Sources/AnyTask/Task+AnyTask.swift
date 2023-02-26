import Foundation

public extension Task {

    /// Erases this task to an `AnyTask`.
    /// - Parameter options: The options to configure the task with.
    /// - Returns: This task erased to `AnyTask`.
    func erased(options: AnyTask.Options = .default) -> AnyTask {
        .init(self, options: options)
    }

    /// Erases this task and stores it in the collection.
    /// - Parameters:
    ///   - collection: The collection to store in.
    ///   - options: The options to configure the task with.
    @discardableResult
    func store<Collection: RangeReplaceableCollection>(
        in collection: inout Collection,
        options: AnyTask.Options = .default
    ) -> AnyTask where Collection.Element == AnyTask {
        let task = erased(options: options)
        collection.append(task)
        return task
    }

    @discardableResult
    func store(
        in set: inout Set<AnyTask>,
        options: AnyTask.Options = .default
    ) -> (inserted: Bool, memberAfterInsert: AnyTask) {
        set.insert(erased(options: options))
    }
}

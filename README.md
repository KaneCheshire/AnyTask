# AnyTask

A small Swift Package introducing an `AnyTask` type, providing type-erasure for Swift `Task`s, which makes it very easy 
to store in a collection since the generics are removed.

Additionally, an `AnyTask` will cancel itself when it is being destroyed, releiving you of the need to manually cancel any
pending tasks when a collection of `AnyTask`s is destroyed. You can also opt out of this behaviour if you prefer.

Finally, an `AnyTask` can also be configured to fail an assertion in debug mode if a cancellation attempt occurs when the
task is already cancelled.

## Why is this useful

It's easy to forget to cancel a Swift `Task`, which will continue to run even if nothing keeps a reference to it. 
Unless you are creating a "fire and forget" task, you probably want to make sure that it is cancelled when it is no longer
needed (i.e. when an owning class is destroyed).

This means that you have to manually store a `Task` somewhere so that it can be cancelled at a later date, except it's
quite difficult to store different types of `Task`s in a collection because they can be specialized with different types:

```swift
let taskA = Task<Bool, Never> { // code to return a Bool }
let taskB = Task<Void, Error> { // code that doesn't return a value but can throw }
let tasks = [taskA, taskB] // This code won't compile
```

This means you need a different collection for every posible specialized `Task` type, or just a different property for every
`Task` type, and then make sure that you remember to cancel them all properly in `deinit`.

`AnyTask` type-erases `Task`s, which means that you can just store every task you create in a single collection (or set) 
and it will also automatically cancel all the tasks in the collection when the collection is destroyed, because 
`AnyTask` cancels itself when it is deinitted:

```swift
var tasks: [AnyTask] = []
Task<Bool, Never> {}.store(in: &tasks)
Task<Void, Error> {}.store(in: &tasks)

// When `tasks` is destroyed, the `AnyTask`s will automatically cancel the underlying type-erased `Task`s. 
```

## Usage
### Erasing a `Task`

You can create an `AnyTask` manually from a Swift `Task` but it is simpler to use a convenience function on `Task` to store
in a collection of `AnyTask`s:

```swift
var tasks: [AnyTask] = []
Task {
    // Async task code
}.store(in: &tasks)
```

You can also do the same thing with a set of `AnyTask`s:

```swift
var tasks: Set<AnyTask> = []
Task {
    // Async task code
}.store(in: &tasks)
```

If you want to you can also make a call to erase a task explicitly:

```swift
let task: AnyTask = Task {
    // Async task code
}.erased()
```

Or you can also create an `AnyTask` manually from a `Task`:

```swift
let task = Task {
    // Async task code
}
let anyTask = AnyTask(task)
```

### Setting options

Wherever you are able to erase a `Task` to `AnyTask` you are able to override the default options that the `AnyTask` is 
configured with. 

```swift
Task {}.store(in: &tasks, options: [.assertOnOverCancellation])

Task {}.erased(options: [])

AnyTask(Task {}, options: [])
```

You can see a full list of available `Options` in code.


### Cancelling a task

You can still manually check if an `AnyTask` is cancelled by checking the `isCancelled` property:

```swift
var tasks: [AnyTask] = []
let task: AnyTask = Task {}.store(in: &tasks)
task.isCancelled
```

You can also explicitly cancel a task by calling `cancel()`:

```swift
var tasks: [AnyTask] = []
let task: AnyTask = Task {}.store(in: &tasks)
task.cancel()
```

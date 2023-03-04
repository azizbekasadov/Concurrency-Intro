#  Intro to Concurrency (Traditional)

#Concurrency
 - is "the decomposability property of a program, algorithm, or problem into order-independent or partially-ordered components or units."
- this means is looking at the logic of your app to determine which pieces can run at the same time, and possibly in a random order, yet still result in a correct implementation of your data flow.

Tasks which access different resources, or read-only shared resources, can all be accessed via different threads to allow for much faster processing.

#Operation class 
- Built on top of Grand Central Dispatch, operations allow for the handling of more complex scenarios such as reusable code to be run on a background thread, having one thread depend on another, and even canceling an operation before it’s started or completed.

There are two APIs that you'll use when making your app concurrent: Grand Central Dispatch, commonly referred to as GCD, and Operations. 

#Grand Central Dispatch
`GCD` - is Apple’s implementation of C’s libdispatch library. Its purpose is to queue up tasks — either a method or a closure — that can be run in parallel, depending on availability of resources; it then executes the tasks on an available processor core.

- All of the tasks that GCD manages for you are placed into GCD-managed first-in, first-out (FIFO) queues. Each task that you submit to a queue is then executed against a pool of threads fully managed by the system.

###Note: There is no guarantee as to which thread your task will execute against.

#Synchronous and asynchronous tasks
- Work placed into the queue may either run synchronously or asynchronously. When running a task synchronously, your app will wait and block the current run loop until execution finishes before moving on to the next task. Alternatively, a task that is run asynchronously will start, but return execution to your app immediately. This way, the app is free to run other tasks while the first one is executing.

````
// Class level variable
let queue = DispatchQueue(label: "com.somename.worker.queue")

// Somewhere in your function
queue.async {
    // Call slow non-UI methods here
    DispatchQueue.main.async {
        // Update the UI here
    }
}


````

- You create a queue, submit a task to it to run asynchronously on a background thread, and, when it’s complete, you delegate the code back to the main thread to update the UI.

#Serial and concurrent queues

- The queue to which your task is submitted also has a characteristic of being either serial or concurrent. Serial queues only have a single thread associated with them and thus only allow a single task to be executed at any given time. A concurrent queue, on the other hand, is able to utilize as many threads as the system has resources for. Threads will be created and released as necessary on a concurrent queue.

-  There is no guarantee that more than one task will run at a time. If your iOS device is completely bogged down and your app is competing for resources, it may only be capable of running a single task.

#Asynchronous doesn’t mean concurrent
- While the difference seems subtle at first, just because your tasks are asynchronous doesn’t mean they will run concurrently. You’re actually able to submit asynchronous tasks to either a serial queue or a concurrent queue. Being synchronous or asynchronous simply identifies whether or not the queue on which you’re running the task must wait for the task to complete before it can spawn the next task.

`Categorizing something as serial versus concurrent` identifies whether the queue has a single thread or multiple threads available to it. Submitting three asynchronous tasks to a serial queue means that each task has to completely finish before the next task is able to start as there is only one thread available.

##A task being synchronous or not speaks to the source of the task. Being serial or concurrent speaks to the destination of the task.

#Operations
GCD is great for common tasks that need to be run a single time in the background. When you find yourself building functionality that should be reusable — such as image editing operations — you will likely want to encapsulate that functionality into a class. By subclassing Operation, you can accomplish that goal!

##Operation subclassing
Operations are fully-functional classes that can be submitted to an OperationQueue, just like you'd submit a closure of work to a DispatchQueue for GCD. Because they’re classes and can contain variables, you gain the ability to know what state the operation is in at any given point.
Operations can exist in any of the following states: • isReady
###• isExecuting
###• isCancelled
###• isFinished
Unlike GCD, an operation is run synchronously by default, and getting it to run asynchronously requires more work. While you can directly execute an operation yourself, that’s almost never going to be a good idea due to its synchronous nature. You'll want to get it off of the main thread by submitting it to an OperationQueue so that your UI performance isn’t impacted.

Operations provide greater control over your tasks as you can now handle such common needs as cancelling the task, reporting the state of the task, wrapping asynchronous tasks into an operation and specifying dependences between various tasks.

#BlockOperation
Sometimes, you find yourself working on an app that heavily uses operations, but find that you have a need for a simpler, GCD-like, closure. If you don’t want to also create a DispatchQueue, then you can instead utilize the BlockOperation class.
BlockOperation subclasses Operation for you and manages the concurrent execution of one or more closures on the default global queue. However, being an actual Operation subclass lets you take advantage of all the other features of an operation.

Block operations run concurrently. If you need them to run serially, you'll need to setup a dispatch queue instead.

- GCD tends to be simpler to work with for simple tasks you just need to execute and forget. Operations provide much more functionality when you need to keep track of a job or maintain the ability to cancel it.

- If you’re just working with methods or chunks of code that need to be executed, GCD is a fitting choice. If you’re working with objects that need to encapsulate data and functionality then you’re more likely to utilize Operations. Some developers even go to the extreme of saying that you should always use Operations because it’s built on top of GCD, and Apple’s guidance says to always use the highest level of abstraction provided.

#Threads
There are many advantages to splitting your app’s work into multiple threads:
• Faster execution: By running tasks on threads, it’s possible for work to be done
concurrently, which will allow it to finish faster than running everything serially.
• Responsiveness: If you only perform user-visible work on the main UI thread, then users won’t notice that the app slows down or freezes up periodically due to work that could be performed on another thread.
• Optimized resource consumption: Threads are highly optimized by the OS.

When you create a queue, the OS will potentially create and assign one or more threads to the queue. If existing threads are available, they can be reused; if not, then the OS will create them as necessary.

##Main queue
When your app starts, a main dispatch queue is automatically created for you. It’s a serial queue that’s responsible for your UI. Because it’s used so often, Apple has made it available as a class variable, which you access via DispatchQueue.main. You never want to execute something synchronously against the main queue, unless it’s related to actual UI work. Otherwise, you’ll lock up your UI which could potentially degrade your app performance.

If you recall from the previous chapter, there are two types of dispatch queues: serial or concurrent. The default initializer will create a serial queue wherein each task must complete before the next task is able to start.

Concurrent queues are so common that Apple has provided six different global concurrent queues, depending on the Quality of service (QoS) the queue should have.

If you just need a concurrent queue but don’t want to manage your own, you can use the global class method on DispatchQueue to get one of the pre-defined global queues:

```
    let queue = DispatchQueue.global(qos: .userInteractive)
```

//
//  Threads.swift
//  Intro2Concurrency
//
//  Created by Azizbek Asadov on 04/03/23.
//

import Foundation

// MARK: - Serial Queue
let label = "com.azizbekasadov.mycoolapp.networking"
let queue = DispatchQueue(label: label)


// MARK: - Concurrent Queue
let label1 = "com.azizbekasadov.mycoolapp.networking"
let queue1 = DispatchQueue(label: label, attributes: DispatchQueue.Attributes.concurrent)


// MARK: - Quality of Service
let queue2 = DispatchQueue.global(qos: .userInteractive)

//    .userInteractive
//    The .userInteractive QoS is recommended for tasks that the user directly interacts with. UI-updating calculations, animations or anything needed to keep the UI responsive and fast. If the work doesn’t happen quickly, things may appear to freeze. Tasks submitted to this queue should complete virtually instantaneously.

//    .userInitiated
//    The .userInitiated queue should be used when the user kicks off a task from the UI that needs to happen immediately, but can be done asynchronously. For example, you may need to open a document or read from a local database. If the user clicked a button, this is probably the queue you want. Tasks performed in this queue should take a few seconds or less to complete.

//    .utility
//    You’ll want to use the .utility dispatch queue for tasks that would typically include a progress indicator such as long-running computations, I/O, networking or continuous data feeds. The system tries to balance responsiveness and performance with energy efficiency. Tasks can take a few seconds to a few minutes in this queue.

//    .background
//    For tasks that the user is not directly aware of you should use the .background queue. They don’t require user interaction and aren’t time sensitive. Prefetching, database maintenance, synchronizing remote servers and performing backups are all great examples. The OS will focus on energy efficiency instead of speed. You’ll want to use this queue for work that will take significant time, on the order of minutes or more.

//    .default and .unspecified
//    There are two other possible choices that exist, but you should not use explicitly. There’s a .default option, which falls between .userInitiated and .utility and is the default value of the qos argument. It’s not intended for you to directly use. The second option is .unspecified, and exists to support legacy APIs that may opt the thread out of a quality of service. It’s good to know they exist, but if you’re using them, you’re almost certainly doing something wrong.

//Global queues are always concurrent and first-in, first-out.

// MARK: - Inferring QoS
let label3 = "com.azizbekasadov.qos.app.inferring"
let queue3 = DispatchQueue(label: label3,
                           qos: .userInitiated,
                           attributes: .concurrent)
//The OS will pay attention to what type of tasks are being submitted to the queue and make changes as necessary.
//If you submit a task with a higher quality of service than the queue has, the queue’s level will increase. Not only that, but all the operations enqueued will also have their priority raised as well.
//If the current context is the main thread, the inferred QoS is .userInitiated. You can specify a QoS yourself, but as soon as you’ll add a task with a higher QoS, your queue’s QoS service will be increased to match it.

// MARK: - Adding Task to the Queue
//Dispatch queues provide both sync and async methods to add a task to a queue.

final class SomeClass {
    private var textLabel: String = ""
    
    func invokeServerInteraction() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            // Perform your work here
            // ...
            // Switch back to the main queue to
            // update your UI
            DispatchQueue.main.async {
                self.textLabel = "New articles available!"
            }
        }
    }
}

//Strongly capturing self in a GCD async closure will not cause a reference cycle (e.g. a retain cycle) since the whole closure will be deallocated once it’s completed, but it will extend the lifetime of self.
//You should never perform UI updates on any queue other than the main queue. If it’s not documented what queue an API callback uses, dispatch it to the main queue!

//Use extreme caution when submitting a task to a dispatch queue synchronously. If you find yourself calling the sync method, instead of the async method, think once or twice whether that’s really what you should be doing. If you submit a task synchronously to the current queue, which blocks the current queue, and your task tries to access a resource in the current queue, then your app will deadlock
//Never call sync from the main thread, since it would block your main thread and could even potentially cause a deadlock.

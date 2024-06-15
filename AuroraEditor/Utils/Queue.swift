//
//  Queue.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/21.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

/// Queue specific key
private let queueSpecificKey = DispatchSpecificKey<NSObject>()

/// Global Main Queue
let globalMainQueue = Queue(queue: DispatchQueue.main, specialIsMainQueue: true)

/// Global User Interactive Queue
let globalUserInteractiveQueue = Queue(queue: DispatchQueue.global(qos: .userInteractive),
                                               specialIsMainQueue: false)

/// Global User Initiated Queue
let globalUserInitiatedQueue = Queue(queue: DispatchQueue.global(qos: .userInitiated),
                                             specialIsMainQueue: false)

/// Global Utility Queue
let globalDefaultQueue = Queue(queue: DispatchQueue.global(qos: .default), specialIsMainQueue: false)

/// Global Background Queue
let globalBackgroundQueue = Queue(queue: DispatchQueue.global(qos: .background), specialIsMainQueue: false)

/// Queue
public final class Queue {
    /// Native Queue
    private let nativeQueue: DispatchQueue

    /// Specific
    private var specific = NSObject()

    /// Special is Main Queue
    private let specialIsMainQueue: Bool

    /// Queue
    public var queue: DispatchQueue {
        return self.nativeQueue
    }

    /// Global Queue
    /// 
    /// - Returns: Global Queue
    public class func mainQueue() -> Queue {
        return globalMainQueue
    }

    /// Global Default Queue
    /// 
    /// - Returns: globalDefaultQueue
    public class func concurrentDefaultQueue() -> Queue {
        return globalDefaultQueue
    }

    /// Global Background Queue
    /// 
    /// - Returns: globalBackgroundQueue
    public class func concurrentBackgroundQueue() -> Queue {
        return globalBackgroundQueue
    }

    /// Init with queue
    /// 
    /// - Parameter queue: queue
    public init(queue: DispatchQueue) {
        self.nativeQueue = queue
        self.specialIsMainQueue = false
    }

    /// Init with queue
    /// 
    /// - Parameter queue: queue
    /// - Parameter specialIsMainQueue: special is main queue
    fileprivate init(queue: DispatchQueue, specialIsMainQueue: Bool) {
        self.nativeQueue = queue
        self.specialIsMainQueue = specialIsMainQueue
    }

    /// Init
    /// 
    /// - Parameters:
    ///   - name: name
    ///   - qos: quality of service
    public init(name: String? = nil, qos: DispatchQoS = .default) {
        self.nativeQueue = DispatchQueue(label: name ?? "", qos: qos)

        self.specialIsMainQueue = false

        self.nativeQueue.setSpecific(key: queueSpecificKey, value: self.specific)
    }

    /// Is current
    /// 
    /// - Returns: current queue?
    public func isCurrent() -> Bool {
        if DispatchQueue.getSpecific(key: queueSpecificKey) === self.specific {
            return true
        } else if self.specialIsMainQueue && Thread.isMainThread {
            return true
        } else {
            return false
        }
    }

    /// Execute async
    /// 
    /// - Parameter function: block to execute
    public func async(_ function: @escaping () -> Void) {
        if self.isCurrent() {
            function()
        } else {
            self.nativeQueue.async(execute: function)
        }
    }

    /// Execute sync
    /// 
    /// - Parameter function: block to execute
    public func sync(_ function: () -> Void) {
        if self.isCurrent() {
            function()
        } else {
            self.nativeQueue.sync(execute: function)
        }
    }

    /// Dispatch
    /// 
    /// - Parameter function: block to execute
    public func justDispatch(_ function: @escaping () -> Void) {
        self.nativeQueue.async(execute: function)
    }

    /// Dispatch
    ///
    /// - Parameters:
    ///   - qos: quality of service
    ///   - function: block to execute
    public func justDispatchWithQoS(qos: DispatchQoS, _ function: @escaping () -> Void) {
        self.nativeQueue.async(group: nil, qos: qos, flags: [.enforceQoS], execute: function)
    }

    /// Execute after
    /// 
    /// - Parameters:
    ///   - delay: Delay
    ///   - function: block to execute
    public func after(_ delay: Double, _ function: @escaping() -> Void) {
        let time: DispatchTime = DispatchTime.now() + delay
        self.nativeQueue.asyncAfter(deadline: time, execute: function)
    }
}

//
//  DependencyFacrory.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

private struct Weak<Instance: AnyObject> {
    weak var instance: Instance?

    init(_ instance: Instance) {
        self.instance = instance
    }
}

open class DependencyFactory {
    enum Lifecycle {
        case shared
        case weakShared
        case unshared
        case scoped
    }

    struct InstanceKey: Hashable, CustomStringConvertible {
        let lifecycle: Lifecycle
        let name: String

        func hash(into hasher: inout Hasher) {
            hasher.combine(lifecycle)
            hasher.combine(name)
        }

        var description: String {
            return "\(lifecycle)(\(name))"
        }

        static func == (lhs: InstanceKey, rhs: InstanceKey) -> Bool {
            return (lhs.lifecycle == rhs.lifecycle) && (lhs.name == rhs.name)
        }
    }

    private var sharedInstances: [String: Any] = [:]
    private var weakSharedInstances: [String: Any] = [:]
    private var scopedInstances: [String: Any] = [:]
    private var instanceStack: [InstanceKey] = []
    private var configureStack: [() -> Void] = []
    private var requestDepth = 0

    public init() { }

    public final func shared<T>(name: String = #function, factory: () -> T, configure: ((T) -> Void)? = nil) -> T {
        return shared(name: name, factory(), configure: configure)
    }

    public final func shared<T>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        if let instance = sharedInstances[name] as? T {
            return instance
        }

        return inject(
            lifecycle: .shared,
            name: name,
            factory: factory,
            configure: configure
        )
    }

    public final func scoped<T>(name: String = #function, factory: () -> T, configure: ((T) -> Void)? = nil) -> T {
        return scoped(name: name, factory(), configure: configure)
    }

    public final func scoped<T>(
        name: String = #function,
        _ factory: @autoclosure () -> T,
        configure: ((T) -> Void)? = nil
    ) -> T {
        if let instance = scopedInstances[name] as? T {
            return instance
        }

        return inject(
            lifecycle: .scoped,
            name: name,
            factory: factory,
            configure: configure
        )
    }

    private final func inject<T>(lifecycle: Lifecycle, name: String, factory: () -> T, configure: ((T) -> Void)?) -> T {
        let key = InstanceKey(lifecycle: lifecycle, name: name)

        if lifecycle != .unshared && instanceStack.contains(key) {
            fatalError("Circular dependency from one of \(instanceStack) to \(key) in initializer")
        }

        instanceStack.append(key)
        let instance = factory()
        instanceStack.removeLast()

        switch lifecycle {
        case .shared:
            sharedInstances[name] = instance
        case .weakShared:
            weakSharedInstances[name] = instance
        case .unshared:
            break
        case .scoped:
            scopedInstances[name] = instance
        }

        if let configure = configure {
            configureStack.append({ configure(instance) })
        }

        if instanceStack.isEmpty {
            // A configure call may trigger another instance stack to be generated, so must make a
            // copy of the current configure stack and clear it out for the upcoming requested
            // instances.
            let delayedConfigures = configureStack
            configureStack.removeAll(keepingCapacity: true)

            requestDepth += 1

            for delayedConfigure in delayedConfigures {
                delayedConfigure()
            }

            requestDepth -= 1

            if requestDepth == 0 {
                // This marks the end of an entire instance request tree. Must do final cleanup here.
                // Make sure scoped instances survive until the entire request is complete.
                scopedInstances.removeAll(keepingCapacity: true)
            }
        }

        return instance
    }
}

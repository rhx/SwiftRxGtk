//
//  GObject+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 16/4/17.
//  Copyright © 2017, 2018, 2019 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import RxSwift

/// Extend GObject with `rx` proxy
extension Object: ReactiveCompatible {}

/// Extend GObject references with `rx` proxy
extension ObjectRef: ReactiveCompatible {}

extension Reactive where Base == ObjectRef {
    /// Observerve a given property on an ObjectRef
    ///
    /// - Parameters:
    ///   - type: the type of the observed property
    ///   - property: name of the observed property
    ///   - options: `BindingFlags` to use (defaults to `.sync_create`)
    ///   - retainSelf: `true` if the observable should retain the object
    /// - Returns: an observable for the given property
    public func observe<E, P: PropertyNameProtocol>(_ property: P, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: base, property: property, options: options, retainTarget: retainSelf).asObservable()
    }
}

public extension Reactive where Base: Object {
    /// Observerve a given property on a GObject subclass
    ///
    /// - Parameters:
    ///   - type: the type of the observed property
    ///   - property: name of the observed property
    ///   - options: `BindingFlags` to use (defaults to `.sync_create`)
    ///   - retainSelf: `true` if the observable should retain the object
    /// - Returns: an observable for the given property
    func observe<E, P: PropertyNameProtocol>(_ property: P, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: ObjectRef(base.ptr), property: property, options: options, retainTarget: retainSelf).asObservable()
    }

#if os(Linux)
    /// Observable sequence of object deallocation event.
    /// After object is deallocated one `()` element will be produced and
    /// the sequence will immediately complete.
    var deallocated: Observable<Void> {
        return synchronized {
            return .never() // FIXME: should observe GObject deallocation
        }
    }
#endif

    func synchronized<T>( _ action: () -> T) -> T {
        g_mutex_lock(objectMutex)
        let result = action()
        g_mutex_unlock(objectMutex)
        return result
    }
}


public extension Reactive where Base: ObjectProtocol {
    /// Observerve a given property on a type that conforms to `ObjectProtocol`
    ///
    /// - Parameters:
    ///   - type: the type of the observed property
    ///   - property: name of the observed property
    ///   - options: `BindingFlags` to use (defaults to `.sync_create`)
    ///   - retainSelf: `true` if the observable should retain the object
    /// - Returns: an observable for the given property
    func observe<E, P: PropertyNameProtocol>(_ property: P, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: ObjectRef(base.ptr), property: property, options: options, retainTarget: retainSelf).asObservable()
    }
}


public protocol PropertyObservableProtocol {
    var target: ObjectRef { get }
    var propertyName: PropertyName { get }
    var retainTarget: Bool { get }
    var options: BindingFlags { get }
}

fileprivate let dummy_property: PropertyName = "any"

public class PropertyObserver: PropertyObservableProtocol, Disposable {
    public typealias Callback = (ValueRef) -> Void

    public var object: ObjectRef
    public var target: ObjectRef
    public var binding: BindingRef?
    public var callback: Callback
    public var propertyName: PropertyName
    public var retainTarget: Bool
    public var options: BindingFlags

    public init(parent: PropertyObservableProtocol, callback: @escaping Callback) {
        #if TRACE_RESOURCES
            _ = Resources.incrementTotal()
        #endif

        self.callback = callback
        self.target = parent.target
        self.retainTarget = parent.retainTarget
        self.propertyName = parent.propertyName
        self.options = parent.options
        self.object = ObjectRef(raw: g_object_newv(property_observer_get_type(), 0, nil))

        binding = target.bind(propertyName, to: object, property: dummy_property, flags: options) { src, _ in
            self.callback(src)
            return true
        }
        _ = binding?.ref()

        if retainTarget { _ = target.ref() }
    }

    public func dispose() {
        binding?.unbind()
        binding = nil
        if retainTarget { target.unref() }
        object.unref()
    }

    deinit {
        #if TRACE_RESOURCES
            _ = Resources.decrementTotal()
        #endif
    }
}

public class PropertyObservable<Element, P: PropertyNameProtocol>: ObservableType, PropertyObservableProtocol {
    public typealias E = Element?

    public var target: ObjectRef
    var strongTarget: AnyObject?

    public var propertyName: PropertyName
    public var options: BindingFlags
    public var retainTarget: Bool

    public init(object: ObjectRef, property: P, options: BindingFlags = .sync_create, retainTarget: Bool = false) {
        self.target = object
        self.propertyName = PropertyName(property)
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget { _ = target.ref() }
    }

    deinit {
        if retainTarget { target.unref() }
    }

    public func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
        let observer = PropertyObserver(parent: self) {
            guard let v: Element = $0.get() else {
                    observer.on(.next(nil))
                    return
            }
            observer.on(.next(v))
        }

        return Disposables.create(with: observer.dispose)
    }

}


fileprivate struct GPropertyObserver {
    var parent: GObject
}

fileprivate struct GPropertyObserverClass {
    var parent: GObjectClass
}

fileprivate func property_observer_class_init(_ cl: gpointer?, _: gpointer?) {
    guard let object_class = cl?.assumingMemoryBound(to: GObjectClass.self) else { return }
    object_class.pointee.set_property = property_observer_set_property
    object_class.pointee.get_property = property_observer_get_property
    let readwrite = ParamFlags(rawValue: 3)
    g_object_class_install_property(object_class, 1, g_param_spec_string(dummy_property.name, dummy_property.name, "Dummy property", "", readwrite))
}

fileprivate var type: GType = 0

fileprivate func property_observer_get_type() -> GType {
    if type == 0 {
         type = g_type_register_static_simple(.object, "GPropertyObserver", guint(MemoryLayout<GPropertyObserverClass>.size), property_observer_class_init, guint(MemoryLayout<GPropertyObserver>.size), nil,  GTypeFlags(rawValue: 0))
    }
    return type
}

fileprivate func property_observer_set_property(_ object: UnsafeMutablePointer<GObject>?, _ property_id: guint, _ value: UnsafePointer<GValue>?, _ pspec: UnsafeMutablePointer<GParamSpec>?) {
}

fileprivate func property_observer_get_property(_ object: UnsafeMutablePointer<GObject>?, _ property_id: guint, _ value: UnsafeMutablePointer<GValue>?, _ pspec: UnsafeMutablePointer<GParamSpec>?) {
}

fileprivate var objectMutex: UnsafeMutablePointer<GMutex> = {
    let mutex = UnsafeMutablePointer<GMutex>.allocate(capacity: 1)
    g_mutex_init(mutex)
    return mutex
}()

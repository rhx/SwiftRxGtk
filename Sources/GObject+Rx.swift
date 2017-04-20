//
//  GObject+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 16/4/17.
//  Copyright © 2017 Rene Hexel.  All rights reserved.
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
    public func observe<E>(_ type: E.Type, _ property: PropertyName, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: base, property: property, options: options, retainTarget: retainSelf).asObservable()
    }
}


extension Reactive where Base: Object {
    /// Observerve a given property on a GObject subclass
    ///
    /// - Parameters:
    ///   - type: the type of the observed property
    ///   - property: name of the observed property
    ///   - options: `BindingFlags` to use (defaults to `.sync_create`)
    ///   - retainSelf: `true` if the observable should retain the object
    /// - Returns: an observable for the given property
    public func observe<E>(_ type: E.Type, _ property: PropertyName, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: ObjectRef(base.ptr), property: property, options: options, retainTarget: retainSelf).asObservable()
    }
}


extension Reactive where Base: ObjectProtocol {
    /// Observerve a given property on a type that conforms to `ObjectProtocol`
    ///
    /// - Parameters:
    ///   - type: the type of the observed property
    ///   - property: name of the observed property
    ///   - options: `BindingFlags` to use (defaults to `.sync_create`)
    ///   - retainSelf: `true` if the observable should retain the object
    /// - Returns: an observable for the given property
    public func observe<E>(_ type: E.Type, _ property: PropertyName, options: BindingFlags = .sync_create, retainSelf: Bool = true) -> Observable<E?> {
        return PropertyObservable(object: ObjectRef(base.ptr), property: property, options: options, retainTarget: retainSelf).asObservable()
    }
}


fileprivate protocol PropertyObservableProtocol {
    var target: ObjectRef { get }
    var propertyName: PropertyName { get }
    var retainTarget: Bool { get }
    var options: BindingFlags { get }
}

fileprivate let dummy_property: PropertyName = "any"

fileprivate class PropertyObserver: PropertyObservableProtocol, Disposable {
    typealias Callback = (ValueRef) -> Void

    var object: ObjectRef
    var target: ObjectRef
    var binding: BindingRef?
    var callback: Callback
    var propertyName: PropertyName
    var retainTarget: Bool
    var options: BindingFlags

    init(parent: PropertyObservableProtocol, callback: @escaping Callback) {
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

        if retainTarget { _ = target.ref() }
    }

    func dispose() {
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

fileprivate final class PropertyObservable<Element>: ObservableType, PropertyObservableProtocol {
    typealias E = Element?

    var target: ObjectRef
    var strongTarget: AnyObject?

    var propertyName: PropertyName
    var options: BindingFlags
    var retainTarget: Bool

    init(object: ObjectRef, property: PropertyName, options: BindingFlags = .sync_create, retainTarget: Bool = false) {
        self.target = object
        self.propertyName = property
        self.options = options
        self.retainTarget = retainTarget
        if retainTarget { _ = target.ref() }
    }

    deinit {
        if retainTarget { target.unref() }
    }

    func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == E {
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
    g_object_class_install_property(object_class, 1, g_param_spec_string(dummy_property.name, dummy_property.name, "Dummy property", "", G_PARAM_READWRITE))
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

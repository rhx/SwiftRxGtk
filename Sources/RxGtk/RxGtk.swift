//
//  RxGtk.swift
//
//  Created by Rene Hexel on 16/4/17.
//  Copyright © 2017, 2018, 2019 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import RxSwift
import RxCocoa

public extension Reactive where Base: Object {

    /// Internal convenience method for observing a value
    static func value<C: Object, P: PropertyNameProtocol, T>(_ obj: C, property p: P, setter: @escaping (C, T) -> Void) -> ControlProperty<T> {
        let source: Observable<T> = ControlObservable<T, P>(object: ObjectRef(cPointer: obj.ptr), property: p).asObservable().map { $0! }

        let observer = Binder(obj) { setter($0, $1) }.asObserver()

        return ControlProperty(values: source, valueSink: observer)
    }
}


class ControlObservable<Element, P: PropertyNameProtocol>: PropertyObservable<Element, P> {
    override func subscribe<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let observer = PropertyObserver(parent: self) {
            guard let v: Element = $0.get() else {
                observer.on(.completed)
                return
            }
            observer.on(.next(v))
        }

        return Disposables.create(with: observer.dispose)
    }
}

// MARK: Error binding policies

func bindingErrorToInterface(_ error: Swift.Error) {
    let error = "Binding error to UI: \(error)"
    #if DEBUG
        fatalError(error)
    #else
        print(error)
    #endif
}

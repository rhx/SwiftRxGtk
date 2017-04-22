//
//  RxGtk.swift
//
//  Created by Rene Hexel on 16/4/17.
//  Copyright © 2017 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import RxSwift
import RxCocoa

extension Reactive where Base: Object {

    /// Internal convenience method for observing a value
    static func value<C: Object, P: PropertyNameProtocol, T>(_ control: C, property p: P, setter: @escaping (C, T) -> Void) -> ControlProperty<T> {
        let source: Observable<T> = ControlObservable<T, P>(object: ObjectRef(cPointer: control.ptr), property: p).asObservable().map { $0! }

        let bindingObserver = UIBindingObserver(UIElement: control, binding: setter)

        return ControlProperty<T>(values: source, valueSink: bindingObserver)
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

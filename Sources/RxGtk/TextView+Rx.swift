//
//  TextView+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 22/4/17.
//  Copyright © 2017, 2019 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import CGtk
import Gtk
import RxSwift
import RxCocoa

public extension Reactive where Base: TextView {

    /// Reactive wrapper for the `text` property
    var text: ControlProperty<String> { return value }

    /// Reactive value wrapper for the `value` property.
    var value: ControlProperty<String> {
        _ = TextBufferRef(base.buffer).ref()
        let source: Observable<String> = TextBuffer(base.buffer).rx.observe(EntryPropertyName.text).map { $0 ?? "" }
        let observer = Binder(base) { (control, value: String) in
            control.buffer.map {
                TextBufferRef($0).set(text: value, len: CInt(value.utf8.count))
            }
        }
        return ControlProperty(values: source, valueSink: observer)
    }
}

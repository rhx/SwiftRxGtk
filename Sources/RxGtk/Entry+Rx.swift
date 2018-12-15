//
//  Entry+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 22/4/17.
//  Copyright © 2017 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import CGtk
import Gtk
import RxSwift
import RxCocoa

public extension Reactive where Base: Entry {

    /// Reactive wrapper for the `text` property
    public var text: ControlProperty<String> { return value }

    /// Reactive value wrapper for the `text` property.
    public var value: ControlProperty<String> {
        return Object.rx.value(
            base, property: EntryPropertyName.text,
            setter: { textField, t in
                if textField.text != t { textField.set(text: t) }
            }
        )
    }
}

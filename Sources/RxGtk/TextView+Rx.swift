//
//  TextView+Rx.swift
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

public extension Reactive where Base: TextView {
//
//    /// Reactive wrapper for the `text` property
//    public var text: ControlProperty<String?> { return value }
//
//    /// Reactive value wrapper for the `text` property.
//    public var value: ControlProperty<String?> {
//        return Object.rx.value(
//            base, property: EntryPropertyName.text
//            getter: { textField in
//                textField.text
//        }, setter: { textField, value in
//            // This check is important because setting text value always clears control state
//            // including marked text selection which is imporant for proper input
//            // when IME input method is used.
//            if textField.text != value {
//                textField.text = value
//            }
//        }
//        )
//    }
}

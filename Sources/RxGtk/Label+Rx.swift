//
//  Label+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 22/4/17.
//  Copyright © 2017, 2018 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import CGtk
import Gtk
import RxSwift
import RxCocoa

public extension Reactive where Base: Label {

    /// Bindable sink for `text` property.
    public var text: Binder<String?> {
        return Binder(self.base) { label, text in
            label.set(text: text ?? "")
        }
    }

    /// Bindable sink for `label` (mnemonic text) property.
    public var label: Binder<String?> {
        return Binder(self.base) { label, text in
            label.set(label: text ?? "")
        }
    }
}

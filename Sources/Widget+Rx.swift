//
//  Widget+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 12/05/2017.
//  Copyright © 2017 Rene Hexel.  All rights reserved.
//
import CGLib
import GLib
import GLibObject
import CGtk
import Gtk
import RxSwift
import RxCocoa

public extension Reactive where Base: Widget {
    // MARK: - Boolean properties

    /// Bindable sink for `visible` property.
    public var isVisible: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(visible: value)
        }
    }

    /// Convenience bindable `isHidden` sink for `visible` property.
    public var isHidden: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(visible: !value)
        }
    }

    /// Bindable sink for `sensitive` property.
    public var isSensitive: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(sensitive: value)
        }
    }

    /// Convenience bindable `isEnabled` sink for `sensitive` property.
    public var isEnabled: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(sensitive: value)
        }
    }

    /// Bindable sink for `expand` property.
    public var expand: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setHexpand(expand: value)
            widget.setVexpand(expand: value)
        }
    }

    /// Bindable sink for `hexpand` property.
    public var hExpand: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setHexpand(expand: value)
        }
    }

    /// Bindable sink for `vexpand` property.
    public var vExpand: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setVexpand(expand: value)
        }
    }

    /// Bindable sink for `canFocus` property.
    public var canFocus: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(canFocus: value)
        }
    }

    /// Bindable sink for `canDefault` property.
    public var canDefault: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(canDefault: value)
        }
    }

    /// Bindable sink for `noShowAll` property.
    public var noShowAll: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(noShowAll: value)
        }
    }

    /// Bindable sink for `hasTooltip` property.
    public var hasTooltip: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(hasTooltip: value)
        }
    }

    // MARK: - String properties

    /// Bindable sink for `tooltip` property.
    public var toolTip: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: base) { widget, text in
            widget.setTooltip(text: text ?? "")
        }
    }

    /// Bindable sink for `tooltipMarkup` property.
    public var toolTipMarkup: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: base) { widget, text in
            widget.setTooltip(markup: text ?? "")
        }
    }

    /// Bindable sink for `name` property.
    public var name: UIBindingObserver<Base, String?> {
        return UIBindingObserver(UIElement: base) { widget, text in
            widget.set(name: text ?? "")
        }
    }

    // MARK: - Integer properties

    /// Bindable sink for `marginBottom` property.
    public var marginBottom: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setMarginBottom(margin: CInt(value))
        }
    }

    /// Bindable sink for `marginTop` property.
    public var marginTop: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setMarginTop(margin: CInt(value))
        }
    }

    /// Bindable sink for `marginStart` property.
    public var marginStart: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setMarginStart(margin: CInt(value))
        }
    }

    /// Bindable sink for `marginEnd` property.
    public var marginEnd: UIBindingObserver<Base, Int> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setMarginEnd(margin: CInt(value))
        }
    }

    /// Bindable sink for `sizeRequest` property.
    public var requestedSize: UIBindingObserver<Base, (width: Int, height: Int)> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setSizeRequest(width: CInt(value.width), height: CInt(value.height))
        }
    }

    // MARK: - Double properties

    /// Bindable sink for `opacity` property.
    public var opacity: UIBindingObserver<Base, Double> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.set(opacity: gdouble(value))
        }
    }

    // MARK: - Enum properties

    /// Bindable sink for `direction` property.
    public var textDirection: UIBindingObserver<Base, TextDirection> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setDirection(dir: value)
        }
    }

    /// Bindable sink for `halign` property.
    public var hAlign: UIBindingObserver<Base, Align> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setHalign(align: value)
        }
    }

    /// Bindable sink for `valign` property.
    public var vAlign: UIBindingObserver<Base, Align> {
        return UIBindingObserver(UIElement: self.base) { widget, value in
            widget.setValign(align: value)
        }
    }
}

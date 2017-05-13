//
//  ListBox+Rx.swift
//  RxGtk
//
//  Created by Rene Hexel on 12/05/2017.
//  Copyright © 2017 Rene Hexel.  All rights reserved.
//
import Foundation
import CGLib
import GLib
import GLibObject
import CGtk
import Gtk
import RxSwift
import RxCocoa

/// Marks data source as `ListBox` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxListBoxDataSourceType {

    /// Type of elements that can be bound to table view.
    associatedtype Element

    /// New observable sequence event observed.
    ///
    /// - parameter listBox: Bound list box.
    /// - parameter observedEvent: Event
    func listBox(_ listBox: ListBoxRef, observedEvent: Event<Element>) -> Void
}


extension Reactive where Base: ListBox {
    public func items<S: Swift.Sequence, O: ObservableType>(_ source: O) -> (_ cellFactory: @escaping (ListBoxRef, Int, S.Iterator.Element, ListBoxRow?) -> ListBoxRow) -> Disposable where O.E == S {
        return { cellFactory in
            let dataSource = RxListBoxReactiveArrayDataSourceSequenceWrapper<S>(cellFactory)
            return self.items(dataSource)(source)
        }
    }

    public func items<O: ObservableType, S: Swift.Sequence>(_ dataSource: RxListBoxReactiveArrayDataSourceSequenceWrapper<S>) -> (_ source: O) -> Disposable where O.E == S {
        return { source in
            // Strong reference is needed because data source is in use until result subscription is disposed
            return source.subscribeProxyDataSource(ofWidget: self.base, dataSource: dataSource, retainDataSource: true) { [weak listBox = self.base] (_: RxListBoxDataSource, event) -> Void in
                guard let listBox = listBox else { return }
                dataSource.listBox(ListBoxRef(cPointer: listBox.ptr), observedEvent: event)
            }
        }
    }
}


open class RxListBoxDataSource {}

public class RxListBoxReactiveArrayDataSource<Element>: RxListBoxDataSource, SectionedViewDataSourceType {
    typealias CellFactory = (ListBoxRef, Int, Element, ListBoxRow?) -> ListBoxRow

    var itemModels: [Element]? = nil

    func modelAtIndex(_ index: Int) -> Element? { return itemModels?[index] }

    public func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath[0] == 0) // section
        guard let item = itemModels?[indexPath[1]] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }

    let cellFactory: CellFactory

    init(_ factory: @escaping CellFactory) {
        self.cellFactory = factory
    }

    // reactive

    func listBox(_ listBox: ListBoxRef, observedElements: [Element]) {
        var cachedRows = Array<ListBoxRow>()
        cachedRows.reserveCapacity(itemModels?.count ?? 64)
        itemModels = observedElements
        var nextChild = listBox.children
        while let row = nextChild {
            nextChild = row.pointee.next
            guard let rowPtr = row.pointee.data else { continue }
            let listRow = ListBoxRow(rowPtr.assumingMemoryBound(to: GtkListBoxRow.self))
            cachedRows.append(listRow)
            listBox.remove(widget: WidgetRef(raw: rowPtr))
        }
        for (i, element) in observedElements.enumerated() {
            let cachedRow: ListBoxRow? = i < cachedRows.count ? cachedRows[i] : nil
            let row = cellFactory(listBox, i, element, cachedRow)
            listBox.insert(child: row, position: CInt(i))
        }
    }
}


public class RxListBoxReactiveArrayDataSourceSequenceWrapper<S: Swift.Sequence>: RxListBoxReactiveArrayDataSource<S.Iterator.Element>, RxListBoxDataSourceType {
    public typealias Element = S

    override init(_ cellFactory: @escaping CellFactory) {
        super.init(cellFactory)
    }

    public func listBox(_ listBox: ListBoxRef, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { listBoxDataSource, sectionModels in
            let sections = Array(sectionModels)
            listBoxDataSource.listBox(listBox, observedElements: sections)
            }.on(observedEvent)
    }
}

var proxies: [UnsafeMutableRawPointer : RxListBoxDataSource] = [:]

extension RxListBoxDataSource {
    /// Returns existing proxy for object or installs new instance of delegate proxy.
    ///
    /// - parameter object: Target GLib object on which to install delegate proxy.
    /// - returns: Installed instance of delegate proxy.
    ///
    public static func proxyForObject<O: ObjectProtocol>(_ object: O) -> RxListBoxDataSource {
        MainScheduler.ensureExecutingOnScheduler()

        let maybeProxy = RxListBoxDataSource.assignedProxyFor(object)

        let proxy: RxListBoxDataSource
        if let existingProxy = maybeProxy {
            proxy = existingProxy
        } else {
            proxy = RxListBoxDataSource.createProxyFor(object)!
            RxListBoxDataSource.assignProxy(proxy, toObject: object)
            assert(RxListBoxDataSource.assignedProxyFor(object)! === proxy)
        }

        return proxy
    }

    public static func assignedProxyFor<O: ObjectProtocol>(_ object: O) -> RxListBoxDataSource? {
        return proxies[object.ptr]
    }

    public static func createProxyFor<O: ObjectProtocol>(_ object: O) -> RxListBoxDataSource? {
        return RxListBoxDataSource()
    }

    public static func assignProxy<O: ObjectProtocol>(_ dataSource: RxListBoxDataSource, toObject object: O) {
        proxies[object.ptr] = dataSource
    }
}

extension ObservableType {
    func subscribeProxyDataSource(ofWidget object: Widget, dataSource: RxListBoxDataSource, retainDataSource: Bool = true, binding: @escaping (RxListBoxDataSource, Event<E>) -> Void) -> Disposable {
        let proxy = RxListBoxDataSource.proxyForObject(object)
        let subscription = self.asObservable()
            .observeOn(MainScheduler())
            .catchError { error in
                bindingErrorToInterface(error)
                return Observable.empty()
            }
            // source can never end, otherwise it would release the subscriber, and deallocate the data source
            .concat(Observable.never())
            .takeUntil(object.rx.deallocated)
            .subscribe { [weak object] (event: Event<E>) in
                if let object = object {
                    let assignedProxy = RxListBoxDataSource.assignedProxyFor(object)
                    assert(proxy === assignedProxy, "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: assignedProxy))")
                }

                binding(proxy, event)

                switch event {
                case .error(let error):
                    bindingErrorToInterface(error)
                case .completed: break
                default: break
            }
        }

        return Disposables.create { [weak object] in
            _ = object
            subscription.dispose()
        }
    }
}

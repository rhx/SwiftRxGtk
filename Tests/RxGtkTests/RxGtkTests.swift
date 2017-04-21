import XCTest
import CGtk
import Gtk
import RxSwift
@testable import RxGtk

fileprivate var initialised = false

class RxGtkTests: XCTestCase {

    override func setUp() {
        guard !initialised else { return }
        var argc = CInt(0)
        var end: UnsafeMutablePointer<CChar>? = nil
        withUnsafeMutablePointer(to: &end) {
            var ptr: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>? = $0
            gtk_init(&argc, &ptr)
        }
        initialised = true
    }

    func testLabel() {
        let s = "Hello"
        var label = Label(str: s)
	var expectedValue = s
        var expectNil = false
	XCTAssertNotNil(label.text)
	XCTAssertEqual(label.text, expectedValue)
        let t = "World"
        let o = Observable.just(t)
        expectedValue = t
        let subscription = o.subscribe(onNext: {
            XCTAssertEqual($0, expectedValue)
            label.text = $0
            expectNil = true
        }, onCompleted: {
            XCTAssertTrue(expectNil)
        })
        XCTAssertEqual(label.text, expectedValue)
        subscription.dispose()
        expectedValue = "Drive"
        let d = Observable.just(expectedValue).asDriver(onErrorJustReturn: "Error")
        let disposable = d.drive(label.rx.text)
        XCTAssertEqual(label.text, expectedValue)
        XCTAssertEqual(label.label, expectedValue)
        disposable.dispose()
        expectedValue = "Drive_Mnemonic"
        let l = Observable.just(expectedValue).asDriver(onErrorJustReturn: "Error")
        let disposable2 = l.drive(label.rx.label)
        XCTAssertEqual(label.text, expectedValue)
        XCTAssertEqual(label.label, expectedValue)
        disposable2.dispose()
    }


    static var allTests = [
        ("testLabel", testLabel),
    ]
}

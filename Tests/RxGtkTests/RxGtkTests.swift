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
        var label: Label! = Label(str: s)
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
        expectedValue = "Set"
        label.set(text: expectedValue)
        XCTAssertEqual(label.text, expectedValue)
        XCTAssertEqual(label.getText(), expectedValue)
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
        label = nil
        label = Label(str: s)
        expectedValue = s
        XCTAssertNotNil(label.text)
        XCTAssertEqual(label.text, expectedValue)
        label = nil
    }


    func testEntry() {
        let s = "Hello"
        var textField: Entry! = Entry()
        var expectedValue = ""
        var expectNil = false
        XCTAssertNotNil(textField.buffer)
        XCTAssertNotNil(textField.text)
        XCTAssertEqual(textField.text, expectedValue)
        expectedValue = s
        textField.set(text: expectedValue)
        XCTAssertNotNil(textField.text)
        XCTAssertEqual(textField.text, expectedValue)
        let t = "World"
        let o = Observable.just(t)
        expectedValue = t
        let subscription = o.subscribe(onNext: {
            XCTAssertEqual($0, expectedValue)
            textField.set(text: $0)
            XCTAssertEqual(textField.text, expectedValue)
            expectNil = true
        }, onCompleted: {
            XCTAssertTrue(expectNil)
        })
        XCTAssertEqual(textField.text, expectedValue)
        subscription.dispose()
        expectedValue = "Drive"
        let d = Observable.just(expectedValue).asDriver(onErrorJustReturn: "Error")
        let disposable = d.drive(textField.rx.text)
        XCTAssertEqual(textField.text, expectedValue)
        disposable.dispose()
        expectedValue = "Subscription"
        textField.set(text: expectedValue)
        var result = "Unexpected"
        var completed = false
        var disposed = false
        let controlSub = textField.rx.text.subscribe(onNext: {
            result = $0 + "Test"
            let s = strdup($0)
            result = s.map { String(cString: $0) } ?? ""
            XCTAssertEqual($0, expectedValue)
            free(s)
        }, onError: {
            _ in XCTFail()
        }, onCompleted: {
            completed = true
        }, onDisposed: {
            disposed = true
        })
        XCTAssertEqual(result, expectedValue)
        XCTAssertFalse(completed)
        XCTAssertFalse(disposed)
        textField.text = nil
        textField = nil
        XCTAssertFalse(completed)
        controlSub.dispose()
        XCTAssertTrue(disposed)
    }

    static var allTests = [
        ("testLabel", testLabel),
        ("testEntry", testEntry),
    ]
}

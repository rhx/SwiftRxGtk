import XCTest
@testable import RxGtk

class RxGtkTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(RxGtk().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}

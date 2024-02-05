import XCTest
@testable import SwiftErrorKit

final class AttributedErrorTests: XCTestCase {

    // Test that order of attributes is as expected - first in, last out.
    func testOrder() {

        func throwSomething() throws {
            do {
                throw Whoops()
                    .attribute(.tag(0), .tag("0"), .tag(1), .tag("1"), .tag(2), .tag("2"))
                    .attribute(.tag(3))
                    .attribute(.tag("3"))
            } catch {
                throw error
                    .attribute(.tag(4), .tag(5))
                    .attribute(.tag(6), .tag("4"), .tag("5"), .tag("6"))
            }
        }

        var result: (any Error)!
        do {
            try throwSomething()
        } catch {
             result = error
                .attribute(.tag(7), .tag(8), .tag("7"), .tag(9))
                .attribute(.tag("8"), .tag("9"), .tag("10"))
                .attribute(.tag(10))
        }
        XCTAssertEqual(result.tags(of: Int.self), [10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0])
        XCTAssertEqual(result.tags(of: String.self), ["10", "9", "8", "7", "6", "5", "4", "3", "2", "1", "0"])
    }

    func testIdentifiable_whenBaseIsIdentifiable_shouldIDBeOfBaseID() {
        let error = IdentifiedWhoops()
        XCTAssertEqual(ObjectIdentifier(type(of: error.identifiable.id)), ObjectIdentifier(IdentifiedWhoops.ID.self))
        let anyError = IdentifiedWhoops().attribute(.tag("test"))
        XCTAssertEqual(ObjectIdentifier(type(of: anyError.identifiable.id)), ObjectIdentifier(IdentifiedWhoops.ID.self))
    }

    func testIdentifiable_whenBaseIsntIdentifiable_shouldIDBeOfUUID() {
        let error = Whoops()
        XCTAssertEqual(ObjectIdentifier(type(of: error.identifiable.id)), ObjectIdentifier(UUID.self))
        let anyError = Whoops().attribute(.tag("test"))
        XCTAssertEqual(ObjectIdentifier(type(of: anyError.identifiable.id)), ObjectIdentifier(UUID.self))
    }

    func testIdentifiable_whenIdentified_shouldRemainIdentity() {
        let e1 = Whoops().attribute(.tag("test"))
        var ids = [Any]()
        ids.append(e1.identifiable.id)
        do {
            let e2 = e1.attribute(.tag("test"), .severity(.info))
            ids.append(e2.identifiable.id)
            let e3 = e2
            ids.append(e3.identifiable.id)
            throw e3.attribute(.rank(.low))
        } catch {
            ids.append(error.identifiable.id)
        }
        let set = Set(ids.map({ $0 as! UUID }))
        XCTAssertEqual(ids.count, 4)
        XCTAssertEqual(set.count, 1)
    }
}

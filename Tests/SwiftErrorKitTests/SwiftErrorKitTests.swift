import XCTest
@testable import SwiftErrorKit

struct Whoops: Error {}

struct IdentifiedWhoops: Error, Identifiable {
    let id = Int.random(in: Int.zero..<Int.max)
}

final class SwiftErrorKitTests: XCTestCase {

}

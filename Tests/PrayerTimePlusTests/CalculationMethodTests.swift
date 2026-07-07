@testable import PrayerTimePlus
import XCTest

/// Tests for the method preset table and Auto resolution.
final class CalculationMethodTests: XCTestCase {
    func testMuslimWorldLeagueAngles() {
        let params = CalculationMethod.muslimWorldLeague.parameters
        XCTAssertEqual(params.fajrAngle, 18.0)
        XCTAssertFalse(params.ishaIsInterval)
        XCTAssertEqual(params.ishaValue, 17.0)
        XCTAssertEqual(params.method, "mwl")
    }

    func testUmmAlQuraIsIntervalIsha() {
        let params = CalculationMethod.ummAlQura.parameters
        XCTAssertEqual(params.fajrAngle, 18.5)
        XCTAssertTrue(params.ishaIsInterval)
        XCTAssertEqual(params.ishaValue, 90.0)
    }

    func testOmanOffsetsDecodedFromTable() {
        // oman = [18, 1, 5, 0, 18, 0, 0, 5, 5, 0, 1]
        let params = CalculationMethod.oman.parameters
        XCTAssertEqual(params.fajrAngle, 18.0)
        XCTAssertTrue(params.maghribIsInterval)
        XCTAssertEqual(params.maghribValue, 5.0)
        XCTAssertEqual(params.ishaValue, 18.0)
        XCTAssertEqual(params.methodAdjustments.dhuhr, 5)
        XCTAssertEqual(params.methodAdjustments.asr, 5)
        XCTAssertEqual(params.methodAdjustments.isha, 1)
    }

    func testEmiratesNegativeOffsets() {
        // emirates = [18.5, 1, 2, 0, 18.5, 1, -4, 2, 0, 0, -3]
        let params = CalculationMethod.emirates.parameters
        XCTAssertEqual(params.methodAdjustments.fajr, 1)
        XCTAssertEqual(params.methodAdjustments.sunrise, -4)
        XCTAssertEqual(params.methodAdjustments.dhuhr, 2)
        XCTAssertEqual(params.methodAdjustments.isha, -3)
    }

    func testDubaiFallsBackToMuslimWorldLeagueAngles() {
        let dubai = CalculationMethod.dubai.parameters
        XCTAssertEqual(dubai.fajrAngle, 18.0)
        XCTAssertEqual(dubai.ishaValue, 17.0)
        XCTAssertEqual(dubai.method, "dubai")
    }

    func testOtherIsNeutral() {
        let params = CalculationMethod.other.parameters
        XCTAssertEqual(params.fajrAngle, 0)
        XCTAssertEqual(params.ishaValue, 0)
    }

    func testEveryMethodResolvesFromItsKey() {
        for method in CalculationMethod.allCases {
            XCTAssertEqual(CalculationMethod.from(key: method.key), method)
        }
    }

    func testUnknownKeyReturnsNil() {
        XCTAssertNil(CalculationMethod.from(key: "jafari"))
        XCTAssertNil(CalculationMethod.from(key: "tehran"))
        XCTAssertNil(CalculationMethod.from(key: "not-a-method"))
    }

    func testAutoResolutionMatchesAppendix() {
        let expected: [String: CalculationMethod] = [
            "OM": .oman,
            "SA": .ummAlQura,
            "AE": .emirates,
            "TR": .turkey,
            "FR": .uoif,
            "US": .northAmerica,
            "GB": .muslimWorldLeague,
            "PK": .karachi,
            "EG": .egyptian,
            "ID": .indonesia,
            "MY": .malaysia2,
        ]
        for (code, method) in expected {
            XCTAssertEqual(AutoMethod.forCountry(code), method, "for \(code)")
        }
    }

    func testAutoResolutionIsCaseInsensitiveWithFallback() {
        XCTAssertEqual(AutoMethod.forCountry("om"), .oman)
        XCTAssertEqual(AutoMethod.forCountry("ZZ"), .muslimWorldLeague)
    }
}

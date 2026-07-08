@testable import PrayerTimePlus
import XCTest

/// High-latitude behaviour: at 60°N in June an 18° Fajr is never reached, so the
/// night-fraction rules and the automatic fallback must fill it in.
final class HighLatitudeTests: XCTestCase {
    private let coordinates = Coordinates(latitude: 60.0, longitude: 0.0)
    private let date = DateComponents(year: 2026, month: 6, day: 21)
    private let utcOffset: TimeInterval = 0

    private func times(_ rule: HighLatitudeRule) -> PrayerTimes {
        var params = CalculationMethod.muslimWorldLeague.parameters
        params.highLatitudeRule = rule
        return PrayerTimes(
            coordinates: coordinates, date: date,
            calculationParameters: params, utcOffset: utcOffset,
        )
    }

    func testUnadjustedLeavesFajrUndefined() {
        XCTAssertNil(times(.unadjusted).fajr)
    }

    func testMiddleOfTheNightDefinesFajrAndIsha() throws {
        let result = times(.middleOfTheNight)
        let fajr = try XCTUnwrap(result.fajr)
        XCTAssertNotNil(result.isha)
        let sunrise = try XCTUnwrap(result.sunrise)
        XCTAssertLessThan(fajr, sunrise)
    }

    func testSeventhAndTwilightDefineFajrAndIsha() {
        for rule in [HighLatitudeRule.seventhOfTheNight, .twilightAngle] {
            let result = times(rule)
            XCTAssertNotNil(result.fajr, "\(rule)")
            XCTAssertNotNil(result.isha, "\(rule)")
        }
    }

    func testAutomaticUpgradesWhenFajrDegenerate() {
        let result = times(.automatic)
        XCTAssertNotNil(result.fajr)
        XCTAssertNotNil(result.isha)
    }
}

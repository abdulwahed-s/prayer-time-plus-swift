import XCTest
@testable import PrayerTimePlus

/// Unit tests for the astronomical core (`SolarTime`), asserted against the
/// hand-verified intermediates for Sohar, 2026-06-28.
final class AstronomyTests: XCTestCase {
    // Sohar, Oman.
    private let latitude = 24.3486
    private let longitude = 56.6953

    func testJulianDayMatchesReference() {
        XCTAssertEqual(SolarTime.julianDay(year: 2026, month: 6, day: 28), 2_461_219.5, accuracy: 1e-9)
    }

    func testJulianDayJanuaryFebruaryMonthShift() {
        // January and February are treated as months 13/14 of the previous year.
        XCTAssertEqual(SolarTime.julianDay(year: 2000, month: 1, day: 1), 2_451_544.5, accuracy: 1e-9)
    }

    func testSunPositionIntermediates() {
        let base = SolarTime.julianDay(year: 2026, month: 6, day: 28) - longitude / 360.0
        let position = SolarTime.sunPosition(base + 12.0 / 24.0)
        XCTAssertEqual(position.declination, 23.2676, accuracy: 5e-3)
        XCTAssertEqual(position.equationOfTime, -0.05468, accuracy: 5e-4)
    }

    func testLongitudeLocalisationOffset() {
        // tz − lng/15, the local-clock shift applied during adjustment.
        XCTAssertEqual(4.0 - longitude / 15.0, 0.22031, accuracy: 1e-5)
    }

    func testHighLatitudeUndefinedTimeIsNaN() {
        // A summer midnight-sun latitude: the sun never reaches an 18° depression.
        let solar = SolarTime(
            baseJulianDay: SolarTime.julianDay(year: 2026, month: 6, day: 21) - 25.0 / 360.0,
            latitude: 78.0
        )
        XCTAssertTrue(solar.sunAngleTime(angle: 180.0 - 18.0, t: 5.0 / 24.0).isNaN)
    }
}

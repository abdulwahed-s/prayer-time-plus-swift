@testable import PrayerTimePlus
import XCTest

/// Cross-package conformance tests shared visibly with the Dart and Kotlin suites.
final class CustomMaghribAngleTests: XCTestCase {
    private let sohar = Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5)
    private let date = DateComponents(year: 2026, month: 6, day: 28)
    private let utcOffset: TimeInterval = 4 * 3600

    private func custom(
        maghribValue: Double = 0,
        maghribIsInterval: Bool = false,
        ishaValue: Double = 17,
        ishaIsInterval: Bool = false,
        methodAdjustments: PrayerAdjustments = PrayerAdjustments(),
        adjustments: PrayerAdjustments = PrayerAdjustments(),
    ) -> CalculationParameters {
        CalculationParameters(
            method: "custom",
            fajrAngle: 18,
            maghribIsInterval: maghribIsInterval,
            maghribValue: maghribValue,
            ishaIsInterval: ishaIsInterval,
            ishaValue: ishaValue,
            methodAdjustments: methodAdjustments,
            adjustments: adjustments,
            highLatitudeRule: .unadjusted,
        )
    }

    private func times(_ parameters: CalculationParameters) -> PrayerTimes {
        PrayerTimes(
            coordinates: sohar,
            date: date,
            calculationParameters: parameters,
            utcOffset: utcOffset,
            countryCode: "OM",
            cityName: "sohar",
        )
    }

    func testPositiveMaghribAngleProducesAPostSunsetTime() throws {
        let result = times(custom(maghribValue: 4))

        XCTAssertGreaterThan(try XCTUnwrap(result.maghrib), try XCTUnwrap(result.sunset))
    }

    func testZeroAndNegativeMaghribAnglesRetainSunset() {
        for angle in [0.0, -4.0] {
            let result = times(custom(maghribValue: angle))
            XCTAssertEqual(result.maghrib, result.sunset, "\(angle) degrees")
        }
    }

    func testMaghribIntervalRemainsMinutesAfterSunset() throws {
        let result = times(custom(maghribValue: 5, maghribIsInterval: true))

        XCTAssertEqual(try minutesBetween(result.sunset, result.maghrib), 5)
    }

    func testIntervalIshaIsBasedOnFinalAngleBasedMaghrib() throws {
        let result = times(custom(maghribValue: 4, ishaValue: 90, ishaIsInterval: true))

        XCTAssertGreaterThan(try XCTUnwrap(result.maghrib), try XCTUnwrap(result.sunset))
        XCTAssertEqual(try minutesBetween(result.maghrib, result.isha), 90)
    }

    func testUnavailableMaghribAngleFallsBackToSunset() throws {
        let london = PrayerTimes(
            coordinates: Coordinates(latitude: 51.5080, longitude: -0.1281),
            date: DateComponents(year: 2026, month: 7, day: 9),
            calculationParameters: custom(maghribValue: 18, ishaValue: 90, ishaIsInterval: true),
            utcOffset: 3600,
            countryCode: "GB",
            cityName: "London",
        )

        XCTAssertEqual(london.maghrib, london.sunset)
        XCTAssertEqual(try minutesBetween(london.maghrib, london.isha), 90)
    }

    func testMaghribAngleAtOrAfterAngleBasedIshaFallsBackToSunset() throws {
        let result = times(custom(maghribValue: 20, ishaValue: 17))

        XCTAssertEqual(result.maghrib, result.sunset)
        XCTAssertLessThan(try XCTUnwrap(result.maghrib), try XCTUnwrap(result.isha))
    }

    func testCustomAnglePrayersRemainChronological() throws {
        let result = times(custom(maghribValue: 4, ishaValue: 17))
        let maghrib = try XCTUnwrap(result.maghrib)

        XCTAssertLessThan(try XCTUnwrap(result.fajr), maghrib)
        XCTAssertLessThan(try XCTUnwrap(result.sunset), maghrib)
        XCTAssertLessThan(maghrib, try XCTUnwrap(result.isha))
    }

    func testExistingPresetsWithoutAMaghribAngleRetainGoldenResults() {
        let mwl = times(CalculationMethod.muslimWorldLeague.parameters)
        let oman = times(CalculationMethod.oman.parameters)

        XCTAssertEqual(clock(mwl.sunset), "19:05")
        XCTAssertEqual(clock(mwl.maghrib), "19:05")
        XCTAssertEqual(clock(mwl.isha), "20:28")
        XCTAssertEqual(clock(oman.maghrib), "19:10")
        XCTAssertEqual(clock(oman.isha), "20:35")
    }

    func testCustomPresetHasSharedDefaultsAndStableKey() {
        let parameters = CalculationMethod.other.parameters
        let result = times(parameters)

        XCTAssertEqual(CalculationMethod.other.key, "custom")
        XCTAssertEqual(CalculationMethod.other.rawValue, "other")
        XCTAssertEqual(CalculationMethod(rawValue: "other"), .other)
        XCTAssertEqual(CalculationMethod.from(key: "custom"), .other)
        XCTAssertEqual(CalculationMethod.from(key: "other"), .other)
        XCTAssertEqual(parameters.method, "custom")
        XCTAssertEqual(parameters.fajrAngle, 18)
        XCTAssertTrue(parameters.maghribIsInterval)
        XCTAssertEqual(parameters.maghribValue, 0)
        XCTAssertFalse(parameters.ishaIsInterval)
        XCTAssertEqual(parameters.ishaValue, 17)
        XCTAssertEqual(result.maghrib, result.sunset)
    }

    func testMethodAndUserAdjustmentsAreAppliedExactlyOnce() throws {
        let base = times(custom(maghribValue: 4, ishaValue: 90, ishaIsInterval: true))
        let tuned = times(
            custom(
                maghribValue: 4,
                ishaValue: 90,
                ishaIsInterval: true,
                methodAdjustments: PrayerAdjustments(maghrib: 2, isha: 3),
                adjustments: PrayerAdjustments(maghrib: 3, isha: 4),
            ),
        )

        XCTAssertEqual(try minutesBetween(base.maghrib, tuned.maghrib), 5)
        XCTAssertEqual(try minutesBetween(base.isha, tuned.isha), 12)
    }

    private func minutesBetween(_ earlier: Date?, _ later: Date?) throws -> Int {
        Int(try XCTUnwrap(later).timeIntervalSince(try XCTUnwrap(earlier)) / 60)
    }

    private func clock(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: Int(utcOffset))
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

@testable import PrayerTimePlus
import XCTest

/// Tests for `time(for:)`, current/next prayer, and `SunnahTimes`.
final class PrayerTimesAPITests: XCTestCase {
    private let sohar = Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5)
    private let date = DateComponents(year: 2026, month: 6, day: 28)
    private let utcOffset: TimeInterval = 4 * 3600

    private func makeTimes() -> PrayerTimes {
        PrayerTimes(
            coordinates: sohar, date: date,
            calculationParameters: CalculationMethod.oman.parameters,
            utcOffset: utcOffset, countryCode: "OM",
        )
    }

    func testTimeForPrayerMatchesStoredValues() {
        let times = makeTimes()
        XCTAssertEqual(times.time(for: .fajr), times.fajr)
        XCTAssertEqual(times.time(for: .dhuhr), times.dhuhr)
        XCTAssertEqual(times.time(for: .isha), times.isha)
    }

    func testCurrentAndNextPrayer() throws {
        let times = makeTimes()
        let fajr = try XCTUnwrap(times.fajr)
        let dhuhr = try XCTUnwrap(times.dhuhr)
        let asr = try XCTUnwrap(times.asr)
        let isha = try XCTUnwrap(times.isha)

        let beforeFajr = fajr.addingTimeInterval(-60)
        XCTAssertNil(times.currentPrayer(at: beforeFajr))
        XCTAssertEqual(times.nextPrayer(at: beforeFajr), .fajr)

        let betweenDhuhrAndAsr = dhuhr.addingTimeInterval(asr.timeIntervalSince(dhuhr) / 2)
        XCTAssertEqual(times.currentPrayer(at: betweenDhuhrAndAsr), .dhuhr)
        XCTAssertEqual(times.nextPrayer(at: betweenDhuhrAndAsr), .asr)

        let afterIsha = isha.addingTimeInterval(60)
        XCTAssertEqual(times.currentPrayer(at: afterIsha), .isha)
        XCTAssertNil(times.nextPrayer(at: afterIsha))
    }

    func testSunnahTimesFallWithinTheNight() throws {
        let times = makeTimes()
        let sunnah = SunnahTimes(from: times)
        let maghrib = try XCTUnwrap(times.maghrib)
        let middle = try XCTUnwrap(sunnah.middleOfTheNight)
        let lastThird = try XCTUnwrap(sunnah.lastThirdOfTheNight)
        XCTAssertGreaterThan(middle, maghrib)
        XCTAssertGreaterThan(lastThird, middle)
    }

    func testTodayProducesDefinedTimesAtMidLatitude() {
        let today = PrayerTimes.today(
            coordinates: sohar,
            calculationParameters: CalculationMethod.oman.parameters,
            utcOffset: utcOffset, countryCode: "OM",
        )
        XCTAssertNotNil(today.dhuhr)
    }
}

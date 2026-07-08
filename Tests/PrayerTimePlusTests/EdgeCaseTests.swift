@testable import PrayerTimePlus
import XCTest

/// Rounding, the Umm al-Qura worked example, and the Ramadan bump.
final class EdgeCaseTests: XCTestCase {
    private let mecca = Coordinates(latitude: 21.42667, longitude: 39.82611, altitude: 0)
    private let date = DateComponents(year: 2026, month: 6, day: 28)
    private let utcOffset: TimeInterval = 3 * 3600

    private func clock(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 3 * 3600)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    func testMeccaUmmAlQuraWorkedExample() {
        // Dhuhr rounds up from 12:23:59 — a seconds >= 30 boundary.
        let times = PrayerTimes(
            coordinates: mecca, date: date,
            calculationParameters: CalculationMethod.ummAlQura.parameters,
            utcOffset: utcOffset, countryCode: "SA", cityName: "mecca",
        )
        XCTAssertEqual(clock(times.dhuhr), "12:24")
        XCTAssertEqual(clock(times.maghrib), "19:07")
        XCTAssertEqual(clock(times.isha), "20:37")
    }

    func testRamadanAddsThirtyMinutesToIshaInSaudiArabia() throws {
        let normal = CalculationMethod.ummAlQura.parameters
        var ramadan = CalculationMethod.ummAlQura.parameters
        ramadan.isRamadan = true

        let normalTimes = PrayerTimes(
            coordinates: mecca, date: date, calculationParameters: normal,
            utcOffset: utcOffset, countryCode: "SA",
        )
        let ramadanTimes = PrayerTimes(
            coordinates: mecca, date: date, calculationParameters: ramadan,
            utcOffset: utcOffset, countryCode: "SA",
        )
        let normalIsha = try XCTUnwrap(normalTimes.isha)
        let ramadanIsha = try XCTUnwrap(ramadanTimes.isha)
        XCTAssertEqual(ramadanIsha.timeIntervalSince(normalIsha), 30 * 60, accuracy: 1)
    }

    func testRamadanBumpRequiresSaudiArabia() {
        var ramadan = CalculationMethod.ummAlQura.parameters
        ramadan.isRamadan = true
        let saudi = PrayerTimes(
            coordinates: mecca, date: date, calculationParameters: ramadan,
            utcOffset: utcOffset, countryCode: "SA",
        )
        let elsewhere = PrayerTimes(
            coordinates: mecca, date: date, calculationParameters: ramadan,
            utcOffset: utcOffset, countryCode: "AE",
        )
        XCTAssertNotEqual(saudi.isha, elsewhere.isha)
    }
}

@testable import PrayerTimePlus
import XCTest

/// The verified Appendix-A golden vectors for Sohar, Oman on 2026-06-28 (+4).
///
/// These encode the astronomy, the parameter table, the adjust pipeline, rounding,
/// timezone and method offsets at once — when they pass, the port is faithful.
final class GoldenTests: XCTestCase {
    private let sohar = Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5)
    private let date = DateComponents(year: 2026, month: 6, day: 28)
    private let utcOffset: TimeInterval = 4 * 3600

    private func clock(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone(secondsFromGMT: 4 * 3600)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    func testMuslimWorldLeagueGolden() {
        let times = PrayerTimes(
            coordinates: sohar,
            date: date,
            calculationParameters: CalculationMethod.muslimWorldLeague.parameters,
            utcOffset: utcOffset,
            countryCode: "OM",
            cityName: "sohar",
        )
        XCTAssertEqual(clock(times.fajr), "03:59")
        XCTAssertEqual(clock(times.sunrise), "05:27")
        XCTAssertEqual(clock(times.dhuhr), "12:16")
        XCTAssertEqual(clock(times.asr), "15:37")
        XCTAssertEqual(clock(times.sunset), "19:05")
        XCTAssertEqual(clock(times.maghrib), "19:05")
        XCTAssertEqual(clock(times.isha), "20:28")
    }

    func testOmanGolden() {
        let times = PrayerTimes(
            coordinates: sohar,
            date: date,
            calculationParameters: CalculationMethod.oman.parameters,
            utcOffset: utcOffset,
            countryCode: "OM",
            cityName: "sohar",
        )
        XCTAssertEqual(clock(times.fajr), "03:59")
        XCTAssertEqual(clock(times.sunrise), "05:27")
        XCTAssertEqual(clock(times.dhuhr), "12:21")
        XCTAssertEqual(clock(times.asr), "15:42")
        XCTAssertEqual(clock(times.maghrib), "19:10")
        XCTAssertEqual(clock(times.isha), "20:35")
    }
}

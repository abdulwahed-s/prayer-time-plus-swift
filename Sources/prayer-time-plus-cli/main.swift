import Foundation
import PrayerTimePlus

// A small demo that prints prayer times for Sohar, Oman — a fixed reproducible
// day and the current day.

let coordinates = Coordinates(latitude: 24.3486, longitude: 56.6953, altitude: 5)
let utcOffset: TimeInterval = 4 * 3600
let method = CalculationMethod.oman

func formatted(_ date: Date?) -> String {
    guard let date else { return "--:--" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: Int(utcOffset))
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: date)
}

func printTimes(_ title: String, _ times: PrayerTimes) {
    print(title)
    print("  Fajr     \(formatted(times.fajr))")
    print("  Sunrise  \(formatted(times.sunrise))")
    print("  Dhuhr    \(formatted(times.dhuhr))")
    print("  Asr      \(formatted(times.asr))")
    print("  Maghrib  \(formatted(times.maghrib))")
    print("  Isha     \(formatted(times.isha))")
}

let example = PrayerTimes(
    coordinates: coordinates,
    date: DateComponents(year: 2026, month: 6, day: 28),
    calculationParameters: method.parameters,
    utcOffset: utcOffset,
    countryCode: "OM",
    cityName: "sohar",
)
printTimes("Sohar, Oman — 2026-06-28 (\(method.key)):", example)

let today = PrayerTimes.today(
    coordinates: coordinates,
    calculationParameters: method.parameters,
    utcOffset: utcOffset,
    countryCode: "OM",
    cityName: "sohar",
)
print("")
printTimes("Sohar, Oman — today (\(method.key)):", today)

if let next = today.nextPrayer() {
    print("\nNext prayer: \(next)")
}

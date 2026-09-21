import Foundation

// Regenerates the bundled Swift data from the committed JSON sources.
//
// Run from the repository root:
//     swift Tools/GenerateData/generate.swift
//
// Inputs  : Tools/GenerateData/data/{method_parameters,auto_method_resolution}.json
// Outputs : Sources/PrayerTimePlus/Data/{GeneratedMethodData,GeneratedAutoData}.swift
//
// The outputs carry a "GENERATED — do not edit by hand" header and are excluded
// from SwiftLint/SwiftFormat; edit the JSON and re-run instead.

let scriptDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let dataDirectory = scriptDirectory.appendingPathComponent("data")
let outputDirectory = scriptDirectory
    .deletingLastPathComponent() // Tools
    .deletingLastPathComponent() // repo root
    .appendingPathComponent("Sources/PrayerTimePlus/Data")

func die(_ message: String) -> Never {
    FileHandle.standardError.write(Data("generate: \(message)\n".utf8))
    exit(1)
}

func loadObject(_ name: String) -> [String: Any] {
    let url = dataDirectory.appendingPathComponent(name)
    guard let data = try? Data(contentsOf: url) else { die("cannot read \(name)") }
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let dictionary = object as? [String: Any]
    else { die("\(name) is not a JSON object") }
    return dictionary
}

/// Renders a `Double` as a Swift literal, using the shortest round-tripping form
/// and always keeping a decimal point (so `18` becomes `18.0`).
func literal(_ value: Double) -> String {
    if value == value.rounded(), abs(value) < 1e15 {
        return String(format: "%.1f", value)
    }
    return String(value)
}

func numbers(_ any: Any) -> [Double] {
    guard let array = any as? [Any] else { die("expected an array of numbers") }
    return array.map { element in
        guard let number = element as? NSNumber else { die("non-numeric array element") }
        return number.doubleValue
    }
}

func stringMap(_ any: Any?) -> [String: String] {
    guard let raw = any as? [String: Any] else { return [:] }
    var result: [String: String] = [:]
    for (key, value) in raw where value is String {
        // swiftlint:disable:next force_cast
        result[key] = (value as! String)
    }
    return result
}

func write(_ text: String, to name: String) {
    let url = outputDirectory.appendingPathComponent(name)
    do {
        try text.write(to: url, atomically: true, encoding: .utf8)
    } catch {
        die("cannot write \(name): \(error)")
    }
    print("wrote \(name)")
}

// MARK: - Method parameters

let methodJSON = loadObject("method_parameters.json")
guard let methods = methodJSON["methods"] as? [String: Any] else {
    die("method_parameters.json has no \"methods\" object")
}

var methodLines: [String] = [
    "// GENERATED — do not edit by hand.",
    "// Regenerate with: swift Tools/GenerateData/generate.swift",
    "",
    "/// Method key to its 11-column parameter array, copied verbatim from the",
    "/// reference method table. Columns: Fajr angle, Maghrib interval flag, Maghrib",
    "/// value (minutes in interval mode, otherwise an evening angle where non-positive",
    "/// means Sunset), Isha interval flag, Isha value, then Fajr/Sunrise/Dhuhr/Asr/",
    "/// Maghrib/Isha minute offsets.",
    "enum GeneratedMethodData {",
    "    static let parameters: [String: [Double]] = [",
]
for key in methods.keys.sorted() {
    let rendered = numbers(methods[key] ?? []).map(literal).joined(separator: ", ")
    methodLines.append("        \"\(key)\": [\(rendered)],")
}

methodLines.append("    ]")
methodLines.append("}")
methodLines.append("")
write(methodLines.joined(separator: "\n"), to: "GeneratedMethodData.swift")

// MARK: - Auto resolution

let autoJSON = loadObject("auto_method_resolution.json")
let mwlDefault = (autoJSON["mwl_default"] as? String) ?? "mwl"
let country = stringMap(autoJSON["country"])

func renderMap(_ name: String, _ map: [String: String]) -> [String] {
    var lines = ["    static let \(name): [String: String] = ["]
    for key in map.keys.sorted() {
        lines.append("        \"\(key)\": \"\(map[key] ?? "")\",")
    }
    lines.append("    ]")
    return lines
}

var autoLines: [String] = [
    "// GENERATED — do not edit by hand.",
    "// Regenerate with: swift Tools/GenerateData/generate.swift",
    "",
    "/// Country code to method key, for Auto resolution.",
    "enum GeneratedAutoData {",
    "    static let mwlDefault = \"\(mwlDefault)\"",
    "",
]
autoLines += renderMap("country", country)
autoLines.append("}")
autoLines.append("")
write(autoLines.joined(separator: "\n"), to: "GeneratedAutoData.swift")

print("done: \(methods.count) methods, \(country.count) countries")

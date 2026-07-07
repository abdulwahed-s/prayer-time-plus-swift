# Contributing to PrayerTimePlus

Thanks for your interest in improving **PrayerTimePlus** — the Swift port of an
offline Islamic prayer-times engine. This guide covers how to set the project up,
the standards a change is held to, and how to get it merged.

The same engine also ships for
[Dart / Flutter](https://github.com/abdulwahed-s/prayer_time_plus) and
[Kotlin / JVM](https://github.com/abdulwahed-s/prayer-time-plus-kotlin). A change
that affects computed times should ideally be raised for all three ports so they
stay in lock-step.

## Ways to contribute

- **Report a bug** or an incorrect prayer time.
- **Request a feature** or a new calculation method.
- **Improve the docs** — the README, DocC comments, or the example.
- **Send a pull request** — see the workflow below.

Open issues from the [templates](https://github.com/abdulwahed-s/prayer-time-plus-swift/issues/new/choose).
For anything security-related, **do not open a public issue** — follow
[SECURITY.md](SECURITY.md).

## Development setup

Requires a Swift 6.3+ toolchain.

```bash
swift build                # builds the library and CLI
swift test                 # full test suite — must be green
swiftformat .              # formatting — must leave no changes
swiftlint                  # lint — must be clean
swift run prayer-time-plus-cli   # CLI demo
```

The package treats **all warnings as errors**, so the build must be warning-free.

## Standards every change is held to

1. **Zero third-party dependencies.** The Swift standard library and Foundation
   only. Do not add an external package to the library target.
2. **Numeric parity is sacred.** Prayer times are validated to the minute against
   a fixed set of golden vectors. A refactor must not change any computed time.
   If a change *should* alter output (a genuine fix), update the affected golden
   tests in the same PR and explain why in the description.
3. **Everything stays green.** `swift build`, `swift test`, SwiftFormat and
   SwiftLint all pass; the build is warnings-clean. New behaviour comes with
   tests.
4. **Public API is documented.** Every `public` symbol carries a DocC `///`
   comment, and the main types carry a runnable example. Keep only the intended
   surface `public`.

## Commit & PR conventions

- **[Conventional Commits](https://www.conventionalcommits.org/):**
  `type(scope): subject` in the imperative mood — e.g.
  `feat: add Singapore calculation method`, `fix: correct Isha rounding near DST`,
  `docs: clarify utcOffset handling`. Types: `feat`, `fix`, `test`, `docs`,
  `refactor`, `perf`, `chore`, `build`, `ci`.
- **Small, atomic commits** — one logical change each; the message describes only
  that change.
- Releases are cut as **semantic-version git tags** (`0.1.0`); SwiftPM consumes
  the repository directly at a tag.
- Keep pull requests focused, fill in the template, and link the issue they
  close.

## Code of conduct

Be respectful and constructive. Harassment or abuse of any kind is not welcome in
issues, pull requests, or discussions.

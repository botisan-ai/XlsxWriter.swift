# XlsxWriter for iOS/macOS

A Swift wrapper for [rust_xlsxwriter](https://github.com/jmcnamara/rust_xlsxwriter), a high-performance Excel XLSX file writer written in Rust. Uses [UniFFI](https://github.com/mozilla/uniffi-rs) to generate Swift bindings.

## Features

- Create Excel 2007+ (.xlsx) files from iOS/macOS apps
- Write strings, numbers, booleans, dates, and datetimes to cells
- Multiple worksheet support with custom naming
- Column width and row height control
- Save to file or in-memory buffer
- Thread-safe with Swift `actor` isolation
- Native Foundation `Date` support

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/example/XlsxWriter.swift.git", from: "0.1.0")
]
```

Or add it via Xcode: File → Add Package Dependencies → Enter the repository URL.

## Usage

### Basic Example

```swift
import XlsxWriterSwift

// Create a new workbook
let workbook = XlsxWorkbook()

// Add a worksheet
let sheet = try await workbook.addWorksheet(name: "Data")

// Write different data types
try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "Hello, Excel!")
try await workbook.writeNumber(sheet: sheet, row: 1, col: 0, value: 3.14159)
try await workbook.writeInteger(sheet: sheet, row: 2, col: 0, value: 42)
try await workbook.writeBoolean(sheet: sheet, row: 3, col: 0, value: true)

// Save to file
try await workbook.save(to: "/path/to/output.xlsx")
```

### Working with Dates

```swift
import XlsxWriterSwift

let workbook = XlsxWorkbook()
let sheet = try await workbook.addWorksheet()

// Using Foundation Date
try await workbook.writeDate(sheet: sheet, row: 0, col: 0, date: Date())
try await workbook.writeDateTime(sheet: sheet, row: 1, col: 0, datetime: Date())

// Using explicit date values
let christmas = ExcelDateValue(year: 2024, month: 12, day: 25)
try await workbook.writeDate(sheet: sheet, row: 2, col: 0, date: christmas)

// With custom format
try await workbook.writeDateWithFormat(
    sheet: sheet,
    row: 3,
    col: 0,
    date: christmas,
    format: "dd/mm/yyyy"
)

try await workbook.save(to: "dates.xlsx")
```

### Multiple Worksheets

```swift
import XlsxWriterSwift

let workbook = XlsxWorkbook()

// Add multiple worksheets
let dataSheet = try await workbook.addWorksheet(name: "Data")
let summarySheet = try await workbook.addWorksheet(name: "Summary")

// Write to different sheets
try await workbook.writeString(sheet: dataSheet, row: 0, col: 0, value: "Raw Data")
try await workbook.writeNumber(sheet: dataSheet, row: 1, col: 0, value: 100)
try await workbook.writeNumber(sheet: dataSheet, row: 2, col: 0, value: 200)

try await workbook.writeString(sheet: summarySheet, row: 0, col: 0, value: "Total")
try await workbook.writeNumber(sheet: summarySheet, row: 0, col: 1, value: 300)

// Check worksheet count
let count = await workbook.worksheetCount()
print("Workbook has \(count) worksheets")

try await workbook.save(to: "multi-sheet.xlsx")
```

### Column and Row Sizing

```swift
import XlsxWriterSwift

let workbook = XlsxWorkbook()
let sheet = try await workbook.addWorksheet()

// Set column width (in Excel character units)
try await workbook.setColumnWidth(sheet: sheet, col: 0, width: 20.0)
try await workbook.setColumnWidth(sheet: sheet, col: 1, width: 15.0)

// Set row height (in points)
try await workbook.setRowHeight(sheet: sheet, row: 0, height: 30.0)

try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "Wide column, tall row")

try await workbook.save(to: "sized.xlsx")
```

### Save to Buffer

```swift
import XlsxWriterSwift

let workbook = XlsxWorkbook()
let sheet = try await workbook.addWorksheet()
try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "In-memory")

// Get the workbook as Data (useful for network upload, etc.)
let data: Data = try await workbook.saveToBuffer()

// The data is a valid XLSX file (ZIP format)
print("Generated \(data.count) bytes")
```

## API Reference

### XlsxWorkbook

| Method | Description |
|--------|-------------|
| `init()` | Create a new empty workbook |
| `addWorksheet() -> UInt32` | Add a worksheet, returns sheet index |
| `addWorksheet(name:) -> UInt32` | Add a named worksheet |
| `writeString(sheet:row:col:value:)` | Write a string to a cell |
| `writeNumber(sheet:row:col:value:)` | Write a Double to a cell |
| `writeInteger(sheet:row:col:value:)` | Write an Int64 to a cell |
| `writeBoolean(sheet:row:col:value:)` | Write a Bool to a cell |
| `writeDate(sheet:row:col:date:)` | Write a date (ExcelDateValue or Date) |
| `writeDateTime(sheet:row:col:datetime:)` | Write a datetime |
| `writeDateWithFormat(sheet:row:col:date:format:)` | Write a date with custom format |
| `setColumnWidth(sheet:col:width:)` | Set column width |
| `setRowHeight(sheet:row:height:)` | Set row height |
| `worksheetCount() -> UInt32` | Get number of worksheets |
| `save(to:)` | Save to file path or URL |
| `saveToBuffer() -> Data` | Save to in-memory buffer |

### Cell Addressing

- Rows and columns are **zero-indexed**
- Row 0, Col 0 = Cell A1
- Row 0, Col 1 = Cell B1
- Row 1, Col 0 = Cell A2

## Development

### Prerequisites

- Rust toolchain with iOS targets
- Xcode with Swift 6.0+

### Building

```bash
# Install Rust targets (if not already done via rust-toolchain.toml)
rustup target add aarch64-apple-ios aarch64-apple-ios-sim aarch64-apple-darwin

# Build everything (Rust lib + Swift bindings + XCFramework)
./build-ios.sh

# Run tests
swift test
```

### Project Structure

```
XlsxWriter.swift/
├── src/
│   ├── lib.rs              # Rust FFI implementation
│   └── uniffi-bindgen.rs   # UniFFI code generator
├── Sources/
│   ├── XlsxWriterFFI/      # Auto-generated Swift bindings
│   └── XlsxWriterSwift/    # Hand-written Swift wrapper
├── Tests/
│   └── XlsxWriterSwiftTests/
├── build-ios.sh            # Build script
├── Cargo.toml              # Rust dependencies
└── Package.swift           # Swift package manifest
```

## Limitations (v0.1.0)

This initial version focuses on basic functionality. Not yet supported:

- Cell formatting (bold, colors, borders)
- Formulas
- Charts
- Images
- Merged cells
- Hyperlinks

These features are available in the underlying [rust_xlsxwriter](https://docs.rs/rust_xlsxwriter) crate and may be exposed in future versions.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

- [rust_xlsxwriter](https://github.com/jmcnamara/rust_xlsxwriter) - The underlying Rust implementation
- [XlsxWriter](https://xlsxwriter.readthedocs.io/) - Original Python implementation by the same author
- [UniFFI](https://github.com/mozilla/uniffi-rs) - Mozilla's FFI bindings generator

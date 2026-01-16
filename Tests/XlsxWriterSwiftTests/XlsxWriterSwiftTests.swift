import Foundation
import Testing
@testable import XlsxWriterSwift

@Test func testCreateWorkbookAndAddWorksheet() async throws {
    let workbook = XlsxWorkbook()

    let sheetIndex = try await workbook.addWorksheet()
    #expect(sheetIndex == 0)

    let sheetCount = await workbook.worksheetCount()
    #expect(sheetCount == 1)
}

@Test func testAddNamedWorksheet() async throws {
    let workbook = XlsxWorkbook()

    let sheetIndex = try await workbook.addWorksheet(name: "MySheet")
    #expect(sheetIndex == 0)

    let secondSheet = try await workbook.addWorksheet(name: "SecondSheet")
    #expect(secondSheet == 1)

    let sheetCount = await workbook.worksheetCount()
    #expect(sheetCount == 2)
}

@Test func testWriteStringAndNumber() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("test_string_number_\(UUID().uuidString).xlsx").path

    let workbook = XlsxWorkbook()
    let sheet = try await workbook.addWorksheet()

    try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "Hello")
    try await workbook.writeString(sheet: sheet, row: 0, col: 1, value: "World")
    try await workbook.writeNumber(sheet: sheet, row: 1, col: 0, value: 3.14159)
    try await workbook.writeInteger(sheet: sheet, row: 1, col: 1, value: 42)
    try await workbook.writeBoolean(sheet: sheet, row: 2, col: 0, value: true)

    try await workbook.save(to: filePath)

    #expect(FileManager.default.fileExists(atPath: filePath))

    let fileSize = try FileManager.default.attributesOfItem(atPath: filePath)[.size] as? Int ?? 0
    #expect(fileSize > 0)

    try FileManager.default.removeItem(atPath: filePath)
}

@Test func testWriteDate() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("test_date_\(UUID().uuidString).xlsx").path

    let workbook = XlsxWorkbook()
    let sheet = try await workbook.addWorksheet()

    let date = ExcelDateValue(year: 2024, month: 12, day: 25)
    try await workbook.writeDate(sheet: sheet, row: 0, col: 0, date: date)

    let now = Date()
    try await workbook.writeDate(sheet: sheet, row: 1, col: 0, date: now)

    try await workbook.save(to: filePath)

    #expect(FileManager.default.fileExists(atPath: filePath))

    try FileManager.default.removeItem(atPath: filePath)
}

@Test func testWriteDateTime() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("test_datetime_\(UUID().uuidString).xlsx").path

    let workbook = XlsxWorkbook()
    let sheet = try await workbook.addWorksheet()

    let datetime = ExcelDateTimeValue(year: 2024, month: 12, day: 25, hour: 14, minute: 30, second: 0)
    try await workbook.writeDateTime(sheet: sheet, row: 0, col: 0, datetime: datetime)

    let now = Date()
    try await workbook.writeDateTime(sheet: sheet, row: 1, col: 0, datetime: now)

    try await workbook.save(to: filePath)

    #expect(FileManager.default.fileExists(atPath: filePath))

    try FileManager.default.removeItem(atPath: filePath)
}

@Test func testSaveToBuffer() async throws {
    let workbook = XlsxWorkbook()
    let sheet = try await workbook.addWorksheet()

    try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "Test")
    try await workbook.writeNumber(sheet: sheet, row: 1, col: 0, value: 123.456)

    let buffer = try await workbook.saveToBuffer()

    #expect(buffer.count > 0)
    #expect(buffer.prefix(2) == Data([0x50, 0x4B]))
}

@Test func testColumnAndRowSizing() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("test_sizing_\(UUID().uuidString).xlsx").path

    let workbook = XlsxWorkbook()
    let sheet = try await workbook.addWorksheet()

    try await workbook.setColumnWidth(sheet: sheet, col: 0, width: 20.0)
    try await workbook.setRowHeight(sheet: sheet, row: 0, height: 30.0)

    try await workbook.writeString(sheet: sheet, row: 0, col: 0, value: "Wide column, tall row")

    try await workbook.save(to: filePath)

    #expect(FileManager.default.fileExists(atPath: filePath))

    try FileManager.default.removeItem(atPath: filePath)
}

@Test func testMultipleWorksheets() async throws {
    let tempDir = FileManager.default.temporaryDirectory
    let filePath = tempDir.appendingPathComponent("test_multi_sheet_\(UUID().uuidString).xlsx").path

    let workbook = XlsxWorkbook()

    let sheet1 = try await workbook.addWorksheet(name: "Data")
    let sheet2 = try await workbook.addWorksheet(name: "Summary")

    try await workbook.writeString(sheet: sheet1, row: 0, col: 0, value: "Data Sheet")
    try await workbook.writeNumber(sheet: sheet1, row: 1, col: 0, value: 100)
    try await workbook.writeNumber(sheet: sheet1, row: 2, col: 0, value: 200)

    try await workbook.writeString(sheet: sheet2, row: 0, col: 0, value: "Summary Sheet")
    try await workbook.writeNumber(sheet: sheet2, row: 1, col: 0, value: 300)

    let count = await workbook.worksheetCount()
    #expect(count == 2)

    try await workbook.save(to: filePath)

    #expect(FileManager.default.fileExists(atPath: filePath))

    try FileManager.default.removeItem(atPath: filePath)
}

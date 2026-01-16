import Foundation
import XlsxWriterFFI

public struct ExcelDateValue: Sendable {
    public let year: UInt16
    public let month: UInt8
    public let day: UInt8

    public init(year: UInt16, month: UInt8, day: UInt8) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = UInt16(components.year ?? 2000)
        self.month = UInt8(components.month ?? 1)
        self.day = UInt8(components.day ?? 1)
    }

    func toFFI() -> ExcelDate {
        ExcelDate(year: year, month: month, day: day)
    }
}

public struct ExcelDateTimeValue: Sendable {
    public let year: UInt16
    public let month: UInt8
    public let day: UInt8
    public let hour: UInt8
    public let minute: UInt8
    public let second: UInt8

    public init(year: UInt16, month: UInt8, day: UInt8, hour: UInt8, minute: UInt8, second: UInt8) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    public init(from date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        self.year = UInt16(components.year ?? 2000)
        self.month = UInt8(components.month ?? 1)
        self.day = UInt8(components.day ?? 1)
        self.hour = UInt8(components.hour ?? 0)
        self.minute = UInt8(components.minute ?? 0)
        self.second = UInt8(components.second ?? 0)
    }

    func toFFI() -> ExcelDateTime {
        ExcelDateTime(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        )
    }
}

public actor XlsxWorkbook {
    private let workbook: Workbook

    public init() {
        self.workbook = Workbook()
    }

    public func addWorksheet() throws -> UInt32 {
        try workbook.addWorksheet()
    }

    public func addWorksheet(name: String) throws -> UInt32 {
        try workbook.addWorksheetWithName(name: name)
    }

    public func writeString(sheet: UInt32, row: UInt32, col: UInt16, value: String) throws {
        try workbook.writeString(sheetIndex: sheet, row: row, col: col, value: value)
    }

    public func writeNumber(sheet: UInt32, row: UInt32, col: UInt16, value: Double) throws {
        try workbook.writeNumber(sheetIndex: sheet, row: row, col: col, value: value)
    }

    public func writeInteger(sheet: UInt32, row: UInt32, col: UInt16, value: Int64) throws {
        try workbook.writeInteger(sheetIndex: sheet, row: row, col: col, value: value)
    }

    public func writeBoolean(sheet: UInt32, row: UInt32, col: UInt16, value: Bool) throws {
        try workbook.writeBoolean(sheetIndex: sheet, row: row, col: col, value: value)
    }

    public func writeDate(sheet: UInt32, row: UInt32, col: UInt16, date: ExcelDateValue) throws {
        try workbook.writeDate(sheetIndex: sheet, row: row, col: col, date: date.toFFI())
    }

    public func writeDate(sheet: UInt32, row: UInt32, col: UInt16, date: Date) throws {
        let excelDate = ExcelDateValue(from: date)
        try workbook.writeDate(sheetIndex: sheet, row: row, col: col, date: excelDate.toFFI())
    }

    public func writeDateTime(sheet: UInt32, row: UInt32, col: UInt16, datetime: ExcelDateTimeValue) throws {
        try workbook.writeDatetime(sheetIndex: sheet, row: row, col: col, datetime: datetime.toFFI())
    }

    public func writeDateTime(sheet: UInt32, row: UInt32, col: UInt16, datetime: Date) throws {
        let excelDateTime = ExcelDateTimeValue(from: datetime)
        try workbook.writeDatetime(sheetIndex: sheet, row: row, col: col, datetime: excelDateTime.toFFI())
    }

    public func writeDateWithFormat(
        sheet: UInt32,
        row: UInt32,
        col: UInt16,
        date: ExcelDateValue,
        format: String
    ) throws {
        try workbook.writeDateWithFormat(
            sheetIndex: sheet,
            row: row,
            col: col,
            date: date.toFFI(),
            format: format
        )
    }

    public func setColumnWidth(sheet: UInt32, col: UInt16, width: Double) throws {
        try workbook.setColumnWidth(sheetIndex: sheet, col: col, width: width)
    }

    public func setRowHeight(sheet: UInt32, row: UInt32, height: Double) throws {
        try workbook.setRowHeight(sheetIndex: sheet, row: row, height: height)
    }

    public func worksheetCount() -> UInt32 {
        workbook.worksheetCount()
    }

    public func save(to path: String) throws {
        try workbook.save(path: path)
    }

    public func save(to url: URL) throws {
        try workbook.save(path: url.path)
    }

    public func saveToBuffer() throws -> Data {
        let bytes = try workbook.saveToBuffer()
        return Data(bytes)
    }
}

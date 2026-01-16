use std::sync::Mutex;

use rust_xlsxwriter::{
    ExcelDateTime as RustExcelDateTime, Format as RustFormat, Workbook as RustWorkbook,
    XlsxError,
};

#[derive(Debug, thiserror::Error, uniffi::Error)]
#[uniffi(flat_error)]
pub enum XlsxWriterError {
    #[error("IO error: {0}")]
    IoError(String),
    #[error("Row/column limit exceeded: {0}")]
    RowColumnLimitError(String),
    #[error("String length exceeded maximum: {0}")]
    MaxStringLengthExceeded(String),
    #[error("Worksheet name already exists: {0}")]
    SheetnameReused(String),
    #[error("Invalid parameter: {0}")]
    ParameterError(String),
    #[error("Worksheet not found at index: {0}")]
    WorksheetNotFound(u32),
    #[error("Date error: {0}")]
    DateError(String),
    #[error("Unknown error: {0}")]
    Unknown(String),
}

impl From<XlsxError> for XlsxWriterError {
    fn from(e: XlsxError) -> Self {
        match e {
            XlsxError::IoError(msg) => XlsxWriterError::IoError(msg.to_string()),
            XlsxError::RowColumnLimitError => {
                XlsxWriterError::RowColumnLimitError("Row or column index out of bounds".into())
            }
            XlsxError::MaxStringLengthExceeded => {
                XlsxWriterError::MaxStringLengthExceeded("String exceeds 32,767 characters".into())
            }
            XlsxError::SheetnameReused(name) => XlsxWriterError::SheetnameReused(name),
            XlsxError::ParameterError(msg) => XlsxWriterError::ParameterError(msg),
            _ => XlsxWriterError::Unknown(e.to_string()),
        }
    }
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct ExcelDate {
    pub year: u16,
    pub month: u8,
    pub day: u8,
}

#[derive(Debug, Clone, uniffi::Record)]
pub struct ExcelDateTime {
    pub year: u16,
    pub month: u8,
    pub day: u8,
    pub hour: u8,
    pub minute: u8,
    pub second: u8,
}

#[derive(uniffi::Object)]
pub struct Workbook {
    inner: Mutex<RustWorkbook>,
}

#[uniffi::export]
impl Workbook {
    #[uniffi::constructor]
    pub fn new() -> Self {
        Self {
            inner: Mutex::new(RustWorkbook::new()),
        }
    }

    #[uniffi::method]
    pub fn add_worksheet(&self) -> Result<u32, XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let count = workbook.worksheets().len();
        workbook.add_worksheet();
        Ok(count as u32)
    }

    #[uniffi::method]
    pub fn add_worksheet_with_name(&self, name: String) -> Result<u32, XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let count = workbook.worksheets().len();
        let worksheet = workbook.add_worksheet();
        worksheet.set_name(&name)?;
        Ok(count as u32)
    }

    #[uniffi::method]
    pub fn write_string(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        value: String,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.write_string(row, col, &value)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_number(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        value: f64,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.write_number(row, col, value)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_integer(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        value: i64,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.write_number(row, col, value as f64)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_boolean(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        value: bool,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.write_boolean(row, col, value)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_date(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        date: ExcelDate,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;

        let excel_date = RustExcelDateTime::from_ymd(date.year.into(), date.month, date.day)
            .map_err(|e| XlsxWriterError::DateError(e.to_string()))?;

        let date_format = RustFormat::new().set_num_format("yyyy-mm-dd");
        worksheet.write_datetime_with_format(row, col, &excel_date, &date_format)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_datetime(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        datetime: ExcelDateTime,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;

        let excel_datetime = RustExcelDateTime::from_ymd(
            datetime.year.into(),
            datetime.month,
            datetime.day,
        )
        .map_err(|e| XlsxWriterError::DateError(e.to_string()))?
        .and_hms(datetime.hour as u16, datetime.minute, datetime.second as f64)
        .map_err(|e| XlsxWriterError::DateError(e.to_string()))?;

        let datetime_format = RustFormat::new().set_num_format("yyyy-mm-dd hh:mm:ss");
        worksheet.write_datetime_with_format(row, col, &excel_datetime, &datetime_format)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn write_date_with_format(
        &self,
        sheet_index: u32,
        row: u32,
        col: u16,
        date: ExcelDate,
        format: String,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;

        let excel_date = RustExcelDateTime::from_ymd(date.year.into(), date.month, date.day)
            .map_err(|e| XlsxWriterError::DateError(e.to_string()))?;

        let date_format = RustFormat::new().set_num_format(&format);
        worksheet.write_datetime_with_format(row, col, &excel_date, &date_format)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn set_column_width(
        &self,
        sheet_index: u32,
        col: u16,
        width: f64,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.set_column_width(col, width)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn set_row_height(
        &self,
        sheet_index: u32,
        row: u32,
        height: f64,
    ) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let worksheet = workbook
            .worksheet_from_index(sheet_index as usize)
            .map_err(|_| XlsxWriterError::WorksheetNotFound(sheet_index))?;
        worksheet.set_row_height(row, height)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn worksheet_count(&self) -> u32 {
        let mut workbook = self.inner.lock().unwrap();
        workbook.worksheets().len() as u32
    }

    #[uniffi::method]
    pub fn save(&self, path: String) -> Result<(), XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        workbook.save(&path)?;
        Ok(())
    }

    #[uniffi::method]
    pub fn save_to_buffer(&self) -> Result<Vec<u8>, XlsxWriterError> {
        let mut workbook = self.inner.lock().unwrap();
        let buffer = workbook.save_to_buffer()?;
        Ok(buffer)
    }
}

uniffi::setup_scaffolding!();

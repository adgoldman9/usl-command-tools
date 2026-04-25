const MOBILE_CAPTURE_SHEET = 'Mobile_Capture';

// Leave blank when this script is bound from the Sheet with Extensions -> Apps Script.
// For a standalone script.google.com project, set this with configureUSLSyncSpreadsheet()
// or paste the spreadsheet ID here before deploying.
const USL_SYNC_SPREADSHEET_ID = '';

const MOBILE_CAPTURE_HEADERS = [
  'id',
  'captureType',
  'title',
  'description',
  'source',
  'dateCaptured',
  'priority',
  'targetLane',
  'nextAction',
  'status',
  'notes',
  'updatedAt'
];

function doGet(e) {
  const params = e && e.parameter ? e.parameter : {};
  const action = params.action || 'list';
  const callback = sanitizeCallback(params.callback || '');

  if (action === 'setup') {
    ensureSheet_(MOBILE_CAPTURE_SHEET, MOBILE_CAPTURE_HEADERS);
    return jsonResponse_({ ok: true, message: 'Mobile capture sheet is ready.' }, callback);
  }

  if (action === 'list') {
    const records = readRecords_(MOBILE_CAPTURE_SHEET, MOBILE_CAPTURE_HEADERS);
    return jsonResponse_({ ok: true, records: records }, callback);
  }

  return jsonResponse_({ ok: false, error: 'Unsupported action.' }, callback);
}

function doPost(e) {
  const params = e && e.parameter ? e.parameter : {};
  const action = params.action || 'upsertMany';

  if (action !== 'upsertMany') {
    return textResponse_('Unsupported action.');
  }

  const payload = params.payload || '[]';
  const parsed = JSON.parse(payload);
  const records = Array.isArray(parsed) ? parsed : [];
  const count = upsertRecords_(MOBILE_CAPTURE_SHEET, MOBILE_CAPTURE_HEADERS, records);

  return textResponse_('OK: upserted ' + count + ' record(s).');
}

function setupUSLSyncSheet() {
  ensureSheet_(MOBILE_CAPTURE_SHEET, MOBILE_CAPTURE_HEADERS);
}

function configureUSLSyncSpreadsheet() {
  const spreadsheetId = 'PASTE_SPREADSHEET_ID_HERE';
  if (spreadsheetId === 'PASTE_SPREADSHEET_ID_HERE') {
    throw new Error('Paste your Google Sheet ID into configureUSLSyncSpreadsheet before running it.');
  }

  PropertiesService.getScriptProperties().setProperty('USL_SYNC_SPREADSHEET_ID', spreadsheetId);
}

function ensureSheet_(sheetName, headers) {
  const spreadsheet = getSyncSpreadsheet_();
  let sheet = spreadsheet.getSheetByName(sheetName);
  if (!sheet) {
    sheet = spreadsheet.insertSheet(sheetName);
  }

  const existing = sheet.getRange(1, 1, 1, headers.length).getValues()[0];
  const needsHeaders = headers.some((header, index) => existing[index] !== header);
  if (needsHeaders) {
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    sheet.setFrozenRows(1);
  }

  return sheet;
}

function getSyncSpreadsheet_() {
  const propertyId = PropertiesService.getScriptProperties().getProperty('USL_SYNC_SPREADSHEET_ID') || '';
  const configuredId = String(USL_SYNC_SPREADSHEET_ID || propertyId).trim();
  if (configuredId) {
    return SpreadsheetApp.openById(configuredId);
  }

  const activeSpreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  if (activeSpreadsheet) {
    return activeSpreadsheet;
  }

  throw new Error('No Google Sheet is connected. Bind this script from the Sheet, or configure USL_SYNC_SPREADSHEET_ID.');
}

function readRecords_(sheetName, headers) {
  const sheet = ensureSheet_(sheetName, headers);
  const lastRow = sheet.getLastRow();
  if (lastRow < 2) {
    return [];
  }

  const values = sheet.getRange(2, 1, lastRow - 1, headers.length).getValues();
  return values
    .filter(function(row) {
      return row.some(function(cell) {
        return String(cell || '').trim();
      });
    })
    .map(function(row) {
      const record = {};
      headers.forEach(function(header, index) {
        record[header] = row[index] instanceof Date
          ? Utilities.formatDate(row[index], Session.getScriptTimeZone(), 'yyyy-MM-dd')
          : String(row[index] || '');
      });
      return record;
    });
}

function upsertRecords_(sheetName, headers, records) {
  const sheet = ensureSheet_(sheetName, headers);
  const existing = readRecords_(sheetName, headers);
  const rowById = {};
  existing.forEach(function(record, index) {
    if (record.id) {
      rowById[record.id] = index + 2;
    }
  });

  let count = 0;
  records.forEach(function(record) {
    if (!record || !record.id) {
      return;
    }

    const cleanRecord = {};
    headers.forEach(function(header) {
      cleanRecord[header] = header === 'updatedAt'
        ? new Date().toISOString()
        : String(record[header] || '');
    });

    const row = headers.map(function(header) {
      return cleanRecord[header];
    });

    if (rowById[record.id]) {
      sheet.getRange(rowById[record.id], 1, 1, headers.length).setValues([row]);
    } else {
      sheet.appendRow(row);
    }

    count += 1;
  });

  return count;
}

function jsonResponse_(data, callback) {
  const body = callback
    ? callback + '(' + JSON.stringify(data) + ');'
    : JSON.stringify(data);
  const output = ContentService.createTextOutput(body);
  output.setMimeType(callback ? ContentService.MimeType.JAVASCRIPT : ContentService.MimeType.JSON);
  return output;
}

function textResponse_(message) {
  return ContentService.createTextOutput(message).setMimeType(ContentService.MimeType.TEXT);
}

function sanitizeCallback(callback) {
  return /^[A-Za-z_$][A-Za-z0-9_$]*(\.[A-Za-z_$][A-Za-z0-9_$]*)*$/.test(callback)
    ? callback
    : '';
}

const STORAGE_KEY = "usl-sar-esa.records.v1";

const fieldLabels = {
  recordId: "Record ID",
  nsn: "NSN",
  niin: "NIIN",
  fsc: "FSC",
  partType: "Part type",
  partName: "Part name",
  amc: "AMC",
  amsc: "AMSC",
  csiStatus: "CSI status",
  rppobStatus: "RPPOB status",
  esaStatus: "ESA status",
  esaSubmissionDate: "ESA submission date",
  sarCategory: "SAR category",
  sarStatus: "SAR status",
  technicalDataSource: "Technical data source",
  cFoldersStatus: "cFolders status",
  nsnLookupStatus: "NSNLookup status",
  drawingStatus: "Drawing status",
  manufacturingReview: "Manufacturing director review",
  engineeringReview: "Engineering director review",
  supplierCandidate: "Supplier candidate",
  quoteabilityStatus: "Quoteability status",
  nextAction: "Next action",
  followUpCadence: "Follow-up cadence",
  notes: "Notes"
};

const fieldOrder = Object.keys(fieldLabels);

const options = {
  csiStatus: ["Unknown", "No", "Possible", "Yes"],
  rppobStatus: ["Unknown", "Not Required", "Needed", "Drafting", "Submitted", "Approved"],
  esaStatus: ["Not Submitted", "Submitted", "Waiting", "Approved", "Rejected", "More Info Needed"],
  sarCategory: ["Unknown", "Category I", "Category II", "Category III", "Category IV"],
  sarStatus: ["Not Started", "Drafting", "Waiting Data", "Ready for Review", "Submitted", "Approved", "Rejected"],
  technicalDataSource: ["Unknown", "cFolders", "NSNLookup", "Drawing", "Standard Spec", "Reverse Engineering", "Physical Sample"],
  cFoldersStatus: ["Unknown", "No Access", "Requested", "Available", "Restricted", "Not Applicable"],
  nsnLookupStatus: ["Unknown", "Not Checked", "Checked", "Data Found", "No Data"],
  drawingStatus: ["Unknown", "Missing", "Poor Scan", "Partial", "Available", "Needs Reconstruction"],
  manufacturingReview: ["Not Started", "In Review", "Complete", "Blocked"],
  engineeringReview: ["Not Started", "In Review", "Complete", "Blocked"],
  quoteabilityStatus: ["Unknown", "Quote Ready", "Conditional", "Hold", "No-Go"],
  followUpCadence: ["None", "Daily", "Weekly", "Biweekly", "Monthly"]
};

const sampleRecords = [
  {
    id: crypto.randomUUID(),
    recordId: "USL-SAR-001",
    nsn: "4730-00-111-2222",
    niin: "001112222",
    fsc: "4730",
    partType: "Fitting / turned part",
    partName: "Adapter fitting, tube",
    amc: "3",
    amsc: "D",
    csiStatus: "Possible",
    rppobStatus: "Needed",
    esaStatus: "Waiting",
    esaSubmissionDate: nextDate(-3),
    sarCategory: "Category II",
    sarStatus: "Waiting Data",
    technicalDataSource: "cFolders",
    cFoldersStatus: "Requested",
    nsnLookupStatus: "Data Found",
    drawingStatus: "Partial",
    manufacturingReview: "In Review",
    engineeringReview: "In Review",
    supplierCandidate: "Precision turning supplier TBD",
    quoteabilityStatus: "Conditional",
    nextAction: "Confirm thread, material, finish, and ESA path before quote release.",
    followUpCadence: "Weekly",
    notes: "Pilot-style turned part. Do not release as quote-ready until technical controls and missing drawing callouts are resolved."
  },
  {
    id: crypto.randomUUID(),
    recordId: "USL-SAR-002",
    nsn: "3120-01-333-4444",
    niin: "013334444",
    fsc: "3120",
    partType: "Bushing / sleeve",
    partName: "Sleeve bushing",
    amc: "1",
    amsc: "G",
    csiStatus: "Unknown",
    rppobStatus: "Unknown",
    esaStatus: "Not Submitted",
    esaSubmissionDate: "",
    sarCategory: "Unknown",
    sarStatus: "Drafting",
    technicalDataSource: "NSNLookup",
    cFoldersStatus: "Unknown",
    nsnLookupStatus: "Checked",
    drawingStatus: "Needs Reconstruction",
    manufacturingReview: "Not Started",
    engineeringReview: "Not Started",
    supplierCandidate: "Lathe shop TBD",
    quoteabilityStatus: "Hold",
    nextAction: "Create gap list and determine whether ESA concurrence is needed.",
    followUpCadence: "Weekly",
    notes: "Potentially simple geometry, but controlled path is not yet known."
  },
  {
    id: crypto.randomUUID(),
    recordId: "USL-SAR-003",
    nsn: "5340-01-555-6666",
    niin: "015556666",
    fsc: "5340",
    partType: "Bracket / plate",
    partName: "Mounting bracket",
    amc: "",
    amsc: "",
    csiStatus: "No",
    rppobStatus: "Not Required",
    esaStatus: "Approved",
    esaSubmissionDate: nextDate(-20),
    sarCategory: "Category III",
    sarStatus: "Ready for Review",
    technicalDataSource: "Drawing",
    cFoldersStatus: "Available",
    nsnLookupStatus: "Data Found",
    drawingStatus: "Available",
    manufacturingReview: "Complete",
    engineeringReview: "Complete",
    supplierCandidate: "Sheet metal supplier TBD",
    quoteabilityStatus: "Quote Ready",
    nextAction: "Prepare supplier quote packet and first article assumptions.",
    followUpCadence: "Biweekly",
    notes: "Demo-ready example of a record moving toward supplier review."
  }
];

const elements = {
  form: document.querySelector("#record-form"),
  dialog: document.querySelector("#record-dialog"),
  dialogTitle: document.querySelector("#dialog-title"),
  newButton: document.querySelector("#new-record-button"),
  closeButton: document.querySelector("#close-dialog-button"),
  cancelButton: document.querySelector("#cancel-button"),
  deleteButton: document.querySelector("#delete-record-button"),
  printButton: document.querySelector("#print-record-button"),
  exportButton: document.querySelector("#export-csv-button"),
  clearFiltersButton: document.querySelector("#clear-filters-button"),
  searchInput: document.querySelector("#search-input"),
  esaFilter: document.querySelector("#esa-filter"),
  sarFilter: document.querySelector("#sar-filter"),
  csiFilter: document.querySelector("#csi-filter"),
  summaryGrid: document.querySelector("#summary-grid"),
  resultHeading: document.querySelector("#result-heading"),
  tableBody: document.querySelector("#records-table-body"),
  cardList: document.querySelector("#records-card-list"),
  emptyState: document.querySelector("#empty-state"),
  summaryTemplate: document.querySelector("#summary-template"),
  cardTemplate: document.querySelector("#card-template"),
  printSheet: document.querySelector("#print-sheet")
};

let records = loadRecords();

initialize();

function initialize() {
  Object.entries(options).forEach(([id, values]) => fillSelect(id, values));
  fillFilter(elements.esaFilter, "All ESA", options.esaStatus);
  fillFilter(elements.sarFilter, "All SAR", options.sarStatus);
  fillFilter(elements.csiFilter, "All CSI", options.csiStatus);

  elements.newButton.addEventListener("click", () => openDialog());
  elements.closeButton.addEventListener("click", closeDialog);
  elements.cancelButton.addEventListener("click", closeDialog);
  elements.deleteButton.addEventListener("click", deleteCurrentRecord);
  elements.printButton.addEventListener("click", printCurrentRecord);
  elements.exportButton.addEventListener("click", exportCsv);
  elements.clearFiltersButton.addEventListener("click", clearFilters);
  elements.form.addEventListener("submit", saveRecord);

  [elements.searchInput, elements.esaFilter, elements.sarFilter, elements.csiFilter].forEach((element) => {
    element.addEventListener("input", render);
  });

  render();
}

function nextDate(days) {
  const date = new Date();
  date.setDate(date.getDate() + days);
  return date.toISOString().slice(0, 10);
}

function loadRecords() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) {
    return sampleRecords;
  }

  try {
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) ? parsed : sampleRecords;
  } catch (error) {
    console.warn("Could not parse SAR / ESA records.", error);
    return sampleRecords;
  }
}

function persist() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
}

function fillSelect(id, values) {
  const select = document.querySelector(`#${id}`);
  select.innerHTML = values.map((value) => `<option>${escapeHtml(value)}</option>`).join("");
}

function fillFilter(select, label, values) {
  select.innerHTML = `<option value="">${escapeHtml(label)}</option>${values.map((value) => `<option>${escapeHtml(value)}</option>`).join("")}`;
}

function getFilteredRecords() {
  const query = elements.searchInput.value.trim().toLowerCase();
  const esa = elements.esaFilter.value;
  const sar = elements.sarFilter.value;
  const csi = elements.csiFilter.value;

  return records.filter((record) => {
    const searchBlob = [
      record.recordId,
      record.nsn,
      record.niin,
      record.fsc,
      record.partType,
      record.partName,
      record.supplierCandidate,
      record.quoteabilityStatus,
      record.nextAction,
      record.notes
    ].join(" ").toLowerCase();

    return (!query || searchBlob.includes(query))
      && (!esa || record.esaStatus === esa)
      && (!sar || record.sarStatus === sar)
      && (!csi || record.csiStatus === csi);
  }).sort(sortRecords);
}

function sortRecords(a, b) {
  const quoteRank = { "No-Go": 0, Hold: 1, Conditional: 2, Unknown: 3, "Quote Ready": 4 };
  const esaRank = { Rejected: 0, "More Info Needed": 1, Waiting: 2, Submitted: 3, "Not Submitted": 4, Approved: 5 };
  return (quoteRank[a.quoteabilityStatus] ?? 9) - (quoteRank[b.quoteabilityStatus] ?? 9)
    || (esaRank[a.esaStatus] ?? 9) - (esaRank[b.esaStatus] ?? 9)
    || String(a.partName || "").localeCompare(String(b.partName || ""));
}

function render() {
  const filtered = getFilteredRecords();
  renderSummary(filtered);
  renderTable(filtered);
  renderCards(filtered);

  elements.emptyState.hidden = filtered.length > 0;
  elements.resultHeading.textContent = `${filtered.length} Part Record${filtered.length === 1 ? "" : "s"}`;
}

function renderSummary(filtered) {
  const waitingEsa = filtered.filter((record) => ["Submitted", "Waiting", "More Info Needed"].includes(record.esaStatus)).length;
  const sarActive = filtered.filter((record) => !["Not Started", "Approved", "Rejected"].includes(record.sarStatus)).length;
  const quoteReady = filtered.filter((record) => record.quoteabilityStatus === "Quote Ready").length;
  const controlled = filtered.filter((record) => ["Possible", "Yes"].includes(record.csiStatus)).length;

  const summary = [
    ["Visible", filtered.length, "Filtered records"],
    ["ESA Waiting", waitingEsa, "Needs response"],
    ["SAR Active", sarActive, "In progress"],
    ["Quote Ready", quoteReady, "Supplier packet"],
    ["CSI Flags", controlled, "Possible or yes"]
  ];

  elements.summaryGrid.innerHTML = "";
  summary.forEach(([label, value, note]) => {
    const item = elements.summaryTemplate.content.cloneNode(true);
    item.querySelector("span").textContent = label;
    item.querySelector("strong").textContent = value;
    item.querySelector("small").textContent = note;
    elements.summaryGrid.append(item);
  });
}

function renderTable(filtered) {
  elements.tableBody.innerHTML = "";

  filtered.forEach((record) => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${pill(record.esaStatus, "esa")}</td>
      <td>${pill(record.sarStatus, "sar")}</td>
      <td>${pill(record.csiStatus, "csi")}</td>
      <td class="nsn-cell"><strong>${escapeHtml(record.nsn || "No NSN")}</strong><span>${escapeHtml(record.niin || "No NIIN")}</span></td>
      <td class="part-cell"><strong>${escapeHtml(record.partName || "Untitled part")}</strong><span>${escapeHtml(record.partType || record.recordId || "No type")}</span></td>
      <td>${pill(record.quoteabilityStatus, "quote")}</td>
      <td>${escapeHtml(record.nextAction || "No next action set")}</td>
      <td>
        <button class="button small" type="button" data-edit-id="${record.id}">Edit</button>
        <button class="button small" type="button" data-print-id="${record.id}">Print</button>
      </td>
    `;

    row.querySelector("[data-edit-id]").addEventListener("click", () => openDialog(record.id));
    row.querySelector("[data-print-id]").addEventListener("click", () => printRecord(record.id));
    elements.tableBody.append(row);
  });
}

function renderCards(filtered) {
  elements.cardList.innerHTML = "";

  filtered.forEach((record) => {
    const card = elements.cardTemplate.content.cloneNode(true);
    card.querySelector(".esa-pill").textContent = record.esaStatus;
    card.querySelector(".esa-pill").classList.add(slug(record.esaStatus));
    card.querySelector(".sar-pill").textContent = record.sarStatus;
    card.querySelector(".sar-pill").classList.add(slug(record.sarStatus));
    card.querySelector("h3").textContent = record.partName || "Untitled part";
    card.querySelector(".record-meta").textContent = `${record.partType || "Unknown type"} | ${record.recordId || "No record ID"}`;
    card.querySelector(".card-csi").textContent = record.csiStatus || "Unknown";
    card.querySelector(".card-nsn").textContent = record.nsn || "No NSN";
    card.querySelector(".card-quote").textContent = record.quoteabilityStatus || "Unknown";
    card.querySelector(".card-next").textContent = record.nextAction || "No next action set";
    card.querySelector(".edit-record-button").addEventListener("click", () => openDialog(record.id));
    card.querySelector(".print-card-button").addEventListener("click", () => printRecord(record.id));
    elements.cardList.append(card);
  });
}

function pill(value, type) {
  return `<span class="${type}-pill ${slug(value)}">${escapeHtml(value || "Unknown")}</span>`;
}

function slug(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

function openDialog(id = "") {
  elements.form.reset();
  document.querySelector("#id").value = id;
  elements.deleteButton.hidden = !id;
  elements.dialogTitle.textContent = id ? "Edit Part Record" : "New Part Record";

  const record = records.find((item) => item.id === id);
  if (record) {
    fieldOrder.concat("id").forEach((field) => {
      const input = document.querySelector(`#${field}`);
      if (input) {
        input.value = record[field] || "";
      }
    });
  } else {
    Object.entries(options).forEach(([field, values]) => {
      const input = document.querySelector(`#${field}`);
      if (input) {
        input.value = values[0];
      }
    });
    document.querySelector("#esaStatus").value = "Not Submitted";
    document.querySelector("#sarStatus").value = "Not Started";
    document.querySelector("#quoteabilityStatus").value = "Unknown";
  }

  if (typeof elements.dialog.showModal === "function") {
    elements.dialog.showModal();
  } else {
    elements.dialog.setAttribute("open", "");
  }
}

function closeDialog() {
  if (typeof elements.dialog.close === "function") {
    elements.dialog.close();
  } else {
    elements.dialog.removeAttribute("open");
  }
}

function saveRecord(event) {
  event.preventDefault();
  const formData = new FormData(elements.form);
  const id = formData.get("id") || crypto.randomUUID();
  const record = { id };

  fieldOrder.forEach((field) => {
    record[field] = String(formData.get(field) || "").trim();
  });

  const existingIndex = records.findIndex((item) => item.id === id);
  if (existingIndex >= 0) {
    records[existingIndex] = record;
  } else {
    records.unshift(record);
  }

  persist();
  closeDialog();
  render();
}

function deleteCurrentRecord() {
  const id = document.querySelector("#id").value;
  if (!id) {
    return;
  }

  const record = records.find((item) => item.id === id);
  const label = record?.partName || record?.recordId || "this record";
  if (!confirm(`Delete ${label}?`)) {
    return;
  }

  records = records.filter((item) => item.id !== id);
  persist();
  closeDialog();
  render();
}

function printCurrentRecord() {
  const id = document.querySelector("#id").value;
  if (id) {
    printRecord(id);
    return;
  }

  const formData = new FormData(elements.form);
  const draft = { id: "draft" };
  fieldOrder.forEach((field) => {
    draft[field] = String(formData.get(field) || "").trim();
  });
  renderPrintSheet(draft);
  window.print();
}

function printRecord(id) {
  const record = records.find((item) => item.id === id);
  if (!record) {
    return;
  }
  renderPrintSheet(record);
  window.print();
}

function renderPrintSheet(record) {
  const rows = fieldOrder.map((field) => `
    <div class="print-item">
      <strong>${escapeHtml(fieldLabels[field])}</strong>
      <span>${escapeHtml(record[field] || "Not set")}</span>
    </div>
  `).join("");

  elements.printSheet.innerHTML = `
    <p class="eyebrow">USL SAR / ESA / RPPOB Summary</p>
    <h1>${escapeHtml(record.partName || "Part Record")}</h1>
    <p>${escapeHtml(record.recordId || "No record ID")} | ${escapeHtml(record.nsn || "No NSN")} | Generated ${new Date().toLocaleString()}</p>
    <div class="print-grid">${rows}</div>
  `;
}

function clearFilters() {
  elements.searchInput.value = "";
  elements.esaFilter.value = "";
  elements.sarFilter.value = "";
  elements.csiFilter.value = "";
  render();
}

function exportCsv() {
  const csv = toCsv(records);
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `usl-sar-esa-records-${new Date().toISOString().slice(0, 10)}.csv`;
  document.body.append(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function toCsv(items) {
  const header = fieldOrder.map((field) => fieldLabels[field]);
  const rows = items.map((record) => fieldOrder.map((field) => record[field] || ""));
  return [header, ...rows].map((row) => row.map(csvEscape).join(",")).join("\n");
}

function csvEscape(value) {
  const text = String(value ?? "");
  return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, "\"\"")}"` : text;
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

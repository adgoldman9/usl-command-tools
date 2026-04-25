const STORAGE_KEY = "usl-opportunity-tracker.records.v1";

const fieldLabels = {
  opportunityId: "Opportunity ID",
  source: "Source",
  noticeId: "Notice ID",
  solicitationNumber: "Solicitation number",
  nsn: "NSN",
  niin: "NIIN",
  fsc: "FSC",
  partName: "Part name",
  agency: "Agency",
  buyer: "Buyer / Contracting Officer",
  dueDate: "Due date",
  amc: "AMC",
  amsc: "AMSC",
  csiStatus: "CSI status",
  technicalDataSource: "Technical data source",
  tdpStatus: "TDP status",
  supplierStatus: "Supplier status",
  decision: "Decision",
  priority: "Priority",
  nextAction: "Next action",
  followUpDate: "Follow-up date",
  notes: "Notes"
};

const fieldOrder = Object.keys(fieldLabels);

const options = {
  source: ["SAM.gov", "DIBBS", "LRAF", "Email", "Manual"],
  decision: ["Pursue", "Hold", "Skip", "Parked"],
  priority: ["High", "Medium", "Low"],
  csiStatus: ["Unknown", "No", "Possible", "Yes"],
  technicalDataSource: ["Unknown", "cFolders", "NSNLookup", "Standard Spec", "Reverse Engineering"],
  tdpStatus: ["Unknown", "Not Available", "Requested", "Partial", "Available", "Restricted"],
  supplierStatus: ["Unknown", "Not Started", "Identified", "Contacted", "Quoted", "No Quote"]
};

const sampleRecords = [
  {
    id: crypto.randomUUID(),
    opportunityId: "USL-OPP-001",
    source: "DIBBS",
    noticeId: "SPE4A6-26-T-1024",
    solicitationNumber: "SPE4A626T1024",
    nsn: "4730-00-111-2222",
    niin: "001112222",
    fsc: "4730",
    partName: "Adapter fitting, tube",
    agency: "DLA Aviation",
    buyer: "Buyer TBD",
    dueDate: nextDate(9),
    amc: "3",
    amsc: "D",
    csiStatus: "Unknown",
    technicalDataSource: "cFolders",
    tdpStatus: "Requested",
    supplierStatus: "Not Started",
    decision: "Hold",
    priority: "High",
    nextAction: "Confirm TDP access and screen thread/material requirements before supplier release.",
    followUpDate: nextDate(2),
    notes: "Good fit for turned-part pilot logic. Hold until technical data package is confirmed."
  },
  {
    id: crypto.randomUUID(),
    opportunityId: "USL-OPP-002",
    source: "SAM.gov",
    noticeId: "FA8126-26-Q-0007",
    solicitationNumber: "FA812626Q0007",
    nsn: "3120-01-333-4444",
    niin: "013334444",
    fsc: "3120",
    partName: "Sleeve bushing",
    agency: "USAF Sustainment",
    buyer: "Contracting POC TBD",
    dueDate: nextDate(14),
    amc: "1",
    amsc: "G",
    csiStatus: "Possible",
    technicalDataSource: "NSNLookup",
    tdpStatus: "Partial",
    supplierStatus: "Identified",
    decision: "Pursue",
    priority: "Medium",
    nextAction: "Build quick gap list and ask supplier for turning feasibility feedback.",
    followUpDate: nextDate(4),
    notes: "Candidate for bushing/sleeve workflow. Verify fit tolerances and material callout."
  },
  {
    id: crypto.randomUUID(),
    opportunityId: "USL-OPP-003",
    source: "Manual",
    noticeId: "Internal lead",
    solicitationNumber: "",
    nsn: "5340-01-555-6666",
    niin: "015556666",
    fsc: "5340",
    partName: "Mounting bracket",
    agency: "Depot lead",
    buyer: "Internal research",
    dueDate: "",
    amc: "",
    amsc: "",
    csiStatus: "Unknown",
    technicalDataSource: "Reverse Engineering",
    tdpStatus: "Not Available",
    supplierStatus: "Unknown",
    decision: "Parked",
    priority: "Low",
    nextAction: "Park until drawing, sample, or customer interest is available.",
    followUpDate: nextDate(21),
    notes: "Useful as a bracket/plate demo example, but not an active pursuit yet."
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
  exportButton: document.querySelector("#export-csv-button"),
  importButton: document.querySelector("#import-csv-button"),
  fileInput: document.querySelector("#csv-file-input"),
  clearFiltersButton: document.querySelector("#clear-filters-button"),
  searchInput: document.querySelector("#search-input"),
  decisionFilter: document.querySelector("#decision-filter"),
  priorityFilter: document.querySelector("#priority-filter"),
  sourceFilter: document.querySelector("#source-filter"),
  summaryGrid: document.querySelector("#summary-grid"),
  resultHeading: document.querySelector("#result-heading"),
  tableBody: document.querySelector("#records-table-body"),
  cardList: document.querySelector("#records-card-list"),
  emptyState: document.querySelector("#empty-state"),
  summaryTemplate: document.querySelector("#summary-template"),
  cardTemplate: document.querySelector("#card-template")
};

let records = loadRecords();

initialize();

function initialize() {
  fillSelect("source", options.source);
  fillSelect("decision", options.decision);
  fillSelect("priority", options.priority);
  fillSelect("csiStatus", options.csiStatus);
  fillSelect("technicalDataSource", options.technicalDataSource);
  fillSelect("tdpStatus", options.tdpStatus);
  fillSelect("supplierStatus", options.supplierStatus);
  fillFilter(elements.decisionFilter, "All decisions", options.decision);
  fillFilter(elements.priorityFilter, "All priorities", options.priority);
  fillFilter(elements.sourceFilter, "All sources", options.source);

  elements.newButton.addEventListener("click", () => openDialog());
  elements.closeButton.addEventListener("click", closeDialog);
  elements.cancelButton.addEventListener("click", closeDialog);
  elements.deleteButton.addEventListener("click", deleteCurrentRecord);
  elements.exportButton.addEventListener("click", exportCsv);
  elements.importButton.addEventListener("click", () => elements.fileInput.click());
  elements.fileInput.addEventListener("change", importCsv);
  elements.clearFiltersButton.addEventListener("click", clearFilters);
  elements.form.addEventListener("submit", saveRecord);

  [elements.searchInput, elements.decisionFilter, elements.priorityFilter, elements.sourceFilter].forEach((element) => {
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
    console.warn("Could not parse opportunity records.", error);
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
  const decision = elements.decisionFilter.value;
  const priority = elements.priorityFilter.value;
  const source = elements.sourceFilter.value;

  return records.filter((record) => {
    const searchBlob = [
      record.opportunityId,
      record.source,
      record.noticeId,
      record.solicitationNumber,
      record.nsn,
      record.niin,
      record.fsc,
      record.partName,
      record.agency,
      record.buyer,
      record.nextAction,
      record.notes
    ].join(" ").toLowerCase();

    return (!query || searchBlob.includes(query))
      && (!decision || record.decision === decision)
      && (!priority || record.priority === priority)
      && (!source || record.source === source);
  }).sort(sortRecords);
}

function sortRecords(a, b) {
  const priorityRank = { High: 0, Medium: 1, Low: 2 };
  const decisionRank = { Pursue: 0, Hold: 1, Parked: 2, Skip: 3 };
  const aDue = a.dueDate || "9999-12-31";
  const bDue = b.dueDate || "9999-12-31";

  return (priorityRank[a.priority] ?? 9) - (priorityRank[b.priority] ?? 9)
    || (decisionRank[a.decision] ?? 9) - (decisionRank[b.decision] ?? 9)
    || aDue.localeCompare(bDue);
}

function render() {
  const filtered = getFilteredRecords();
  renderSummary(filtered);
  renderTable(filtered);
  renderCards(filtered);

  elements.emptyState.hidden = filtered.length > 0;
  elements.resultHeading.textContent = `${filtered.length} Opportunity${filtered.length === 1 ? "" : " Records"}`;
}

function renderSummary(filtered) {
  const dueSoon = filtered.filter((record) => isDueSoon(record.dueDate)).length;
  const waitingTdp = filtered.filter((record) => ["Requested", "Partial", "Restricted", "Unknown"].includes(record.tdpStatus)).length;
  const pursue = filtered.filter((record) => record.decision === "Pursue").length;
  const hold = filtered.filter((record) => record.decision === "Hold").length;

  const summary = [
    ["Visible", filtered.length, "Filtered records"],
    ["Pursue", pursue, "Ready to work"],
    ["Hold", hold, "Needs data"],
    ["Due Soon", dueSoon, "Next 7 days"],
    ["TDP Gaps", waitingTdp, "Not fully ready"]
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

function isDueSoon(dateValue) {
  if (!dateValue) {
    return false;
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const dueDate = new Date(`${dateValue}T00:00:00`);
  const days = Math.round((dueDate - today) / 86400000);
  return days >= 0 && days <= 7;
}

function renderTable(filtered) {
  elements.tableBody.innerHTML = "";

  filtered.forEach((record) => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${pill(record.decision, "decision")}</td>
      <td>${pill(record.priority, "priority")}</td>
      <td class="nsn-cell"><strong>${escapeHtml(record.nsn || "No NSN")}</strong><span>${escapeHtml(record.niin || "No NIIN")}</span></td>
      <td class="part-cell"><strong>${escapeHtml(record.partName || "Untitled part")}</strong><span>${escapeHtml(record.noticeId || record.opportunityId || "No notice")}</span></td>
      <td>${escapeHtml(record.agency || "Unknown")}<br><span class="muted">${escapeHtml(record.source || "")}</span></td>
      <td>${formatDate(record.dueDate)}</td>
      <td>${escapeHtml(record.tdpStatus || "Unknown")}<br><span class="muted">${escapeHtml(record.technicalDataSource || "")}</span></td>
      <td>${escapeHtml(record.nextAction || "No next action set")}</td>
      <td><button class="button small" type="button" data-edit-id="${record.id}">Edit</button></td>
    `;

    row.querySelector("[data-edit-id]").addEventListener("click", () => openDialog(record.id));
    elements.tableBody.append(row);
  });
}

function renderCards(filtered) {
  elements.cardList.innerHTML = "";

  filtered.forEach((record) => {
    const card = elements.cardTemplate.content.cloneNode(true);
    card.querySelector(".decision-pill").textContent = record.decision;
    card.querySelector(".decision-pill").classList.add(slug(record.decision));
    card.querySelector(".priority-pill").textContent = record.priority;
    card.querySelector(".priority-pill").classList.add(slug(record.priority));
    card.querySelector("h3").textContent = record.partName || "Untitled part";
    card.querySelector(".record-meta").textContent = `${record.source || "Unknown source"} | ${record.agency || "Unknown agency"} | ${record.noticeId || "No notice"}`;
    card.querySelector(".card-nsn").textContent = record.nsn || "No NSN";
    card.querySelector(".card-due").textContent = formatDate(record.dueDate);
    card.querySelector(".card-tdp").textContent = `${record.tdpStatus || "Unknown"} / ${record.technicalDataSource || "Unknown"}`;
    card.querySelector(".card-next").textContent = record.nextAction || "No next action set";
    card.querySelector(".edit-record-button").addEventListener("click", () => openDialog(record.id));
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
  elements.dialogTitle.textContent = id ? "Edit Opportunity" : "New Opportunity";

  const record = records.find((item) => item.id === id);
  if (record) {
    fieldOrder.concat("id").forEach((field) => {
      const input = document.querySelector(`#${field}`);
      if (input) {
        input.value = record[field] || "";
      }
    });
  } else {
    document.querySelector("#source").value = "Manual";
    document.querySelector("#decision").value = "Hold";
    document.querySelector("#priority").value = "Medium";
    document.querySelector("#csiStatus").value = "Unknown";
    document.querySelector("#technicalDataSource").value = "Unknown";
    document.querySelector("#tdpStatus").value = "Unknown";
    document.querySelector("#supplierStatus").value = "Unknown";
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
  const label = record?.partName || record?.opportunityId || "this opportunity";
  if (!confirm(`Delete ${label}?`)) {
    return;
  }

  records = records.filter((item) => item.id !== id);
  persist();
  closeDialog();
  render();
}

function clearFilters() {
  elements.searchInput.value = "";
  elements.decisionFilter.value = "";
  elements.priorityFilter.value = "";
  elements.sourceFilter.value = "";
  render();
}

function exportCsv() {
  const csv = toCsv(records);
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `usl-opportunities-${new Date().toISOString().slice(0, 10)}.csv`;
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

async function importCsv(event) {
  const [file] = event.target.files;
  if (!file) {
    return;
  }

  const text = await file.text();
  const rows = parseCsv(text);
  event.target.value = "";

  if (rows.length < 2) {
    alert("No CSV rows found.");
    return;
  }

  const headers = rows[0].map(normalizeHeader);
  const imported = rows.slice(1)
    .filter((row) => row.some((cell) => String(cell || "").trim()))
    .map((row) => rowToRecord(headers, row));

  if (!imported.length) {
    alert("No usable opportunity rows found.");
    return;
  }

  records = [...imported, ...records];
  persist();
  render();
  alert(`Imported ${imported.length} opportunity record${imported.length === 1 ? "" : "s"}.`);
}

function rowToRecord(headers, row) {
  const record = { id: crypto.randomUUID() };

  fieldOrder.forEach((field) => {
    const index = headers.indexOf(normalizeHeader(fieldLabels[field]));
    record[field] = index >= 0 ? String(row[index] || "").trim() : "";
  });

  record.source = ensureOption(record.source, options.source, "Manual");
  record.decision = ensureOption(record.decision, options.decision, "Hold");
  record.priority = ensureOption(record.priority, options.priority, "Medium");
  record.csiStatus = ensureOption(record.csiStatus, options.csiStatus, "Unknown");
  record.technicalDataSource = ensureOption(record.technicalDataSource, options.technicalDataSource, "Unknown");
  record.tdpStatus = ensureOption(record.tdpStatus, options.tdpStatus, "Unknown");
  record.supplierStatus = ensureOption(record.supplierStatus, options.supplierStatus, "Unknown");

  return record;
}

function ensureOption(value, validOptions, fallback) {
  const found = validOptions.find((option) => option.toLowerCase() === String(value || "").toLowerCase());
  return found || fallback;
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let cell = "";
  let inQuotes = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    const next = text[index + 1];

    if (char === "\"" && inQuotes && next === "\"") {
      cell += "\"";
      index += 1;
    } else if (char === "\"") {
      inQuotes = !inQuotes;
    } else if (char === "," && !inQuotes) {
      row.push(cell);
      cell = "";
    } else if ((char === "\n" || char === "\r") && !inQuotes) {
      if (char === "\r" && next === "\n") {
        index += 1;
      }
      row.push(cell);
      rows.push(row);
      row = [];
      cell = "";
    } else {
      cell += char;
    }
  }

  row.push(cell);
  rows.push(row);
  return rows;
}

function normalizeHeader(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "");
}

function formatDate(dateValue) {
  if (!dateValue) {
    return "No date";
  }

  const date = new Date(`${dateValue}T00:00:00`);
  if (Number.isNaN(date.getTime())) {
    return dateValue;
  }

  return date.toLocaleDateString(undefined, {
    month: "short",
    day: "numeric",
    year: "numeric"
  });
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

const STORAGE_KEY = "usl-mobile-capture.items.v1";

const fieldLabels = {
  captureType: "Capture type",
  title: "Title",
  description: "Description",
  source: "Source",
  dateCaptured: "Date captured",
  priority: "Priority",
  targetLane: "Target lane",
  nextAction: "Next action",
  status: "Status",
  notes: "Notes"
};

const fieldOrder = Object.keys(fieldLabels);

const options = {
  captureType: ["CHATGPT TASK", "CODEX TASK", "FILE TASK", "WAITING", "OPPORTUNITY", "SUPPLIER LEAD", "NSN REVIEW", "FOLLOW-UP"],
  priority: ["High", "Medium", "Low"],
  targetLane: ["Daily Command / Agenda", "Opportunity Intake", "Supplier & Apollo Outreach", "SAR / ESA / RPPOB", "SBIR / AFWERX", "USL Software / CAD Platform", "Website / Marketing / Pitch", "Codex Builds"],
  status: ["Active", "Waiting", "Parked", "Routed", "Completed"]
};

const sampleItems = [
  {
    id: crypto.randomUUID(),
    captureType: "CODEX TASK",
    title: "Add follow-up date filter to Opportunity Tracker",
    description: "Mobile idea captured during workflow review. Need quick filters for overdue, today, and next 7 days.",
    source: "Mobile note",
    dateCaptured: today(),
    priority: "Medium",
    targetLane: "Codex Builds",
    nextAction: "Convert to Codex Build Packet when dashboard foundations are complete.",
    status: "Active",
    notes: "Sample record only."
  },
  {
    id: crypto.randomUUID(),
    captureType: "WAITING",
    title: "Waiting on external sustainment response",
    description: "Track buyer, ESA, supplier, or partner replies without losing the thread.",
    source: "Email / mobile",
    dateCaptured: today(),
    priority: "High",
    targetLane: "Daily Command / Agenda",
    nextAction: "Review daily command brief and follow up if overdue.",
    status: "Waiting",
    notes: "Replace with real waiting item or delete."
  }
];

const elements = {
  quickForm: document.querySelector("#quick-capture-form"),
  quickType: document.querySelector("#quick-type"),
  quickTitle: document.querySelector("#quick-title"),
  quickDescription: document.querySelector("#quick-description"),
  dialog: document.querySelector("#record-dialog"),
  form: document.querySelector("#record-form"),
  dialogTitle: document.querySelector("#dialog-title"),
  quickAddButton: document.querySelector("#quick-add-button"),
  closeButton: document.querySelector("#close-dialog-button"),
  cancelButton: document.querySelector("#cancel-button"),
  deleteButton: document.querySelector("#delete-record-button"),
  markRoutedButton: document.querySelector("#mark-routed-button"),
  exportButton: document.querySelector("#export-csv-button"),
  importButton: document.querySelector("#import-csv-button"),
  fileInput: document.querySelector("#csv-file-input"),
  clearFiltersButton: document.querySelector("#clear-filters-button"),
  searchInput: document.querySelector("#search-input"),
  typeFilter: document.querySelector("#type-filter"),
  statusFilter: document.querySelector("#status-filter"),
  laneFilter: document.querySelector("#lane-filter"),
  summaryGrid: document.querySelector("#summary-grid"),
  resultHeading: document.querySelector("#result-heading"),
  cardList: document.querySelector("#card-list"),
  emptyState: document.querySelector("#empty-state"),
  summaryTemplate: document.querySelector("#summary-template"),
  cardTemplate: document.querySelector("#card-template")
};

let items = loadItems();
initialize();

function initialize() {
  fillSelect("quick-type", options.captureType);
  fillSelect("captureType", options.captureType);
  fillSelect("priority", options.priority);
  fillSelect("targetLane", options.targetLane);
  fillSelect("status", options.status);
  fillFilter(elements.typeFilter, "All types", options.captureType);
  fillFilter(elements.statusFilter, "All status", options.status);
  fillFilter(elements.laneFilter, "All lanes", options.targetLane);

  elements.quickForm.addEventListener("submit", quickCapture);
  elements.quickAddButton.addEventListener("click", () => openDialog());
  elements.closeButton.addEventListener("click", closeDialog);
  elements.cancelButton.addEventListener("click", closeDialog);
  elements.deleteButton.addEventListener("click", deleteCurrentItem);
  elements.markRoutedButton.addEventListener("click", markCurrentRouted);
  elements.exportButton.addEventListener("click", exportCsv);
  elements.importButton.addEventListener("click", () => elements.fileInput.click());
  elements.fileInput.addEventListener("change", importCsv);
  elements.clearFiltersButton.addEventListener("click", clearFilters);
  elements.form.addEventListener("submit", saveItem);

  [elements.searchInput, elements.typeFilter, elements.statusFilter, elements.laneFilter].forEach((element) => {
    element.addEventListener("input", render);
  });

  render();
}

function today() {
  return new Date().toISOString().slice(0, 10);
}

function loadItems() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) return sampleItems;
  try {
    const parsed = JSON.parse(stored);
    return Array.isArray(parsed) ? parsed : sampleItems;
  } catch (error) {
    console.warn("Could not parse mobile capture items.", error);
    return sampleItems;
  }
}

function persist() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
}

function fillSelect(id, values) {
  const select = document.querySelector(`#${id}`);
  select.innerHTML = values.map((value) => `<option>${escapeHtml(value)}</option>`).join("");
}

function fillFilter(select, label, values) {
  select.innerHTML = `<option value="">${escapeHtml(label)}</option>${values.map((value) => `<option>${escapeHtml(value)}</option>`).join("")}`;
}

function quickCapture(event) {
  event.preventDefault();
  const captureType = elements.quickType.value;
  const title = elements.quickTitle.value.trim();
  const description = elements.quickDescription.value.trim();
  if (!title) return;

  items.unshift({
    id: crypto.randomUUID(),
    captureType,
    title,
    description,
    source: "Mobile / quick capture",
    dateCaptured: today(),
    priority: inferPriority(captureType),
    targetLane: inferLane(captureType),
    nextAction: inferNextAction(captureType),
    status: captureType === "WAITING" ? "Waiting" : "Active",
    notes: ""
  });

  persist();
  elements.quickForm.reset();
  elements.quickType.value = captureType;
  render();
}

function inferPriority(type) {
  return ["OPPORTUNITY", "NSN REVIEW", "FOLLOW-UP"].includes(type) ? "High" : "Medium";
}

function inferLane(type) {
  const map = {
    "CHATGPT TASK": "Daily Command / Agenda",
    "CODEX TASK": "Codex Builds",
    "FILE TASK": "Daily Command / Agenda",
    "WAITING": "Daily Command / Agenda",
    "OPPORTUNITY": "Opportunity Intake",
    "SUPPLIER LEAD": "Supplier & Apollo Outreach",
    "NSN REVIEW": "Opportunity Intake",
    "FOLLOW-UP": "Daily Command / Agenda"
  };
  return map[type] || "Daily Command / Agenda";
}

function inferNextAction(type) {
  const map = {
    "CHATGPT TASK": "Handle in ChatGPT business workflow.",
    "CODEX TASK": "Convert to Codex Build Packet.",
    "FILE TASK": "Organize, upload, convert, or attach file.",
    "WAITING": "Check follow-up timing and owner.",
    "OPPORTUNITY": "Create or update Opportunity Tracker record.",
    "SUPPLIER LEAD": "Add to supplier outreach workflow.",
    "NSN REVIEW": "Screen NSN, TDP, AMC/AMSC, CSI, and pursue/hold decision.",
    "FOLLOW-UP": "Add to agenda and contact owner."
  };
  return map[type] || "Route to daily command board.";
}

function getFilteredItems() {
  const query = elements.searchInput.value.trim().toLowerCase();
  const type = elements.typeFilter.value;
  const status = elements.statusFilter.value;
  const lane = elements.laneFilter.value;

  return items.filter((item) => {
    const blob = [item.captureType, item.title, item.description, item.source, item.targetLane, item.nextAction, item.status, item.notes].join(" ").toLowerCase();
    return (!query || blob.includes(query)) && (!type || item.captureType === type) && (!status || item.status === status) && (!lane || item.targetLane === lane);
  }).sort(sortItems);
}

function sortItems(a, b) {
  const statusRank = { Active: 0, Waiting: 1, Parked: 2, Routed: 3, Completed: 4 };
  const priorityRank = { High: 0, Medium: 1, Low: 2 };
  return (statusRank[a.status] ?? 9) - (statusRank[b.status] ?? 9)
    || (priorityRank[a.priority] ?? 9) - (priorityRank[b.priority] ?? 9)
    || String(b.dateCaptured || "").localeCompare(String(a.dateCaptured || ""));
}

function render() {
  const filtered = getFilteredItems();
  renderSummary(filtered);
  renderCards(filtered);
  elements.emptyState.hidden = filtered.length > 0;
  elements.resultHeading.textContent = `${filtered.length} Capture Item${filtered.length === 1 ? "" : "s"}`;
}

function renderSummary(filtered) {
  const active = filtered.filter((item) => item.status === "Active").length;
  const waiting = filtered.filter((item) => item.status === "Waiting").length;
  const codex = filtered.filter((item) => item.captureType === "CODEX TASK").length;
  const unrouted = filtered.filter((item) => !["Routed", "Completed"].includes(item.status)).length;
  const summary = [["Visible", filtered.length, "Filtered items"], ["Active", active, "Needs motion"], ["Waiting", waiting, "External status"], ["Codex", codex, "Build ideas"], ["Unrouted", unrouted, "Needs routing"]];

  elements.summaryGrid.innerHTML = "";
  summary.forEach(([label, value, note]) => {
    const item = elements.summaryTemplate.content.cloneNode(true);
    item.querySelector("span").textContent = label;
    item.querySelector("strong").textContent = value;
    item.querySelector("small").textContent = note;
    elements.summaryGrid.append(item);
  });
}

function renderCards(filtered) {
  elements.cardList.innerHTML = "";
  filtered.forEach((item) => {
    const card = elements.cardTemplate.content.cloneNode(true);
    const article = card.querySelector(".capture-card");
    article.classList.toggle("routed", ["Routed", "Completed"].includes(item.status));
    card.querySelector(".type-pill").textContent = item.captureType;
    card.querySelector(".type-pill").classList.add(slug(item.captureType));
    card.querySelector(".status-pill").textContent = item.status;
    card.querySelector(".status-pill").classList.add(slug(item.status));
    card.querySelector("h3").textContent = item.title || "Untitled capture";
    card.querySelector(".description").textContent = item.description || "No description yet.";
    card.querySelector(".card-lane").textContent = item.targetLane || "No lane";
    card.querySelector(".card-next").textContent = item.nextAction || "No next action";
    card.querySelector(".card-source").textContent = item.source || "No source";
    card.querySelector(".card-date").textContent = formatDate(item.dateCaptured);
    card.querySelector(".edit-button").addEventListener("click", () => openDialog(item.id));
    card.querySelector(".route-button").addEventListener("click", () => markRouted(item.id));
    elements.cardList.append(card);
  });
}

function openDialog(id = "") {
  elements.form.reset();
  document.querySelector("#id").value = id;
  elements.deleteButton.hidden = !id;
  elements.markRoutedButton.hidden = !id;
  elements.dialogTitle.textContent = id ? "Edit Capture" : "New Capture";

  const item = items.find((entry) => entry.id === id);
  if (item) {
    fieldOrder.concat("id").forEach((field) => {
      const input = document.querySelector(`#${field}`);
      if (input) input.value = item[field] || "";
    });
  } else {
    document.querySelector("#captureType").value = "CHATGPT TASK";
    document.querySelector("#priority").value = "Medium";
    document.querySelector("#targetLane").value = "Daily Command / Agenda";
    document.querySelector("#status").value = "Active";
    document.querySelector("#dateCaptured").value = today();
  }

  if (typeof elements.dialog.showModal === "function") elements.dialog.showModal();
  else elements.dialog.setAttribute("open", "");
}

function closeDialog() {
  if (typeof elements.dialog.close === "function") elements.dialog.close();
  else elements.dialog.removeAttribute("open");
}

function saveItem(event) {
  event.preventDefault();
  const formData = new FormData(elements.form);
  const id = formData.get("id") || crypto.randomUUID();
  const item = { id };
  fieldOrder.forEach((field) => { item[field] = String(formData.get(field) || "").trim(); });
  const existingIndex = items.findIndex((entry) => entry.id === id);
  if (existingIndex >= 0) items[existingIndex] = item;
  else items.unshift(item);
  persist();
  closeDialog();
  render();
}

function deleteCurrentItem() {
  const id = document.querySelector("#id").value;
  if (!id) return;
  const item = items.find((entry) => entry.id === id);
  if (!confirm(`Delete ${item?.title || "this capture item"}?`)) return;
  items = items.filter((entry) => entry.id !== id);
  persist();
  closeDialog();
  render();
}

function markCurrentRouted() {
  const id = document.querySelector("#id").value;
  if (id) {
    markRouted(id);
    closeDialog();
  }
}

function markRouted(id) {
  const item = items.find((entry) => entry.id === id);
  if (!item) return;
  item.status = "Routed";
  item.notes = item.notes ? `${item.notes}\nMarked routed ${today()}.` : `Marked routed ${today()}.`;
  persist();
  render();
}

function clearFilters() {
  elements.searchInput.value = "";
  elements.typeFilter.value = "";
  elements.statusFilter.value = "";
  elements.laneFilter.value = "";
  render();
}

function exportCsv() {
  const csv = toCsv(items);
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `usl-mobile-capture-${today()}.csv`;
  document.body.append(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function toCsv(records) {
  const header = fieldOrder.map((field) => fieldLabels[field]);
  const rows = records.map((record) => fieldOrder.map((field) => record[field] || ""));
  return [header, ...rows].map((row) => row.map(csvEscape).join(",")).join("\n");
}

function csvEscape(value) {
  const text = String(value ?? "");
  return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, "\"\"")}"` : text;
}

async function importCsv(event) {
  const [file] = event.target.files;
  if (!file) return;
  const text = await file.text();
  const rows = parseCsv(text);
  event.target.value = "";
  if (rows.length < 2) {
    alert("No CSV rows found.");
    return;
  }
  const headers = rows[0].map(normalizeHeader);
  const imported = rows.slice(1).filter((row) => row.some((cell) => String(cell || "").trim())).map((row) => rowToItem(headers, row));
  if (!imported.length) {
    alert("No usable capture rows found.");
    return;
  }
  items = [...imported, ...items];
  persist();
  render();
  alert(`Imported ${imported.length} capture item${imported.length === 1 ? "" : "s"}.`);
}

function rowToItem(headers, row) {
  const item = { id: crypto.randomUUID() };
  fieldOrder.forEach((field) => {
    const index = headers.indexOf(normalizeHeader(fieldLabels[field]));
    item[field] = index >= 0 ? String(row[index] || "").trim() : "";
  });
  item.captureType = ensureOption(item.captureType, options.captureType, "CHATGPT TASK");
  item.priority = ensureOption(item.priority, options.priority, "Medium");
  item.targetLane = ensureOption(item.targetLane, options.targetLane, "Daily Command / Agenda");
  item.status = ensureOption(item.status, options.status, "Active");
  item.dateCaptured = item.dateCaptured || today();
  return item;
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
      if (char === "\r" && next === "\n") index += 1;
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

function slug(value) {
  return String(value || "").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

function formatDate(dateValue) {
  if (!dateValue) return "No date";
  const date = new Date(`${dateValue}T00:00:00`);
  if (Number.isNaN(date.getTime())) return dateValue;
  return date.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
}

function escapeHtml(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

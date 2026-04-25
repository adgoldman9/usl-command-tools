(function () {
  const STORAGE_KEY = "usl-command-dashboard.tasks.v1";

  const lanes = [
    "Daily Command / Agenda",
    "Opportunity Intake",
    "Supplier & Apollo Outreach",
    "SAR / ESA / RPPOB",
    "SBIR / AFWERX",
    "USL Software / CAD Platform",
    "Website / Marketing / Pitch",
    "Codex Builds"
  ];

  const statuses = ["Active", "Waiting", "Parked", "Completed"];

  const seedTasks = [
    {
      id: crypto.randomUUID(),
      title: "Review daily command priorities",
      lane: "Daily Command / Agenda",
      status: "Active",
      priority: "High",
      owner: "Andrew",
      dueDate: "",
      currentStatus: "Daily operating lane is ready for priority review.",
      nextAction: "Add today's top three actions.",
      notes: "Starter record. Edit or delete after first use.",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: crypto.randomUUID(),
      title: "Build Opportunity Tracker",
      lane: "Codex Builds",
      status: "Active",
      priority: "High",
      owner: "Codex",
      dueDate: "",
      currentStatus: "Recommended second build after this dashboard.",
      nextAction: "Run the Opportunity Tracker Codex prompt.",
      notes: "Use plain HTML/CSS/JS and localStorage.",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ];

  const elements = {
    board: document.getElementById("lane-board"),
    summaryGrid: document.getElementById("summary-grid"),
    laneFilter: document.getElementById("lane-filter"),
    statusFilter: document.getElementById("status-filter"),
    searchInput: document.getElementById("search-input"),
    clearFiltersButton: document.getElementById("clear-filters-button"),
    newTaskButton: document.getElementById("new-task-button"),
    exportCsvButton: document.getElementById("export-csv-button"),
    dialog: document.getElementById("task-dialog"),
    dialogTitle: document.getElementById("dialog-title"),
    form: document.getElementById("task-form"),
    closeDialogButton: document.getElementById("close-dialog-button"),
    cancelButton: document.getElementById("cancel-button"),
    deleteTaskButton: document.getElementById("delete-task-button"),
    template: document.getElementById("task-card-template")
  };

  const fields = {
    id: document.getElementById("task-id"),
    title: document.getElementById("title"),
    lane: document.getElementById("lane"),
    status: document.getElementById("status"),
    priority: document.getElementById("priority"),
    owner: document.getElementById("owner"),
    dueDate: document.getElementById("dueDate"),
    currentStatus: document.getElementById("currentStatus"),
    nextAction: document.getElementById("nextAction"),
    notes: document.getElementById("notes")
  };

  let tasks = loadTasks();

  function loadTasks() {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return seedTasks;
    }

    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : seedTasks;
    } catch {
      return seedTasks;
    }
  }

  function saveTasks() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks));
  }

  function fillSelect(select, values, includeAllLabel) {
    select.innerHTML = "";

    if (includeAllLabel) {
      const option = document.createElement("option");
      option.value = "All";
      option.textContent = includeAllLabel;
      select.appendChild(option);
    }

    values.forEach((value) => {
      const option = document.createElement("option");
      option.value = value;
      option.textContent = value;
      select.appendChild(option);
    });
  }

  function getFilteredTasks() {
    const lane = elements.laneFilter.value;
    const status = elements.statusFilter.value;
    const query = elements.searchInput.value.trim().toLowerCase();

    return tasks.filter((task) => {
      const matchesLane = lane === "All" || task.lane === lane;
      const matchesStatus = status === "All" || task.status === status;
      const searchable = [
        task.title,
        task.owner,
        task.currentStatus,
        task.nextAction,
        task.notes,
        task.lane,
        task.status,
        task.priority
      ].join(" ").toLowerCase();
      const matchesQuery = !query || searchable.includes(query);
      return matchesLane && matchesStatus && matchesQuery;
    });
  }

  function renderSummary(filteredTasks) {
    const active = tasks.filter((task) => task.status === "Active").length;
    const waiting = tasks.filter((task) => task.status === "Waiting").length;
    const dueSoon = tasks.filter((task) => isDueSoon(task.dueDate) && task.status !== "Completed").length;
    const visible = filteredTasks.length;

    const stats = [
      ["Visible Records", visible],
      ["Active", active],
      ["Waiting", waiting],
      ["Due Next 7 Days", dueSoon]
    ];

    elements.summaryGrid.innerHTML = "";
    stats.forEach(([label, value]) => {
      const item = document.createElement("article");
      item.className = "summary-item";
      item.innerHTML = `<span>${label}</span><strong>${value}</strong>`;
      elements.summaryGrid.appendChild(item);
    });
  }

  function isDueSoon(value) {
    if (!value) {
      return false;
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const due = new Date(`${value}T00:00:00`);
    const diffDays = Math.round((due - today) / 86400000);
    return diffDays >= 0 && diffDays <= 7;
  }

  function renderBoard() {
    const filteredTasks = getFilteredTasks();
    renderSummary(filteredTasks);
    elements.board.innerHTML = "";

    lanes.forEach((lane) => {
      const laneTasks = filteredTasks.filter((task) => task.lane === lane);
      const column = document.createElement("section");
      column.className = "lane-column";
      column.innerHTML = `
        <div class="lane-header">
          <h2>${lane}</h2>
          <span class="lane-count">${laneTasks.length}</span>
        </div>
        <div class="task-list"></div>
      `;

      const taskList = column.querySelector(".task-list");
      if (laneTasks.length === 0) {
        const empty = document.createElement("p");
        empty.className = "empty-state";
        empty.textContent = "No matching tasks.";
        taskList.appendChild(empty);
      } else {
        laneTasks
          .sort(sortByPriorityAndDueDate)
          .forEach((task) => taskList.appendChild(createTaskCard(task)));
      }

      elements.board.appendChild(column);
    });
  }

  function sortByPriorityAndDueDate(a, b) {
    const weights = { High: 0, Medium: 1, Low: 2 };
    const priorityDiff = weights[a.priority] - weights[b.priority];
    if (priorityDiff !== 0) {
      return priorityDiff;
    }
    return (a.dueDate || "9999-12-31").localeCompare(b.dueDate || "9999-12-31");
  }

  function createTaskCard(task) {
    const fragment = elements.template.content.cloneNode(true);
    const card = fragment.querySelector(".task-card");
    const statusPill = fragment.querySelector(".status-pill");
    const priorityPill = fragment.querySelector(".priority-pill");

    statusPill.textContent = task.status;
    statusPill.classList.add(task.status.toLowerCase());
    priorityPill.textContent = task.priority;
    priorityPill.classList.add(task.priority.toLowerCase());

    fragment.querySelector("h3").textContent = task.title;
    fragment.querySelector(".current-status").textContent = task.currentStatus || "No current status entered.";
    fragment.querySelector(".next-action").textContent = task.nextAction || "No next action entered.";
    fragment.querySelector(".owner").textContent = task.owner || "Unassigned";
    fragment.querySelector(".due-date").textContent = formatDate(task.dueDate);

    fragment.querySelector(".edit-task-button").addEventListener("click", () => openDialog(task));
    card.dataset.id = task.id;
    return fragment;
  }

  function formatDate(value) {
    if (!value) {
      return "No date";
    }
    const date = new Date(`${value}T00:00:00`);
    return date.toLocaleDateString(undefined, { month: "short", day: "numeric", year: "numeric" });
  }

  function openDialog(task) {
    const isEditing = Boolean(task);
    elements.dialogTitle.textContent = isEditing ? "Edit Task" : "New Task";
    elements.deleteTaskButton.hidden = !isEditing;

    const record = task || {
      id: "",
      title: "",
      lane: lanes[0],
      status: "Active",
      priority: "Medium",
      owner: "",
      dueDate: "",
      currentStatus: "",
      nextAction: "",
      notes: ""
    };

    Object.entries(fields).forEach(([key, field]) => {
      field.value = record[key] || "";
    });

    elements.dialog.showModal();
    fields.title.focus();
  }

  function closeDialog() {
    elements.dialog.close();
    elements.form.reset();
  }

  function handleSubmit(event) {
    event.preventDefault();
    const now = new Date().toISOString();
    const id = fields.id.value || crypto.randomUUID();
    const existing = tasks.find((task) => task.id === id);
    const record = {
      id,
      title: fields.title.value.trim(),
      lane: fields.lane.value,
      status: fields.status.value,
      priority: fields.priority.value,
      owner: fields.owner.value.trim(),
      dueDate: fields.dueDate.value,
      currentStatus: fields.currentStatus.value.trim(),
      nextAction: fields.nextAction.value.trim(),
      notes: fields.notes.value.trim(),
      createdAt: existing ? existing.createdAt : now,
      updatedAt: now
    };

    if (existing) {
      tasks = tasks.map((task) => task.id === id ? record : task);
    } else {
      tasks.unshift(record);
    }

    saveTasks();
    closeDialog();
    renderBoard();
  }

  function deleteCurrentTask() {
    const id = fields.id.value;
    if (!id) {
      return;
    }
    const task = tasks.find((item) => item.id === id);
    const label = task ? task.title : "this task";
    if (!window.confirm(`Delete "${label}"?`)) {
      return;
    }
    tasks = tasks.filter((item) => item.id !== id);
    saveTasks();
    closeDialog();
    renderBoard();
  }

  function exportCsv() {
    const rows = getFilteredTasks();
    const headers = [
      "Title",
      "Lane",
      "Status",
      "Priority",
      "Owner",
      "Due Date",
      "Current Status",
      "Next Action",
      "Notes",
      "Created At",
      "Updated At"
    ];
    const csv = [
      headers.join(","),
      ...rows.map((task) => [
        task.title,
        task.lane,
        task.status,
        task.priority,
        task.owner,
        task.dueDate,
        task.currentStatus,
        task.nextAction,
        task.notes,
        task.createdAt,
        task.updatedAt
      ].map(csvEscape).join(","))
    ].join("\n");

    const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `usl-command-dashboard-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    link.remove();
    URL.revokeObjectURL(url);
  }

  function csvEscape(value) {
    const text = String(value ?? "");
    return `"${text.replaceAll('"', '""')}"`;
  }

  function clearFilters() {
    elements.laneFilter.value = "All";
    elements.statusFilter.value = "All";
    elements.searchInput.value = "";
    renderBoard();
  }

  function bindEvents() {
    elements.newTaskButton.addEventListener("click", () => openDialog());
    elements.exportCsvButton.addEventListener("click", exportCsv);
    elements.clearFiltersButton.addEventListener("click", clearFilters);
    elements.closeDialogButton.addEventListener("click", closeDialog);
    elements.cancelButton.addEventListener("click", closeDialog);
    elements.deleteTaskButton.addEventListener("click", deleteCurrentTask);
    elements.form.addEventListener("submit", handleSubmit);
    elements.laneFilter.addEventListener("change", renderBoard);
    elements.statusFilter.addEventListener("change", renderBoard);
    elements.searchInput.addEventListener("input", renderBoard);
  }

  function init() {
    fillSelect(elements.laneFilter, lanes, "All lanes");
    fillSelect(elements.statusFilter, statuses, "All statuses");
    fillSelect(fields.lane, lanes);
    fillSelect(fields.status, statuses);
    saveTasks();
    bindEvents();
    renderBoard();
  }

  init();
})();

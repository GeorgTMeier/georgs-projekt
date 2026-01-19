(() => {
  const body = document.body;
  const tableName = body.dataset.table;
  const pk = body.dataset.pk;

  const dot = document.getElementById("saveDot");
  const text = document.getElementById("saveText");

  function setStatus(kind, msg) {
    dot.className = "status-dot";
    if (kind) dot.classList.add(kind);
    text.textContent = msg;
  }

  function flashCell(td, cls, ms = 800) {
    td.classList.add(cls);
    window.setTimeout(() => td.classList.remove(cls), ms);
  }

  async function saveCell(td) {
    const tr = td.closest("tr");
    if (!tr) return;

    const id = tr.dataset.id;
    const col = td.dataset.col;
    if (!id || !col) return;

    const value = td.innerText; // keep as typed (server will cast)

    td.classList.remove("error", "saved");
    td.classList.add("saving");
    setStatus("saving", "speichere…");

    try {
      const res = await fetch(`/api/rows/${encodeURIComponent(id)}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ [col]: value }),
      });

      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        const err = data?.error || `HTTP ${res.status}`;
        throw new Error(err);
      }

      td.classList.remove("saving");
      flashCell(td, "saved", 600);
      setStatus("ok", "gespeichert");
      window.setTimeout(() => setStatus(null, "bereit"), 900);
    } catch (e) {
      td.classList.remove("saving");
      flashCell(td, "error", 1400);
      setStatus("err", `Fehler: ${e.message}`);
      window.setTimeout(() => setStatus(null, "bereit"), 1800);
    }
  }

  // Save on blur (leaving cell)
  document.addEventListener(
    "blur",
    (e) => {
      const td = e.target;
      if (!(td instanceof HTMLElement)) return;
      if (td.tagName !== "TD") return;
      if (!td.dataset.col) return;
      if (td.getAttribute("contenteditable") !== "true") return;
      saveCell(td);
    },
    true
  );

  // Save on Enter (but keep navigation easy)
  document.addEventListener("keydown", (e) => {
    const td = e.target;
    if (!(td instanceof HTMLElement)) return;
    if (td.tagName !== "TD") return;
    if (!td.dataset.col) return;
    if (td.getAttribute("contenteditable") !== "true") return;

    if (e.key === "Enter") {
      e.preventDefault();
      td.blur();
    }
    if (e.key === "Escape") {
      td.blur();
    }
  });

  // Basic sanity info in case someone loads the page without data attributes
  if (!tableName || !pk) {
    setStatus("err", "Konfiguration fehlt (data-table / data-pk)");
  }
})();

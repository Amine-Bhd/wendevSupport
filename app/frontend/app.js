const ticketsContainer = document.querySelector("#tickets");
const ticketTemplate = document.querySelector("#ticket-template");
const ticketForm = document.querySelector("#ticket-form");
const refreshButton = document.querySelector("#refresh");
const ticketCount = document.querySelector("#ticket-count");
const apiStatus = document.querySelector("#api-status");

const statusLabels = {
  ouvert: "Ouvert",
  en_cours: "En cours",
  resolu: "Résolu",
  ferme: "Fermé"
};

function setApiStatus(ok, text) {
  apiStatus.textContent = text;
  apiStatus.dataset.state = ok ? "ok" : "error";
}

async function checkHealth() {
  try {
    const response = await fetch("/api/health");
    if (!response.ok) {
      throw new Error("API indisponible");
    }
    const payload = await response.json();
    setApiStatus(true, `API disponible - ${payload.hostname}`);
  } catch (_error) {
    setApiStatus(false, "API indisponible");
  }
}

function emptyState() {
  ticketsContainer.innerHTML = `
    <div class="empty-state">
      Aucun ticket pour le moment.
    </div>
  `;
}

function renderTickets(tickets) {
  ticketsContainer.innerHTML = "";
  ticketCount.textContent = `${tickets.length} ticket${tickets.length > 1 ? "s" : ""}`;

  if (tickets.length === 0) {
    emptyState();
    return;
  }

  for (const ticket of tickets) {
    const node = ticketTemplate.content.cloneNode(true);
    const article = node.querySelector(".ticket");
    const title = node.querySelector("h3");
    const description = node.querySelector(".description");
    const priority = node.querySelector(".priority");
    const statusLabel = node.querySelector(".status-label");
    const statusSelect = node.querySelector(".status-select");

    article.dataset.status = ticket.status;
    title.textContent = ticket.title;
    description.textContent = ticket.description || "Sans description.";
    priority.textContent = ticket.priority;
    priority.dataset.priority = ticket.priority;
    statusLabel.textContent = statusLabels[ticket.status] || ticket.status;
    statusSelect.value = ticket.status;
    statusSelect.addEventListener("change", () => updateTicketStatus(ticket.id, statusSelect.value));

    ticketsContainer.appendChild(node);
  }
}

async function loadTickets() {
  refreshButton.disabled = true;
  try {
    const response = await fetch("/api/tickets");
    if (!response.ok) {
      throw new Error("Impossible de charger les tickets");
    }
    renderTickets(await response.json());
  } catch (error) {
    ticketsContainer.innerHTML = `<div class="empty-state error">${error.message}</div>`;
  } finally {
    refreshButton.disabled = false;
  }
}

async function createTicket(event) {
  event.preventDefault();
  const formData = new FormData(ticketForm);
  const payload = {
    title: formData.get("title"),
    description: formData.get("description"),
    priority: formData.get("priority")
  };

  const response = await fetch("/api/tickets", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ error: "Création impossible." }));
    alert(error.error || "Création impossible.");
    return;
  }

  ticketForm.reset();
  document.querySelector("#priority").value = "normale";
  await loadTickets();
}

async function updateTicketStatus(id, status) {
  const response = await fetch(`/api/tickets/${id}`, {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ status })
  });

  if (!response.ok) {
    alert("La mise à jour du statut a échoué.");
  }

  await loadTickets();
}

ticketForm.addEventListener("submit", createTicket);
refreshButton.addEventListener("click", loadTickets);

checkHealth();
loadTickets();
setInterval(checkHealth, 15000);

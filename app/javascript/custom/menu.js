const boundControls = new WeakSet();

function addToggleListener(controlId, menuId, toggleClass) {
  const control = document.getElementById(controlId);
  const menu = document.getElementById(menuId);
  if (!control || !menu || boundControls.has(control)) return;

  control.addEventListener("click", (event) => {
    event.preventDefault();
    const enabled = menu.classList.toggle(toggleClass);
    const expanded = toggleClass === "collapse" ? !enabled : enabled;
    control.setAttribute("aria-expanded", String(expanded));
    if (controlId === "hamburger") control.classList.toggle("collapsed", !expanded);
  });
  boundControls.add(control);
}

document.addEventListener("turbo:load", () => {
  addToggleListener("hamburger", "navbar-menu", "collapse");
  addToggleListener("account", "dropdown-menu", "active");
});

document.addEventListener("turbo:before-cache", () => {
  document.getElementById("navbar-menu")?.classList.add("collapse");
  document.getElementById("dropdown-menu")?.classList.remove("active");
  document.getElementById("hamburger")?.classList.add("collapsed");
  for (const id of ["hamburger", "account"]) {
    document.getElementById(id)?.setAttribute("aria-expanded", "false");
  }
});

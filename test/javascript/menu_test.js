const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

function element(initialClasses = []) {
  const classes = new Set(initialClasses);
  const listeners = [];
  const attributes = {};
  return {
    classList: {
      add: (name) => classes.add(name),
      remove: (name) => classes.delete(name),
      contains: (name) => classes.has(name),
      toggle(name, force) {
        const enabled = force === undefined ? !classes.has(name) : force;
        if (enabled) classes.add(name);
        else classes.delete(name);
        return enabled;
      }
    },
    addEventListener: (_event, listener) => listeners.push(listener),
    setAttribute: (name, value) => { attributes[name] = value; },
    attributes,
    click: () => listeners.forEach((listener) => listener({ preventDefault() {} }))
  };
}

function page(loggedIn) {
  const elements = {
    hamburger: element(["collapsed"]),
    "navbar-menu": element(["collapse"])
  };
  if (loggedIn) {
    elements.account = element();
    elements["dropdown-menu"] = element();
  }
  const events = {};
  const document = {
    getElementById: (id) => elements[id],
    addEventListener: (event, listener) => { events[event] = listener; }
  };
  vm.runInNewContext(fs.readFileSync(path.join(__dirname, "../../app/javascript/custom/menu.js"), "utf8"), { document });
  return { elements, events };
}

test("mobile navigation opens and closes without an account menu", () => {
  const { elements, events } = page(false);
  events["turbo:load"]();
  elements.hamburger.click();
  assert.equal(elements["navbar-menu"].classList.contains("collapse"), false);
  assert.equal(elements.hamburger.attributes["aria-expanded"], "true");
  elements.hamburger.click();
  assert.equal(elements["navbar-menu"].classList.contains("collapse"), true);
  assert.equal(elements.hamburger.attributes["aria-expanded"], "false");
});

test("repeated Turbo loads do not duplicate account click handlers", () => {
  const { elements, events } = page(true);
  events["turbo:load"]();
  events["turbo:load"]();
  elements.account.click();
  assert.equal(elements["dropdown-menu"].classList.contains("active"), true);
  assert.equal(elements.account.attributes["aria-expanded"], "true");
  elements.account.click();
  assert.equal(elements["dropdown-menu"].classList.contains("active"), false);
});

test("Turbo cache restores closed menus that can be opened again", () => {
  const { elements, events } = page(true);
  events["turbo:load"]();
  elements.account.click();
  elements.hamburger.click();
  events["turbo:before-cache"]();
  assert.equal(elements["dropdown-menu"].classList.contains("active"), false);
  assert.equal(elements["navbar-menu"].classList.contains("collapse"), true);
  assert.equal(elements.account.attributes["aria-expanded"], "false");
  events["turbo:load"]();
  elements.account.click();
  assert.equal(elements["dropdown-menu"].classList.contains("active"), true);
});

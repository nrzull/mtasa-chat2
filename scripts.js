const keyCodes = {
  enter: 13,
  tab: 9,
  pageUp: 33,
  pageDown: 34
};

const state = {
  show: true,
  showInput: false,
  inputMessage: "",
  scroll: false,
  canScrollToBottom: true,
  lastRegisteredDelayCallback: null
};

const say = "say";
const teamsay = "teamsay";

const hexRegex = /#[0-9A-F]{6}/gi;

let elements;

function show(bool) {
  if (!bool) return elements.chat.classList.add("hidden");
  elements.chat.classList.remove("hidden");

  if (bool) {
    elements.input.addEventListener("keydown", preventPressTab);
    document.addEventListener("keydown", onKeydownScrollButton);
    document.addEventListener("keyup", onKeyupScrollButton);
  } else {
    elements.input.removeEventListener("keydown", preventPressTab);
    document.removeEventListener("keydown", onKeydownScrollButton);
    document.removeEventListener("keyup", onKeyupScrollButton);
  }

  scrollToBottom();
}

function showInput([definition]) {
  elements.input.value = "";
  elements.inputLabel.innerText = definition;
  elements.inputBlock.classList.remove("hidden");

  elements.input.style.paddingLeft = `${elements.inputLabel.offsetWidth +
    10}px`;

  setTimeout(() => {
    elements.input.focus();
    document.addEventListener("keydown", onKeydownEnterButton);
  }, 0);
}

function hideInput() {
  elements.inputBlock.classList.add("hidden");
  elements.input.blur();
  remove.addEventListener("keydown", onKeydownEnterButton);
}

function addMessage([message]) {
  render(message);
  scrollToBottom();
}

function scrollToBottom(force = false) {
  if (force) {
    state.canScrollToBottom = true;
    state.lastRegisteredDelayCallback = null;
  }

  if (!state.canScrollToBottom) return;

  elements.chatMessages.scrollTo({
    top: elements.chatMessages.scrollHeight,
    behavior: "smooth"
  });
}

function preventPressTab(e) {
  if (e.keyCode == keyCodes.tab) e.preventDefault();
}

function render(message) {
  const messageElement = document.createElement("div");
  messageElement.classList.add("chat__message");
  const messageFragment = document.createDocumentFragment();

  processTextWithHexCode(message).forEach(({ text, color }) => {
    const partElement = document.createElement("span");
    partElement.innerText = text;
    partElement.style.color = color;
    messageFragment.appendChild(partElement);
  });

  messageElement.append(messageFragment);
  elements.chatMessagesContainer.append(messageElement);
}

function scroll() {
  if (!state.scroll) return;
  const value = state.scroll == keyCodes.pageUp ? -5 : 5;
  elements.chatMessages.scrollBy({ top: value });
  setTimeout(scroll, 25);
}

function clear() {
  elements.chatMessagesContainer.innerHTML = "";
}

function processTextWithHexCode(text) {
  const results = [];
  const hexCodes = text.match(hexRegex);
  const parts = text.split(hexRegex);

  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    if (part === "") continue;
    results.push({ text: part, color: i === 0 ? null : hexCodes[i - 1] });
  }

  return results;
}

function registerDelayCallback() {
  state.canScrollToBottom = false;

  let callback = function() {
    if (!state.lastRegisteredDelayCallback) return;

    if (callback.uniqueId !== state.lastRegisteredDelayCallback.uniqueId) {
      return;
    }

    state.canScrollToBottom = true;
    scrollToBottom();
    state.lastRegisteredDelayCallback = null;
  };
  callback.uniqueId = Date.now();

  state.lastRegisteredDelayCallback = callback;
  setTimeout(callback, 5000);
}

function onKeydownEnterButton(ev) {
  if (ev.keyCode !== keyCodes.enter) return;
  mta.triggerEvent("onChat2EnterButton", elements.input.value);
  scrollToBottom(true);
}

function onKeydownScrollButton(ev) {
  const { keyCode } = ev;
  const { pageUp, pageDown } = keyCodes;

  if (!state.show) return;
  if (keyCode !== pageUp && keyCode !== pageDown) return;
  if (state.scroll) return;

  if (keyCode == pageUp) state.scroll = pageUp;
  else state.scroll = pageDown;

  scroll();
}

function onKeyupScrollButton(ev) {
  const { keyCode } = ev;
  const { pageUp, pageDown } = keyCodes;

  if (!state.show) return;
  if (keyCode !== pageUp && keyCode !== pageDown) return;
  if (!state.scroll) return;

  state.scroll = false;

  const isEndOfScroll =
    elements.chatMessages.scrollHeight -
      elements.chatMessages.scrollTop -
      parseInt(getComputedStyle(elements.chatMessages).height) <=
    1;

  if (isEndOfScroll) {
    state.canScrollToBottom = true;
    state.lastRegisteredDelayCallback = null;
    return;
  }

  registerDelayCallback();
}

function onDOMContentLoaded() {
  elements = {
    chat: document.querySelector(".chat"),
    inputBlock: document.querySelector(".chat__input-block"),
    inputLabel: document.querySelector(".chat__input-label"),
    input: document.querySelector(".chat__input"),
    chatMessages: document.querySelector(".chat__messages"),
    chatMessagesContainer: document.querySelector(".chat__messages-container")
  };

  mta.triggerEvent("onChat2Loaded");
}

document.addEventListener("DOMContentLoaded", onDOMContentLoaded);

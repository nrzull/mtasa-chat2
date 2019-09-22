const keyCodes = {
  enter: 13,
  tab: 9
};

const state = {
  scroll: false,
  canScrollToBottom: true,
  lastRegisteredDelayCallback: null
};

const hexRegex = /#[0-9A-F]{6}/gi;

let elements;

function show(bool) {
  if (!bool) return elements.chat.classList.add("hidden");
  elements.chat.classList.remove("hidden");

  if (bool) {
    elements.input.addEventListener("keydown", preventPressTab);
  } else {
    elements.input.removeEventListener("keydown", preventPressTab);
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
    document.addEventListener("click", onBlur);
  }, 0);
}

function hideInput() {
  elements.inputBlock.classList.add("hidden");
  elements.input.blur();
  document.removeEventListener("keydown", onKeydownEnterButton);
  document.removeEventListener("click", onBlur);
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

// renders message in chat container
function render(message) {
  const messageElement = document.createElement("div");
  messageElement.classList.add("chat__message");
  const messageFragment = document.createDocumentFragment();

  const processedText = processTextWithHexCode(message);
  for (let index = 0; index < processedText.length; index++) {
    const { text, color } = processedText[index];

    const partElement = document.createElement("span");
    partElement.innerText = text;
    partElement.style.color = color;
    messageFragment.appendChild(partElement);
  }

  messageElement.append(messageFragment);
  elements.chatMessagesContainer.append(messageElement);
}

function scroll(definition) {
  if (!state.scroll) return;
  const value = definition == "scrollup" ? -5 : 5;
  elements.chatMessages.scrollBy({ top: value });
  setTimeout(scroll, 25, definition);
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

// responds for automatic scrolling to bottom after some time if user didn't
// scroll manually yet
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

// sends message to clientside
function onKeydownEnterButton(ev) {
  if (ev.keyCode !== keyCodes.enter) return;
  mta.triggerEvent("onChat2EnterButton", elements.input.value);
  scrollToBottom(true);
}

function startScroll([definition]) {
  state.scroll = true;
  scroll(definition);
}

function onBlur() {
  elements.input.focus();
}

function stopScroll() {
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

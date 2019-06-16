function processTextWithHexCode1(text) {
  const result = [];
  const regex = /#[0-9abcdefABCDEF]{6}/;
  const parts = [];
  const sharpPositions = [];

  text.split("").forEach((v, i) => {
    if (v == "#") sharpPositions.push(i);
  });

  if (!sharpPositions.length) {
    result.push({ part: text, color: null });
    return result;
  }

  if (sharpPositions[0] != 0) {
    result.push({ part: text.slice(0, sharpPositions[0]), color: null });
  }

  sharpPositions.forEach((position, i, arr) => {
    const nextPosition = typeof arr[i + 1] == "number" ? arr[i + 1] : undefined;
    parts.push(text.slice(position, nextPosition));
  });

  parts.forEach(part => {
    if (regex.test(part)) {
      result.push({
        part: part.replace(regex, ""),
        color: part.match(regex)[0]
      });
    } else {
      result.push({
        part,
        color: null
      });
    }
  });

  return result;
}

function processTextWithHexCode2(text) {
  const results = [];
  const regex = /#[0-9A-F]{6}/gi;
  const hexCodes = text.match(regex);
  const parts = text.split(regex);

  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    if (part === "") continue;

    results.push({ text: part, color: i === 0 ? null : hexCodes[i - 1] });
  }
  return results;
}

["#abcdefplayerOne", "playerTwo", "damn", "yo bru#ccff00k"].forEach(p => {
  console.log("---");
  console.log(processTextWithHexCode1(p));
  console.log(processTextWithHexCode2(p));
  console.log("---");
});

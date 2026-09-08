import { expect, test } from "@playwright/test";

test.beforeEach(async ({ page }) => {
  await page.addInitScript(() => {
    globalThis.__dragRejections = [];
    addEventListener("unhandledrejection", e => globalThis.__dragRejections.push(String(e.reason)));
  });
});

function diagnosticsFor(page) {
  const diagnostics = [];
  page.on("pageerror", e => diagnostics.push(e.message));
  page.on("console", m => {
    if (["warning", "error"].includes(m.type())) diagnostics.push(m.text());
  });
  return diagnostics;
}

test("trusted drag carries text through dom-ffi and preserves React event control", async ({ page }) => {
  const diagnostics = diagnosticsFor(page);
  await page.goto("/");
  await page.locator("#payload-drag-source").dragTo(page.locator("#payload-drop-target"));
  expect(await page.evaluate(() => ({
    starts: __dragPayload.starts, drops: __dragPayload.drops, parentDrops: __dragPayload.parentDrops,
  }))).toEqual({starts: 1, parentDrops: 0, drops: [{
    text: "MoonBit drag", names: [], present: true, same: true,
    prevented: true, stopped: true, trusted: true,
  }]});
  expect(await page.evaluate(() => __dragRejections)).toEqual([]);
  expect(diagnostics).toEqual([]);
});

test("constructed drops preserve files, nullability, and same-origin realm guards", async ({ page }) => {
  const diagnostics = diagnosticsFor(page);
  await page.goto("/");
  await expect(page.locator("#payload-drop-target")).toHaveCount(1);
  const result = await page.evaluate(() => {
    const target = document.querySelector("#payload-drop-target");
    const transfer = new DataTransfer();
    transfer.setData("text/plain", "two files");
    transfer.items.add(new File(["a"], "one.txt", {type: "text/plain"}));
    transfer.items.add(new File(["bb"], "two.txt", {type: "text/plain"}));
    const prevented = [];
    for (const dataTransfer of [transfer, new DataTransfer(), null]) {
      const event = new DragEvent("drop", {bubbles: true, cancelable: true, dataTransfer});
      target.dispatchEvent(event);
      prevented.push(event.defaultPrevented);
    }
    const probe = __dragPayload.present;
    const rejected = [
      probe(null), probe({}), probe({nativeEvent: new DragEvent("drop", {dataTransfer: transfer})}),
      probe({nativeEvent: {type: "drop", target, dataTransfer: transfer}}),
    ];
    for (const event of [new Event("drop"), new MouseEvent("drop"),
      new DragEvent("click", {dataTransfer: transfer}), new ClipboardEvent("paste", {clipboardData: transfer})]) {
      const detached = document.createElement("div");
      detached.dispatchEvent(event);
      rejected.push(probe({nativeEvent: event}));
    }
    const frame = document.createElement("iframe");
    document.body.appendChild(frame);
    const win = frame.contentWindow;
    const child = win.document.createElement("div");
    win.document.body.appendChild(child);
    const event = new win.DragEvent("drop", {dataTransfer: new win.DataTransfer()});
    child.dispatchEvent(event);
    const iframe = probe({nativeEvent: event});
    const raw = probe(event);
    frame.remove();
    return {prevented, rejected, iframe, raw, drops: __dragPayload.drops, parentDrops: __dragPayload.parentDrops};
  });
  expect(result).toEqual({prevented: [true, true, true], rejected: Array(8).fill(false), iframe: true, raw: true,
    parentDrops: 0, drops: [
      {text: "two files", names: ["one.txt", "two.txt"], present: true, same: true, prevented: true, stopped: true, trusted: false},
      {text: "", names: [], present: true, same: true, prevented: true, stopped: true, trusted: false},
      {text: "", names: [], present: false, same: true, prevented: true, stopped: true, trusted: false},
    ]});
  expect(await page.evaluate(() => __dragRejections)).toEqual([]);
  expect(diagnostics).toEqual([]);
});

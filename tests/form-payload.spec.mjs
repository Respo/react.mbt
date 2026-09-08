import { expect, test } from "@playwright/test";

test("file targets and submitters preserve native identity and React event control", async ({ page }) => {
  const diagnostics = [];
  page.on("pageerror", (error) => diagnostics.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) diagnostics.push(message.text());
  });
  await page.addInitScript(() => {
    globalThis.__payloadRejections = [];
    addEventListener("unhandledrejection", (event) => globalThis.__payloadRejections.push(String(event.reason)));
  });
  await page.goto("/");
  const files = page.locator("#payload-files");
  await expect(files).toHaveCount(1);
  // A real empty file input yields Some(FileList), unlike a non-file input.
  expect(await page.evaluate(() => globalThis.__formPayload.filesPresent({target: document.querySelector("#payload-files")}))).toBe(true);
  await files.setInputFiles({name: "one.txt", mimeType: "text/plain", buffer: Buffer.from("one")});
  await files.setInputFiles([
    {name: "two.txt", mimeType: "text/plain", buffer: Buffer.from("two")},
    {name: "three.txt", mimeType: "text/plain", buffer: Buffer.from("three")},
  ]);
  await files.setInputFiles([]);
  expect(await page.evaluate(() => globalThis.__formPayload.files)).toEqual([
    {names: ["one.txt"], present: true, same: true},
    {names: ["two.txt", "three.txt"], present: true, same: true},
    {names: [], present: true, same: true},
  ]);
  await page.locator("#payload-save").click();
  await page.locator("#payload-preview").click();
  const prevented = await page.evaluate(() => {
    const form = document.querySelector("#payload-form");
    const noSubmitter = new SubmitEvent("submit", {bubbles: true, cancelable: true});
    form.dispatchEvent(noSubmitter);
    const generic = new Event("submit", {bubbles: true, cancelable: true});
    form.dispatchEvent(generic);
    return [noSubmitter.defaultPrevented, generic.defaultPrevented];
  });
  expect(prevented).toEqual([true, true]);
  expect(await page.evaluate(() => globalThis.__formPayload.submits)).toEqual([
    {id: "payload-save", same: true, prevented: true, stopped: true},
    {id: "payload-preview", same: true, prevented: true, stopped: true},
    {id: null, same: true, prevented: true, stopped: true},
    {id: null, same: true, prevented: true, stopped: true},
  ]);
  expect(await page.evaluate(() => globalThis.__payloadRejections)).toEqual([]);
  expect(diagnostics).toEqual([]);
});

test("form payload guards reject imitations and accept same-origin iframe objects", async ({ page }) => {
  const diagnostics = [];
  await page.addInitScript(() => {
    globalThis.__payloadRejections = [];
    addEventListener("unhandledrejection", (event) => globalThis.__payloadRejections.push(String(event.reason)));
  });
  page.on("pageerror", (error) => diagnostics.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) diagnostics.push(message.text());
  });
  await page.goto("/");
  await expect(page.locator("#payload-files")).toHaveCount(1);
  const result = await page.evaluate(() => {
    const probes = globalThis.__formPayload;
    const text = document.createElement("input");
    const form = document.createElement("form");
    const fakeTarget = {type: "file", files: [], ownerDocument: document};
    const fakeSubmit = {type: "submit", submitter: text, target: form};
    const rejected = [
      probes.filesPresent({target: text}),
      probes.filesPresent({target: form}),
      probes.filesPresent({target: fakeTarget}),
      probes.filesPresent({target: null}),
      probes.submitterPresent({nativeEvent: fakeSubmit}),
      probes.submitterPresent({nativeEvent: new MouseEvent("click")}),
      probes.submitterPresent({nativeEvent: new SubmitEvent("submit")}),
    ];
    const frame = document.createElement("iframe");
    document.body.appendChild(frame);
    const doc = frame.contentDocument;
    doc.body.innerHTML = '<form><input type="file"><button>Submit</button></form>';
    const input = doc.querySelector("input");
    const childForm = doc.querySelector("form");
    const button = doc.querySelector("button");
    let submitter = false;
    childForm.addEventListener("submit", (event) => {
      event.preventDefault();
      submitter = probes.submitterPresent({nativeEvent: event});
    });
    childForm.dispatchEvent(new frame.contentWindow.SubmitEvent("submit", {submitter: button, cancelable: true}));
    const files = probes.filesPresent({target: input, currentTarget: childForm});
    frame.remove();
    return {rejected, files, submitter};
  });
  expect(result).toEqual({rejected: Array(7).fill(false), files: true, submitter: true});
  expect(await page.evaluate(() => globalThis.__payloadRejections)).toEqual([]);
  expect(diagnostics).toEqual([]);
});

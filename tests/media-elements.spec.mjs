import { expect, test } from "@playwright/test";

test("generated media helpers load embedded HTML and select responsive image sources", async ({ page }) => {
  const diagnostics = [];
  page.on("pageerror", (error) => diagnostics.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) diagnostics.push(message.text());
  });
  await page.addInitScript(() => {
    globalThis.__mediaRejections = [];
    addEventListener("unhandledrejection", (event) => globalThis.__mediaRejections.push(String(event.reason)));
  });
  await page.goto("/");
  const frame = page.locator("#generated-frame");
  await expect(frame).toHaveAttribute("title", "Embedded fixture");
  await expect(frame).toHaveAttribute("name", "generated-frame");
  await expect(frame).toHaveAttribute("sandbox", "allow-same-origin");
  await expect(frame).toHaveAttribute("allow", "fullscreen");
  await expect(frame).toHaveAttribute("loading", "eager");
  await expect(frame).toHaveAttribute("referrerpolicy", "no-referrer");
  await expect(frame).not.toHaveAttribute("allowfullscreen");
  await expect(frame).toHaveAttribute("width", "240");
  await expect(frame).toHaveAttribute("height", "80");
  await expect(page.frameLocator("#generated-frame").locator("#frame-message")).toHaveText("Embedded ready");
  await expect.poll(() => page.evaluate(() => globalThis.__moonbitGeneratedDomConformance.frameLoads)).toBe(1);

  const canvas = page.locator("#generated-canvas");
  expect(await canvas.evaluate((node) => ({width: node.width, height: node.height, fallback: node.textContent})))
    .toEqual({width: 120, height: 60, fallback: "Canvas fallback"});
  const source = page.locator("#generated-source");
  await expect(source).toHaveAttribute("sizes", "2px");
  await expect(source).toHaveAttribute("type", "image/svg+xml");
  await expect(source).toHaveAttribute("media", "(min-width: 1px)");
  await expect(source).toHaveAttribute("width", "2");
  await expect(source).toHaveAttribute("height", "1");
  expect(await source.evaluate((node) => node.childNodes.length)).toBe(0);
  const img = page.locator("#generated-picture-img");
  await expect.poll(() => img.evaluate((node) => node.complete && node.naturalWidth)).toBe(2);
  const selected = await img.evaluate((node) => node.currentSrc);
  expect(selected).toBe((await source.getAttribute("srcset")).replace(/ 1x$/, ""));
  expect(await page.locator("#generated-picture").evaluate((node) => [...node.children].map((n) => n.tagName)))
    .toEqual(["SOURCE", "IMG"]);
  await expect(page.locator("#generated-description > dt")).toHaveText("Language");
  await expect(page.locator("#generated-description > dd")).toHaveText("MoonBit");
  expect(await page.evaluate(() => globalThis.__mediaRejections)).toEqual([]);
  expect(diagnostics).toEqual([]);
});

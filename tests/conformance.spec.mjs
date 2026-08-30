import { expect, test } from "@playwright/test";

test("React runtime preserves lifecycle, batching, root, and ref semantics", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const observations = () =>
    page.evaluate(() => {
      const current = globalThis.__moonbitReactConformance;
      return {
        renders: current?.renders ?? 0,
        setups: current?.setups ?? 0,
        cleanups: current?.cleanups ?? 0,
        refMounted: current?.ref?.current instanceof HTMLElement,
        refCleared: current?.ref?.current === null,
      };
    });

  await page.goto("/");
  await expect.poll(async () => (await observations()).setups).toBe(2);
  expect(await observations()).toEqual({
    renders: 2,
    setups: 2,
    cleanups: 1,
    refMounted: true,
    refCleared: false,
  });

  await page.locator("#conformance-functional-update").click();
  await expect(page.locator("#conformance-functional-count")).toHaveText("Functional state: 2");
  expect((await observations()).renders).toBe(4);

  await page.locator("#conformance-reducer-dispatch").click();
  await expect(page.locator("#conformance-reducer-count")).toHaveText("Reducer state: 2");
  expect((await observations()).renders).toBe(6);

  await page.locator("#conformance-focus-ref").click();
  await expect(page.locator("#conformance-ref-input")).toBeFocused();

  await page.locator("#conformance-rerender-root").click();
  await expect(page.locator("#conformance-version")).toHaveText("Render version: 1");
  expect(await observations()).toEqual({
    renders: 8,
    setups: 2,
    cleanups: 1,
    refMounted: true,
    refCleared: false,
  });

  await page.locator("#conformance-toggle-root").click();
  await expect(page.locator("#react-conformance-probe")).toHaveCount(0);
  await expect.poll(async () => (await observations()).cleanups).toBe(2);
  expect((await observations()).refCleared).toBe(true);

  await page.locator("#conformance-toggle-root").click();
  await expect(page.locator("#react-conformance-probe")).toBeVisible();
  await expect.poll(async () => (await observations()).setups).toBe(4);
  expect(await observations()).toEqual({
    renders: 10,
    setups: 4,
    cleanups: 3,
    refMounted: true,
    refCleared: false,
  });

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

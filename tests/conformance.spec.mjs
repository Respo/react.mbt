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

test("portals and hydration preserve React tree and existing DOM semantics", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto("/");

  await expect(page.locator("#react-portal-target #portal-event-button")).toBeVisible();
  await page.locator("#portal-event-button").click();
  await expect(page.locator("#portal-event-count")).toHaveText("Portal events: 1");

  await expect(page.locator("#hydration-event-button")).toHaveText("Hydration events: 0");
  expect(
    await page.evaluate(() => {
      const target = document.querySelector("#react-hydration-target");
      return {
        reused:
          globalThis.__moonbitReactRootIntegration?.hydrationNode ===
          target?.firstElementChild,
        recoverableErrors:
          globalThis.__moonbitReactRootIntegration?.errors.hydration.length,
        generatedId: document.querySelector("#hydration-generated-id")?.textContent,
      };
    }),
  ).toEqual({
    reused: true,
    recoverableErrors: 0,
    generatedId: expect.stringContaining("moonbit-hydration-"),
  });
  await page.locator("#hydration-event-button").click();
  await expect(page.locator("#hydration-event-button")).toHaveText("Hydration events: 1");

  await page.locator("#portal-unmount-owner").click();
  await expect(page.locator("#portal-event-button")).toHaveCount(0);
  await expect(page.locator("#portal-react-owner")).toHaveCount(0);

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("root options report caught, uncaught, and recoverable errors exactly once", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const rootErrors = () =>
    page.evaluate(() => globalThis.__moonbitReactRootIntegration?.errors);

  await page.goto("/");
  await page.locator("#run-caught-root-error").click();
  await expect(page.locator("#caught-error-result")).toHaveText("caught fallback");

  await page.locator("#run-uncaught-root-error").click();
  await expect.poll(async () => (await rootErrors()).uncaught.length).toBe(1);

  await page.locator("#run-recoverable-root-error").click();
  await expect(page.locator("#recoverable-error-result")).toHaveText("client value");
  await expect.poll(async () => (await rootErrors()).recoverable.length).toBe(1);

  const errors = await rootErrors();
  expect(errors.hydration).toEqual([]);
  expect(errors.caught).toHaveLength(1);
  expect(errors.caught[0]).toEqual({
    message: "caught root error",
    componentStack: expect.stringContaining("MoonBitCaughtThrower"),
  });
  expect(errors.uncaught).toHaveLength(1);
  expect(errors.uncaught[0]).toEqual({
    message: "uncaught root error",
    componentStack: expect.stringContaining("MoonBitUncaughtThrower"),
  });
  expect(errors.recoverable).toHaveLength(1);
  expect(errors.recoverable[0].message).toContain("Hydration failed");
  expect(errors.recoverable[0].componentStack).toContain("button");

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

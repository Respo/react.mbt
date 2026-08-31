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

test("Web Stream HTML hydrates by reusing DOM with matching identifiers", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto("/");
  await expect(page.locator("#streaming-hydration-button")).toHaveText(
    "Streaming hydration clicks: 0",
  );
  const evidence = await page.evaluate(() => {
    const target = document.querySelector("#react-streaming-hydration-root");
    const state = globalThis.__moonbitStreamingHydration;
    return {
      reused: state?.serverNode === target?.firstElementChild,
      htmlBytes: state?.htmlBytes ?? 0,
      serverErrors: state?.serverErrors ?? [],
      recoverableErrors: state?.recoverableErrors ?? [],
      generatedId: document.querySelector("#streaming-hydration-id")?.textContent,
    };
  });
  expect(evidence).toEqual({
    reused: true,
    htmlBytes: expect.any(Number),
    serverErrors: [],
    recoverableErrors: [],
    generatedId: expect.stringContaining("moonbit-stream-"),
  });
  expect(evidence.htmlBytes).toBeGreaterThan(0);

  await page.locator("#streaming-hydration-button").click();
  await expect(page.locator("#streaming-hydration-button")).toHaveText(
    "Streaming hydration clicks: 1",
  );

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("flushSync is observable before return and resource hints deduplicate", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  const externalRequests = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("request", (request) => {
    const url = new URL(request.url());
    if (!["127.0.0.1", "localhost"].includes(url.hostname)) {
      externalRequests.push(request.url());
    }
  });
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto("/");
  await expect(page.locator("#flush-sync-value")).toHaveText("Flush value: 0");
  await page.locator("#flush-sync-button").click();
  await expect(page.locator("#flush-sync-value")).toHaveText("Flush value: 1");

  const evidence = await page.evaluate(() => {
    const resourceNodes = [...document.head.querySelectorAll("link, script")]
      .filter((node) => {
        const url = node.getAttribute("href") ?? node.getAttribute("src") ?? "";
        return url.includes("resource-hints.invalid") || url.startsWith("data:text/");
      })
      .map((node) => ({
        kind: node.tagName === "SCRIPT" ? "module-script" : node.getAttribute("rel"),
        rel: node.getAttribute("rel") ?? "",
        href: node.getAttribute("href") ?? node.getAttribute("src") ?? "",
        as: node.getAttribute("as") ?? "",
        hasCrossOrigin: node.hasAttribute("crossorigin"),
        crossOrigin: node.getAttribute("crossorigin") ?? "",
        fetchPriority: node.getAttribute("fetchpriority") ?? "",
        precedence: node.getAttribute("data-precedence") ?? "",
        type: node.getAttribute("type") ?? "",
      }))
      .sort((left, right) => left.kind.localeCompare(right.kind));
    return {
      flush: globalThis.__moonbitDomOperations,
      resourceNodes,
    };
  });
  expect(evidence.flush).toEqual({
    flushBefore: "Flush value: 0",
    flushAfter: "Flush value: 1",
  });
  expect(evidence.resourceNodes).toEqual([
    {
      kind: "dns-prefetch",
      rel: "dns-prefetch",
      href: "https://resource-hints.invalid",
      as: "",
      hasCrossOrigin: false,
      crossOrigin: "",
      fetchPriority: "",
      precedence: "",
      type: "",
    },
    {
      kind: "module-script",
      rel: "",
      href: "data:text/javascript,",
      as: "",
      hasCrossOrigin: false,
      crossOrigin: "",
      fetchPriority: "",
      precedence: "",
      type: "module",
    },
    {
      kind: "modulepreload",
      rel: "modulepreload",
      href: "data:text/javascript,export%20default%201",
      as: "",
      hasCrossOrigin: true,
      crossOrigin: "",
      fetchPriority: "",
      precedence: "",
      type: "",
    },
    {
      kind: "preconnect",
      rel: "preconnect",
      href: "https://resource-hints.invalid",
      as: "",
      hasCrossOrigin: true,
      crossOrigin: "",
      fetchPriority: "",
      precedence: "",
      type: "",
    },
    {
      kind: "preload",
      rel: "preload",
      href: "data:text/css,%2Emoonbit-preload%7B%7D",
      as: "style",
      hasCrossOrigin: false,
      crossOrigin: "",
      fetchPriority: "high",
      precedence: "",
      type: "text/css",
    },
    {
      kind: "stylesheet",
      rel: "stylesheet",
      href: "data:text/css,%2Emoonbit-preinit%7B%7D",
      as: "",
      hasCrossOrigin: false,
      crossOrigin: "",
      fetchPriority: "",
      precedence: "low",
      type: "",
    },
  ]);
  expect(externalRequests).toEqual([]);
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

test("React 19.2 Activity hides DOM, cleans Effects, and restores state", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const metrics = () =>
    page.evaluate(() => {
      const current = globalThis.__moonbitReactActivity;
      return {
        renders: current?.renders ?? 0,
        mounts: current?.mounts ?? 0,
        cleanups: current?.cleanups ?? 0,
      };
    });

  await page.goto("/");
  await expect(page.locator("#activity-probe")).toBeVisible();
  await expect(page.locator("#activity-state")).toHaveText("Activity state: 0");
  await expect.poll(async () => (await metrics()).mounts).toBe(1);
  expect(await metrics()).toEqual({ renders: 1, mounts: 1, cleanups: 0 });

  await page.locator("#activity-visible-increment").click();
  await expect(page.locator("#activity-state")).toHaveText("Activity state: 1");

  await page.locator("#activity-hide").click();
  await expect(page.locator("#activity-probe")).toBeHidden();
  await expect(page.locator("#activity-probe")).toHaveCount(1);
  await expect.poll(async () => (await metrics()).cleanups).toBe(1);
  expect(
    await page.locator("#activity-probe").evaluate((node) => getComputedStyle(node).display),
  ).toBe("none");

  await page.locator("#activity-hidden-increment").click();
  await page.locator("#activity-show").click();
  await expect(page.locator("#activity-probe")).toBeVisible();
  await expect(page.locator("#activity-state")).toHaveText("Activity state: 2");
  await expect.poll(async () => (await metrics()).mounts).toBe(2);
  expect((await metrics()).cleanups).toBe(1);

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("cached resources suspend and reveal their fulfilled value", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const metrics = () =>
    page.evaluate(() => ({ ...globalThis.__moonbitReactResources?.metrics }));

  await page.goto("/");
  await expect(page.locator("#resource-success-pending")).toHaveText("Success pending");
  await expect(page.locator("#resource-failure-pending")).toHaveText("Failure pending");
  expect(await metrics()).toEqual({
    resolves: 0,
    rejects: 0,
    localErrors: 0,
    rootCaughtErrors: 0,
    fallbackRenders: 0,
    retries: 0,
  });

  await page.locator("#resource-resolve-success").click();
  await expect(page.locator("#resource-success-value")).toHaveText(
    "Success: resolved value",
  );
  await expect(page.locator("#resource-success-pending")).toHaveCount(0);
  expect(await metrics()).toEqual({
    resolves: 1,
    rejects: 0,
    localErrors: 0,
    rootCaughtErrors: 0,
    fallbackRenders: 0,
    retries: 0,
  });

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("rejected resources render locally and recover through a reset key", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const metrics = () =>
    page.evaluate(() => ({ ...globalThis.__moonbitReactResources?.metrics }));

  await page.goto("/");
  await expect(page.locator("#resource-failure-pending")).toHaveText("Failure pending");

  await page.locator("#resource-reject-failure").click();
  await expect(page.locator("#resource-error-fallback")).toHaveText(
    "Resource error: resource rejected",
  );
  await expect.poll(async () => (await metrics()).localErrors).toBe(1);
  await expect.poll(async () => (await metrics()).rootCaughtErrors).toBe(1);
  expect(await metrics()).toEqual({
    resolves: 0,
    rejects: 1,
    localErrors: 1,
    rootCaughtErrors: 1,
    fallbackRenders: 2,
    retries: 0,
  });

  await page.locator("#resource-retry").click();
  await expect(page.locator("#resource-retry-value")).toHaveText(
    "Retry: recovered value",
  );
  await expect(page.locator("#resource-error-fallback")).toHaveCount(0);
  expect(await metrics()).toEqual({
    resolves: 0,
    rejects: 1,
    localErrors: 1,
    rootCaughtErrors: 1,
    fallbackRenders: 2,
    retries: 1,
  });

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("external store commits each changed snapshot and unsubscribes exactly once", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const storeMetrics = () =>
    page.evaluate(() => ({ ...globalThis.__moonbitStoreComponentConformance?.store }));

  await page.goto("/");
  await expect(page.locator("#external-store-snapshot")).toHaveText("Store snapshot: 0");
  await expect.poll(async () => (await storeMetrics()).subscribes).toBe(1);
  expect(await storeMetrics()).toEqual({
    publications: 0,
    deliveries: 0,
    subscribes: 1,
    unsubscribes: 0,
    renders: 1,
    committedSnapshots: [0],
  });

  await page.locator("#external-store-publish-one").click();
  await expect(page.locator("#external-store-snapshot")).toHaveText("Store snapshot: 1");
  expect(await storeMetrics()).toMatchObject({
    publications: 1,
    deliveries: 1,
    renders: 2,
    committedSnapshots: [0, 1],
  });

  await page.locator("#external-store-publish-same").click();
  await page.evaluate(() => new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve))));
  expect(await storeMetrics()).toMatchObject({
    publications: 2,
    deliveries: 2,
    renders: 2,
    committedSnapshots: [0, 1],
  });

  await page.locator("#external-store-publish-two").click();
  await expect(page.locator("#external-store-snapshot")).toHaveText("Store snapshot: 2");
  expect(await storeMetrics()).toMatchObject({
    publications: 3,
    deliveries: 3,
    renders: 3,
    committedSnapshots: [0, 1, 2],
  });

  await page.locator("#external-store-unmount").click();
  await expect(page.locator("#external-store-snapshot")).toHaveCount(0);
  await expect.poll(async () => (await storeMetrics()).unsubscribes).toBe(1);
  await page.locator("#external-store-publish-after-unmount").click();
  expect(await storeMetrics()).toEqual({
    publications: 4,
    deliveries: 3,
    subscribes: 1,
    unsubscribes: 1,
    renders: 3,
    committedSnapshots: [0, 1, 2],
  });

  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("typed memo lazy JS interop and imperative handles follow React 19 semantics", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  const componentMetrics = () =>
    page.evaluate(() => ({
      ...globalThis.__moonbitStoreComponentConformance?.components,
    }));

  await page.goto("/");
  await expect(page.locator("#memo-component-value")).toHaveText("Memo component: stable");
  await expect(page.locator("#js-component-value")).toHaveText("JS component: stable");
  await expect(page.locator("#lazy-component-fallback")).toHaveText("Lazy loading");
  await expect.poll(async () => (await componentMetrics()).lazyLoads).toBe(1);
  expect(await componentMetrics()).toMatchObject({
    memoRenders: 1,
    lazyLoads: 1,
    lazyRenders: 0,
    jsRenders: 1,
  });

  await page.locator("#component-unrelated-update").click();
  await expect(page.locator("#component-unrelated-value")).toHaveText("Unrelated: 1");
  expect(await componentMetrics()).toMatchObject({ memoRenders: 1, jsRenders: 2 });

  await page.locator("#component-change-label").click();
  await expect(page.locator("#memo-component-value")).toHaveText("Memo component: changed");
  await expect(page.locator("#js-component-value")).toHaveText("JS component: changed");
  expect(await componentMetrics()).toMatchObject({ memoRenders: 2, jsRenders: 3 });

  await page.locator("#component-resolve-lazy").click();
  await expect(page.locator("#lazy-component-value")).toHaveText("Lazy component: changed");
  expect(await componentMetrics()).toMatchObject({
    memoRenders: 2,
    lazyLoads: 1,
    lazyRenders: 1,
    jsRenders: 3,
  });

  await page.locator("#component-toggle-lazy").click();
  await expect(page.locator("#lazy-component-hidden")).toBeVisible();
  await page.locator("#component-toggle-lazy").click();
  await expect(page.locator("#lazy-component-value")).toHaveText("Lazy component: changed");
  expect((await componentMetrics()).lazyLoads).toBe(1);

  await page.locator("#component-read-handle").click();
  await expect(page.locator("#imperative-handle-status")).toHaveText("Handle: ready handle");
  await page.locator("#component-toggle-imperative").click();
  await expect(page.locator("#imperative-component-value")).toHaveCount(0);
  await page.locator("#component-read-handle").click();
  await expect(page.locator("#imperative-handle-status")).toHaveText("Handle: none");

  expect((await componentMetrics()).markerMatches.every(Boolean)).toBe(true);
  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

test("generated HTML SVG metadata and escape-hatch props match the browser DOM", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto("/");

  const table = page.locator("#generated-table");
  await expect(table).toHaveAttribute("aria-label", "Generated scores");
  await expect(table).toHaveAttribute("data-testid", "generated-table");
  await expect(table.locator("th")).toHaveAttribute("scope", "col");
  await expect(table.locator("th")).toHaveAttribute("colspan", "2");
  await expect(table.locator("tbody td")).toHaveCount(2);

  const fieldset = page.locator("#generated-fieldset");
  await expect(fieldset).not.toBeDisabled();
  await expect(page.locator("#generated-progress")).toHaveAttribute("value", "3.5");
  await expect(page.locator("#generated-progress")).toHaveAttribute("max", "5");

  const dialog = page.locator("#generated-dialog");
  await expect(dialog).not.toHaveAttribute("open", "");
  await dialog.dispatchEvent("cancel");
  await dialog.dispatchEvent("close");

  const svg = page.locator("#generated-svg");
  await expect(svg).toHaveAttribute("viewBox", "0 0 24 24");
  await expect(svg).toHaveAttribute("aria-label", "Generated status icon");
  await expect(page.locator("#generated-path")).toHaveAttribute("stroke-width", "2");
  await expect(page.locator("#generated-path")).toHaveAttribute("pathLength", "20");
  await expect(page.locator("#generated-use")).toHaveAttribute("href", "#generated-path");
  expect(await svg.evaluate((node) => node.namespaceURI)).toBe("http://www.w3.org/2000/svg");

  const metadata = page.locator('head meta[name="react-mbt-generated-helper"]');
  await expect(metadata).toHaveAttribute("content", "metadata-ready");

  const custom = page.locator("moonbit-widget");
  await expect(custom).toHaveAttribute("aria-live", "polite");
  await expect(custom).toHaveAttribute("data-state", "ready");
  await expect(custom).toHaveAttribute("customvalue", "opaque");

  expect(await page.evaluate(() => globalThis.__moonbitGeneratedDomConformance)).toEqual({
    renders: 1,
    cancels: 1,
    closes: 1,
  });
  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
});

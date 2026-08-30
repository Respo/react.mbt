import { expect, test } from "@playwright/test";

test("TodoMVC supports editing, creating, filtering, and clearing todos", async ({ page }) => {
  const pageErrors = [];
  const consoleProblems = [];
  await page.addInitScript(() => {
    globalThis.__unhandledRejections = [];
    globalThis.addEventListener("unhandledrejection", (event) => {
      globalThis.__unhandledRejections.push(String(event.reason));
    });
  });
  page.on("pageerror", (error) => pageErrors.push(error.message));
  page.on("console", (message) => {
    if (["warning", "error"].includes(message.type())) {
      consoleProblems.push(`${message.type()}: ${message.text()}`);
    }
  });

  await page.goto("/");
  await expect(page.locator(".todo-list li")).toHaveCount(3);
  await expect(page.locator(".todo-count")).toHaveText("2 items left");
  await expect(page.getByText("无 Provider: 默认值", { exact: true })).toBeVisible();
  await expect(page.getByText("外层 Provider: 外层值", { exact: true })).toBeVisible();
  await expect(page.getByText("内层 Provider: 内层值", { exact: true })).toBeVisible();
  await expect(page.getByText("恢复外层: 外层值", { exact: true })).toBeVisible();

  await expect(page.locator("#form-action-canonical")).toHaveText("已保存: baseline");
  await expect(page.locator("#form-action-optimistic")).toHaveText("乐观值: baseline");
  await expect(page.locator("#form-action-result")).toHaveText(
    "Action 结果: idle, calls=0, pending=false",
  );
  await expect(page.locator("#form-action-status")).toHaveText(
    "Form 状态: pending=false, method=get, submitted=",
  );

  const actionInput = page.locator("#form-action-input");
  await actionInput.fill("accepted");
  await page.getByRole("button", { name: "提交 Action", exact: true }).click();
  await expect(page.locator("#form-action-status")).toHaveText(
    "Form 状态: pending=true, method=get, submitted=accepted",
  );
  await expect(page.locator("#form-action-optimistic")).toHaveText("乐观值: accepted");
  await expect(page.locator("#form-action-result")).toHaveText(
    "Action 结果: idle, calls=0, pending=true",
  );
  await page.getByRole("button", { name: "完成成功", exact: true }).click();
  await expect(page.locator("#form-action-result")).toHaveText(
    "Action 结果: saved, calls=1, pending=false",
  );
  await expect(page.locator("#form-action-canonical")).toHaveText("已保存: accepted");
  await expect(page.locator("#form-action-optimistic")).toHaveText("乐观值: accepted");

  await actionInput.fill("rejected");
  await page.getByRole("button", { name: "提交 Action", exact: true }).click();
  await expect(page.locator("#form-action-status")).toHaveText(
    "Form 状态: pending=true, method=get, submitted=rejected",
  );
  await expect(page.locator("#form-action-optimistic")).toHaveText("乐观值: rejected");
  await page.getByRole("button", { name: "完成失败", exact: true }).click();
  await expect(page.locator("#form-action-result")).toHaveText(
    "Action 结果: rejected, calls=2, pending=false",
  );
  await expect(page.locator("#form-action-canonical")).toHaveText("已保存: accepted");
  await expect(page.locator("#form-action-optimistic")).toHaveText("乐观值: accepted");

  await page.getByRole("button", { name: "检查 DOM ref", exact: true }).click();
  await expect(page.locator("#dom-ref-status")).toHaveText("DOM ref 状态: 已挂载");
  await expect(page.locator("#controlled-readonly-input")).toHaveValue("只读受控值");
  await expect(page.locator("#uncontrolled-default-input")).toHaveValue("非受控初始值");
  await expect(page.locator("#uncontrolled-multiple-select")).toHaveValues(["alpha", "gamma"]);
  await page.getByRole("button", { name: "聚焦 DOM ref", exact: true }).click();
  await expect(page.locator("#dom-ref-target")).toBeFocused();
  await page.getByRole("button", { name: "卸载 DOM ref", exact: true }).click();
  await expect(page.locator("#dom-ref-target")).toHaveCount(0);
  await page.getByRole("button", { name: "检查 DOM ref", exact: true }).click();
  await expect(page.locator("#dom-ref-status")).toHaveText("DOM ref 状态: 空");

  await page.getByRole("button", { name: "执行状态操作", exact: true }).click();
  await expect(page.getByText("操作状态: 操作已完成（进行中: false）", { exact: true })).toBeVisible();
  await page.getByRole("button", { name: "启动定时器", exact: true }).click();
  await expect(page.getByText("消息: 定时器已更新到: 1", { exact: true })).toBeVisible();

  await page.getByText("学习 MoonBit", { exact: true }).dblclick();
  const editor = page.locator(".todo-list .edit");
  await expect(editor).toBeVisible();
  await editor.fill("学习 MoonBit（已更新）");
  await editor.press("Enter");
  await expect(page.getByText("学习 MoonBit（已更新）", { exact: true })).toBeVisible();

  const newTodo = page.locator(".new-todo");
  await newTodo.fill("Ship browser regression");
  await newTodo.press("Enter");
  const addedTodo = page.locator(".todo-list li", { hasText: "Ship browser regression" });
  await expect(addedTodo).toBeVisible();
  const toggleAll = page.locator(".toggle-all");
  await toggleAll.check();
  await expect(page.locator(".todo-count")).toHaveText("0 items left");
  await toggleAll.uncheck();
  await expect(page.locator(".todo-count")).toHaveText("4 items left");
  await addedTodo.locator(".toggle").check();
  await expect(page.locator(".todo-count")).toHaveText("3 items left");

  await page.getByRole("link", { name: "Completed", exact: true }).click();
  await expect(page.locator(".todo-list li")).toHaveCount(1);
  await page.getByRole("button", { name: "Clear completed", exact: true }).click();
  await expect(page.locator(".todo-list li")).toHaveCount(0);

  await page.getByRole("link", { name: "All", exact: true }).click();
  await expect(page.locator(".todo-list li")).toHaveCount(3);
  expect(pageErrors).toEqual([]);
  expect(consoleProblems).toEqual([]);
  expect(await page.evaluate(() => globalThis.__unhandledRejections)).toEqual([]);
});

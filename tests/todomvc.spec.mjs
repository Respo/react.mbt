import { expect, test } from "@playwright/test";

test("TodoMVC supports editing, creating, filtering, and clearing todos", async ({ page }) => {
  const pageErrors = [];
  page.on("pageerror", (error) => pageErrors.push(error.message));

  await page.goto("/");
  await expect(page.locator(".todo-list li")).toHaveCount(3);
  await expect(page.locator(".todo-count")).toHaveText("2 items left");

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
});

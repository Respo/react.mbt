# Project Agents.md Guide

This is a [MoonBit](https://docs.moonbitlang.com) project.

## Project Structure

- MoonBit packages are organized per directory, for each directory, there is a
  `moon.pkg.json` file listing its dependencies. Each package has its files and
  blackbox test files (common, ending in `_test.mbt`) and whitebox test files
  (ending in `_wbtest.mbt`).

- In the toplevel directory, this is a `moon.mod.json` file listing about the
  module and some meta information.

## Coding convention

- MoonBit code is organized in block style, each block is separated by `///|`,
  the order of each block is irrelevant. In some refactorings, you can process
  block by block independently.

- Try to keep deprecated blocks in file called `deprecated.mbt` in each
  directory.

## Preact Component Usage

When using Preact components in this project, there are specific patterns that must be followed:

### Component Function Wrapping

**Important**: All component functions must be wrapped with the `component` function when used in the virtual DOM tree.

**Correct usage:**
```moonbit
// When using a component function, wrap it with component()
component(comp_todolist, TodoListProps::default(), [])
```

**Incorrect usage:**
```moonbit
// DON'T call component functions directly
comp_todolist(TodoListProps::default())
```

### Component Function Definition

Component functions should follow this pattern:
```moonbit
fn comp_component_name(props : ComponentProps) -> VirtualNode {
  // Component implementation
  @preact.div([...])
}
```

### Example from main.mbt

See `/Users/chenyong/repo/respo/preact.mbt/src/main/main.mbt#L37-38` for a correct example:
```moonbit
component(comp_todolist, TodoListProps::default(), [])
```

This pattern ensures proper component lifecycle management and integration with the Preact rendering system.

## Tooling

- `moon fmt` is used to format your code properly.

- `moon info` is used to update the generated interface of the package, each
  package has a generated interface file `.mbti`, it is a brief formal
  description of the package. If nothing in `.mbti` changes, this means your
  change does not bring the visible changes to the external package users, it is
  typically a safe refactoring.

- In the last step, run `moon info && moon fmt` to update the interface and
  format the code. Check the diffs of `.mbti` file to see if the changes are
  expected.

- Run `moon test` to check the test is passed. MoonBit supports snapshot
  testing, so when your changes indeed change the behavior of the code, you
  should run `moon test --update` to update the snapshot.

- You can run `moon check` to check the code is linted correctly.

- When writing tests, you are encouraged to use `inspect` and run
  `moon test --update` to update the snapshots, only use assertions like
  `assert_eq` when you are in some loops where each snapshot may vary. You can
  use `moon coverage analyze > uncovered.log` to see which parts of your code
  are not covered by tests.

- agent-todo.md has some small tasks that are easy for AI to pick up, agent is
  welcome to finish the tasks and check the box when you are done

import assert from "node:assert/strict";
import test from "node:test";
import {
  hasResolvedPackageVersion,
  isExactSemVer,
  resolvedPackageVersions,
} from "./release-verification.mjs";

test("accepts exact Semantic Versioning 2.0.0 versions", () => {
  for (const version of [
    "0.0.0",
    "1.2.3",
    "1.0.0-alpha",
    "1.0.0-alpha.1",
    "1.0.0-x.7.z.92",
    "1.0.0+build.5",
    "1.0.0-rc.1+build.5",
  ]) {
    assert.equal(isExactSemVer(version), true, version);
  }
});

test("rejects malformed or non-exact semantic versions", () => {
  for (const version of [
    "01.2.3",
    "1.02.3",
    "1.2.03",
    "0.4.0-01",
    "1.2.3-foo..bar",
    "1.2",
    "v1.2.3",
    "latest",
    "",
  ]) {
    assert.equal(isExactSemVer(version), false, version);
  }
});

test("extracts complete resolved package version tokens", () => {
  const tree = `release-check/react-downstream@0.0.0:
├─ tiye/react -> tiye/react@0.4.0
├─ tiye/dom-ffi -> tiye/dom-ffi@0.4.0-rc.1
└─ example/tiye-dom-ffi -> example/tiye-dom-ffi@0.4.0`;

  assert.deepEqual(resolvedPackageVersions(tree, "tiye/dom-ffi"), [
    "0.4.0-rc.1",
  ]);
  assert.equal(hasResolvedPackageVersion(tree, "tiye/dom-ffi", "0.4.0"), false);
  assert.equal(
    hasResolvedPackageVersion(tree, "tiye/dom-ffi", "0.4.0-rc.1"),
    true,
  );
});

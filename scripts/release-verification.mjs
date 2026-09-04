const exactSemVerPattern =
  /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9]\d*|\d*[A-Za-z-][0-9A-Za-z-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/;

export function isExactSemVer(version) {
  return typeof version === "string" && exactSemVerPattern.test(version);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export function resolvedPackageVersions(tree, packageName) {
  const packageEntryPattern = new RegExp(
    `(?:^|\\s)${escapeRegExp(packageName)}@([^\\s()]+)`,
    "gm",
  );
  return [...tree.matchAll(packageEntryPattern)].map((match) => match[1]);
}

export function hasResolvedPackageVersion(tree, packageName, version) {
  return resolvedPackageVersions(tree, packageName).includes(version);
}

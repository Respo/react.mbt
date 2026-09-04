import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { isExactSemVer } from "./release-verification.mjs";

function fail(message) {
  console.error(`release metadata check failed: ${message}`);
  process.exit(1);
}

const moonMod = readFileSync("moon.mod", "utf8");
const packageJson = JSON.parse(readFileSync("package.json", "utf8"));
const releaseTags = JSON.parse(readFileSync("release-tags.json", "utf8"));
const changelog = readFileSync("CHANGELOG.md", "utf8");
const moonVersions = [...moonMod.matchAll(/^version = "([^"]+)"$/gm)].map(
  (match) => match[1],
);
const domFfiVersions = [
  ...moonMod.matchAll(/^\s*"tiye\/dom-ffi@([^"]+)",?$/gm),
].map((match) => match[1]);

if (moonVersions.length !== 1) {
  fail(`expected one moon.mod version, found ${moonVersions.length}`);
}

const version = moonVersions[0];
if (!isExactSemVer(version)) {
  fail(`moon.mod version is not semantic: ${version}`);
}
if (domFfiVersions.length !== 1) {
  fail(`expected one tiye/dom-ffi dependency, found ${domFfiVersions.length}`);
}
const domFfiVersion = domFfiVersions[0];
if (!isExactSemVer(domFfiVersion)) {
  fail(`tiye/dom-ffi dependency is not an exact semantic version: ${domFfiVersion}`);
}
if (packageJson.version !== version) {
  fail(`package.json ${packageJson.version} != moon.mod ${version}`);
}

const sections = [...changelog.matchAll(/^## (.+)$/gm)];
const headings = sections.map((match) => match[1]);
const unreleasedIndex = headings.indexOf("Unreleased");
if (unreleasedIndex !== 0) {
  fail("CHANGELOG.md must start with an Unreleased section");
}

const unreleasedStart = sections[0].index + sections[0][0].length;
const unreleasedEnd = sections[1]?.index ?? changelog.length;
const unreleasedBody = changelog.slice(unreleasedStart, unreleasedEnd).trim();
const unreleasedEntries = [...unreleasedBody.matchAll(/^- /gm)].length;
if (process.env.RELEASE_TAG && unreleasedBody !== "") {
  fail("Unreleased must be empty when preparing a release");
}

const releaseHeadings = headings.slice(1).map((heading) => {
  const match = heading.match(/^(\S+) - (\d{4}-\d{2}-\d{2})$/);
  if (!match || !isExactSemVer(match[1])) {
    fail(`invalid release heading: ${heading}`);
  }
  return { version: match[1], date: match[2] };
});

const headingVersions = releaseHeadings.map((entry) => entry.version);
if (new Set(headingVersions).size !== headingVersions.length) {
  fail("CHANGELOG.md contains duplicate release versions");
}
if (!headingVersions.includes(version)) {
  fail(`CHANGELOG.md has no dated ${version} section`);
}

if (!Array.isArray(releaseTags) || releaseTags.length === 0) {
  fail("release-tags.json must contain the public historical tags");
}
if (new Set(releaseTags).size !== releaseTags.length) {
  fail("release-tags.json contains duplicate tags");
}

const taggedVersions = releaseTags.map((tag) => {
  const tagVersion = tag.replace(/^v/, "");
  if (!isExactSemVer(tagVersion)) {
    fail(`release-tags.json contains an invalid tag: ${tag}`);
  }
  return tagVersion;
});
const expectedVersions = new Set([...taggedVersions, version]);
const missingVersions = [...expectedVersions].filter(
  (expected) => !headingVersions.includes(expected),
);
if (missingVersions.length > 0) {
  fail(`CHANGELOG.md is missing tagged versions: ${missingVersions.join(", ")}`);
}

const unexpectedVersions = headingVersions.filter(
  (headingVersion) => !expectedVersions.has(headingVersion),
);
if (unexpectedVersions.length > 0) {
  fail(`CHANGELOG.md has untagged versions: ${unexpectedVersions.join(", ")}`);
}

if (process.env.VERIFY_GIT_TAGS === "1") {
  const publicTags = [
    ...new Set(
      execFileSync("git", ["ls-remote", "--tags", "origin"], {
        encoding: "utf8",
      })
        .trim()
        .split("\n")
        .filter(Boolean)
        .map((line) => line.split("\t")[1]?.replace(/^refs\/tags\//, ""))
        .filter(Boolean)
        .map((tag) => tag.replace(/\^\{\}$/, ""))
        .filter((tag) => isExactSemVer(tag.replace(/^v/, ""))),
    ),
  ];
  const missingPublicTags = releaseTags.filter(
    (tag) => !publicTags.includes(tag),
  );
  const unexpectedPublicTags = publicTags.filter(
    (tag) => !releaseTags.includes(tag) && tag !== `v${version}`,
  );
  if (missingPublicTags.length > 0 || unexpectedPublicTags.length > 0) {
    fail(
      `release-tags.json differs from origin: missing=[${missingPublicTags.join(", ")}] unexpected=[${unexpectedPublicTags.join(", ")}]`,
    );
  }
}

const releaseTag = process.env.RELEASE_TAG;
if (releaseTag && releaseTag !== `v${version}`) {
  fail(`RELEASE_TAG ${releaseTag} != v${version}`);
}

const releaseNotes = readFileSync(`release-notes/v${version}.md`, "utf8");
if (!releaseNotes.includes("## 中文") || !releaseNotes.includes("## English")) {
  fail(`release-notes/v${version}.md must contain separate Chinese and English sections`);
}

console.log(
  JSON.stringify(
    {
      version,
      domFfiVersion,
      releaseTag: `v${version}`,
      metadataVersionsMatched: 2,
      changelogReleaseSections: releaseHeadings.length,
      historicalTagsCovered: taggedVersions.length,
      publicTagManifestChecked: process.env.VERIFY_GIT_TAGS === "1",
      unreleasedEntries,
      bilingualReleaseNotes: true,
    },
    null,
    2,
  ),
);

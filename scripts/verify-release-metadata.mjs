import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";

const semverPattern = /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/;

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

if (moonVersions.length !== 1) {
  fail(`expected one moon.mod version, found ${moonVersions.length}`);
}

const version = moonVersions[0];
if (!semverPattern.test(version)) {
  fail(`moon.mod version is not semantic: ${version}`);
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
if (changelog.slice(unreleasedStart, unreleasedEnd).trim() !== "") {
  fail("Unreleased must be empty when preparing a release");
}

const releaseHeadings = headings.slice(1).map((heading) => {
  const match = heading.match(
    /^(\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?) - (\d{4}-\d{2}-\d{2})$/,
  );
  if (!match) {
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
  if (!semverPattern.test(tagVersion)) {
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
  const checkoutTags = execFileSync("git", ["tag", "--list"], {
    encoding: "utf8",
  })
    .trim()
    .split("\n")
    .filter(Boolean)
    .filter((tag) => semverPattern.test(tag.replace(/^v/, "")));
  const missingCheckoutTags = releaseTags.filter(
    (tag) => !checkoutTags.includes(tag),
  );
  const unexpectedCheckoutTags = checkoutTags.filter(
    (tag) => !releaseTags.includes(tag) && tag !== `v${version}`,
  );
  if (missingCheckoutTags.length > 0 || unexpectedCheckoutTags.length > 0) {
    fail(
      `release-tags.json differs from checkout: missing=[${missingCheckoutTags.join(", ")}] unexpected=[${unexpectedCheckoutTags.join(", ")}]`,
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
      releaseTag: `v${version}`,
      metadataVersionsMatched: 2,
      changelogReleaseSections: releaseHeadings.length,
      historicalTagsCovered: taggedVersions.length,
      publicTagManifestChecked: process.env.VERIFY_GIT_TAGS === "1",
      unreleasedEntries: 0,
      bilingualReleaseNotes: true,
    },
    null,
    2,
  ),
);

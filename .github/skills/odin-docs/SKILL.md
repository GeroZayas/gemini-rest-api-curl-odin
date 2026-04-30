---
name: odin-docs
description: 'Use for Odin language questions, official docs lookup, pkg.odin-lang.org package docs, overview semantics, demo file examples, official examples repo lookup, nightly builds, release notes, and recent Odin online examples.'
argument-hint: 'Topic, library, or Odin feature to research'
user-invocable: true
disable-model-invocation: false
---

# Odin Docs Research

## When to Use
- Research the most recent Odin language documentation
- Look up Odin standard library APIs or third-party packages
- Find current online examples, patterns, or reference implementations
- Check release notes, changelogs, or version-specific behavior
- Resolve whether a question should be answered from the overview, package site, demo file, examples repo, or nightly/news pages

## Source Routing
Use the most accurate source for the question before broadening the search.

| Question type | Primary source | Secondary source |
|---|---|---|
| Language syntax, semantics, operators, directives, idioms | [Official resources](./references/official-resources.md) | [Context7 setup](./references/context7.md) |
| Official package APIs in `base`, `core`, or `vendor` | [Official resources](./references/official-resources.md) | package source or tests |
| Worked examples for language features | [Demo topic index](./references/demo-topic-index.md) | [Demo resource](./references/demo-resource.md) |
| Idiomatic project examples and library usage | [Official examples](./references/official-examples.md) | package docs |
| Version drift, recent changes, nightlies, release tracking | [Release tracking](./references/release-tracking.md) | GitHub tagged releases |
| Missing or ambiguous documentation | [Demo topic index](./references/demo-topic-index.md) | source, tests, issue tracker |

## Workflow
1. Identify the exact Odin topic, API, package, or language feature.
2. Route the question to the most accurate source using the table above.
3. Prefer official sources first: Odin language docs, overview pages, package docs, examples pages, nightly pages, news pages, and official repositories.
4. If Context7 is available, prefer the Odin documentation source identified in [Context7 setup](./references/context7.md) for docs-style queries.
5. Verify the current version or date when the documentation matters for behavior.
6. Cross-check with recent official examples before using community examples.
7. If sources disagree, prefer the newest official documentation or release-tracking page and note the conflict.
8. If the official docs are thin, consult the [Demo topic index](./references/demo-topic-index.md) to jump to the relevant demo section before scanning the bundled file.
9. If the indexed demo section is still insufficient, inspect the bundled example corpus in [demo resource](./references/demo-resource.md) and then the official examples repository.
10. Summarize the result with practical guidance, version caveats, and a minimal example when useful.

## Source Priority
1. [Official resources](./references/official-resources.md)
2. [Context7 setup](./references/context7.md)
3. [Demo topic index](./references/demo-topic-index.md)
4. [Demo resource](./references/demo-resource.md)
5. [Official examples](./references/official-examples.md)
6. [Release tracking](./references/release-tracking.md)

## Research Rules
- Prefer current official documentation over outdated blog posts or stale examples.
- Treat examples as reference material, not proof of API stability.
- Call out deprecations, breaking changes, and version-sensitive behavior explicitly.
- If a package has multiple docs sources, compare them against the package source or recent releases.
- When the docs are unclear, inspect source code or issue trackers for the latest behavior.
- Prefer the package site for `base`, `core`, and `vendor` APIs before using general web search.
- Use the demo topic index to choose the right demo section before reading the full file.
- Use the bundled `demo.odin` file as a feature index and example bank for language constructs that are missing or abbreviated in the web docs.
- Prefer official examples over community examples when demonstrating idiomatic usage.
- Use nightly and news pages to anchor answers about recency instead of guessing from older docs.

## Output Expectations
- State the doc source and version or date when available.
- Distinguish language features, stdlib APIs, and third-party packages.
- Provide concise code snippets only when they clarify usage.
- Mention any assumptions needed if the answer depends on the installed Odin version.
- If the answer relies on nightly or article material, state that explicitly.

## Good Prompts
- "Use the Odin docs skill to check how `[...]` works in the latest release."
- "Research the current Odin stdlib API for `[...]` and include a recent example."
- "Find the newest documentation and examples for the Odin package `[...]`."
- "Use the local demo resource plus official docs to explain the Odin feature `[...]`."
- "Check whether `[...]` changed recently using Odin nightly builds or news pages."
- "Find an official idiomatic example for `[...]` from Odin docs or the examples repository."
- "Use the demo topic index to jump to the right section for `[...]` and summarize the example."
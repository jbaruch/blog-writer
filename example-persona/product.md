# Product Source Index: Tessl

This file maps Tessl product topics to their authoritative sources. During Phase 0,
identify which topics the post covers and use WebFetch to pull the relevant pages
directly. Don't fetch everything, but don't ration either — the context window can
handle it. The goal is accurate product claims, not minimal token usage.

## Docs Site: docs.tessl.io

The docs are the source of truth for how the product works today. Fetch specific pages
by topic — never crawl the whole site.

### Core Concepts
- What is Tessl: https://docs.tessl.io
- Concepts & terminology: https://docs.tessl.io/introduction-to-tessl/concepts
- Context Lifecycle: https://docs.tessl.io/introduction-to-tessl/context-lifecycle
- Glossary: https://docs.tessl.io/reference/glossary

### Getting Started
- Quick start (skills, docs, rules): https://docs.tessl.io/introduction-to-tessl/quickstart-skills-docs-rules
- Installation: https://docs.tessl.io/introduction-to-tessl/installation
- Quick start (Tessl Framework): https://docs.tessl.io/introduction-to-tessl/quick-start-guide-tessl-framework

### Using Tessl
- Skills: https://docs.tessl.io/use/enhance-your-workflow-with-skills
- Documentation tiles: https://docs.tessl.io/use/make-your-agents-smarter-with-documentation
- Spec-Driven Development: https://docs.tessl.io/use/spec-driven-development-with-tessl

### Creating Content
- Creating skills: https://docs.tessl.io/create/creating-skills
- Creating documentation: https://docs.tessl.io/create/creating-documentation
- Autogenerating documentation: https://docs.tessl.io/create/autogenerating-documentation
- Creating tiles: https://docs.tessl.io/create/creating-tiles
- Developing tiles locally: https://docs.tessl.io/create/developing-tiles-locally

### Evaluation
- Evaluating skills: https://docs.tessl.io/evaluate/evaluating-skills
- Evaluating documentation: https://docs.tessl.io/evaluate/evaluating-documentation

### Distribution
- Registry: https://docs.tessl.io/distribute/distributing-via-registry
- Sharing publicly/with team: https://docs.tessl.io/distribute/sharing-tiles-publicly
- Rollout to repos: https://docs.tessl.io/distribute/rollout-to-your-repositories
- Repository tiles: https://docs.tessl.io/distribute/repository-tiles

### Reference
- CLI commands: https://docs.tessl.io/reference/cli-commands
- Configuration files: https://docs.tessl.io/reference/configuration
- Custom agent setup: https://docs.tessl.io/reference/custom-agent-setup
- MCP tools: https://docs.tessl.io/reference/mcp-tools
- Workspaces: https://docs.tessl.io/reference/workspaces

### Support
- FAQs: https://docs.tessl.io/support/faqs
- Supported platforms: https://docs.tessl.io/support/supported-platforms

## Notion: Internal Product Context

Use for roadmap status, upcoming features, and product direction. Only fetch when the
post discusses planned features, product maturity, or forward-looking statements.

- Roadmap & Feature Matrix: https://www.notion.so/tessl/Roadmap-2c437cf6e97a80ec9825d0f16b10ea8b

## How to Use This Index

### During Phase 0 (Intake):
1. Read the source material (transcript, notes, etc.)
2. List the product features, commands, or concepts mentioned
3. Match each to 1-3 pages from this index
4. Fetch ONLY those pages
5. If a feature isn't covered in any docs page, flag it for the author

### During Phase 3 (Product Accuracy Check):
1. For each product claim in the draft, confirm it matches what the fetched docs say
2. If you need to verify something you didn't fetch in Phase 0, fetch that specific
   page now — don't guess
3. Flag any claim that contradicts the docs or isn't covered by them

### Context Budget:
- With a 1M context window, you can comfortably fetch 6-10 docs pages per post without
  pressure. Fetch what you need to be accurate — don't ration.
- If a post touches more than 6 distinct product areas, it might be trying to cover too
  much — flag this to the author during Phase 2 (Editorial Planning)
- Use WebFetch to pull docs pages directly. Don't ask the author to provide them.
- The roadmap Notion page is large; only fetch it if the post specifically discusses
  product maturity or upcoming features

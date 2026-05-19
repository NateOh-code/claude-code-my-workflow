---
name: review-stata
description: Read-only Stata do-file review protocol for `.do` and `.ado` scripts. Checks reproducibility, applied-micro correctness (FE, IV, staggered DiD, clustering), output discipline, and code quality. Use when user says "review this do-file", "audit the Stata code", "code review on the .do", "check my Stata analysis", or when a do-file is touched as part of a paper submission. NOT for running the code — pair with `/audit-reproducibility` for numeric verification.
argument-hint: "[do-file path or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Stata Scripts

Run the comprehensive Stata code-review protocol. Sibling skill to [`/review-r`](../review-r/SKILL.md), specialized for applied microeconometrics in Stata.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.do` filename or path: review that file only.
   - If `$ARGUMENTS` is `all`: review every `.do` file under `Stata/do/` (and any `.ado` under `Stata/ado/` that the project authored — skip third-party SSC packages installed there).
   - If `$ARGUMENTS` is empty: prompt the user for a target.

2. **For each script, launch the `stata-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent definition.
   - Read [`.claude/rules/stata-code-conventions.md`](../../rules/stata-code-conventions.md) for current standards.
   - Read [`Stata/profile.do`](../../../Stata/profile.do) so it knows the project's globals and conventions.
   - Save report to `quality_reports/[do_file_basename]_stata_review.md`.

3. **After all reviews complete**, present a summary:
   - Total issues found per script.
   - Breakdown by severity (Critical / High / Medium / Low).
   - Top 3 most critical issues across all scripts.

4. **IMPORTANT: Do NOT edit any Stata source files.**
   Only produce reports. Fixes are applied after user review.

## What this skill catches (vs. what it doesn't)

**Catches:**
- Identification bugs (wrong cluster level, vanilla TWFE for staggered DiD, weak first-stage IV without weak-IV-robust CIs).
- Reproducibility bugs (mid-script `set seed`, absolute paths, missing `version`, unpinned SSC packages).
- Output-discipline bugs (`outreg2` instead of `esttab`, raw numbers copy-pasted into LaTeX, default Stata color scheme leaking into committed figures).
- Common Stata pitfalls (non-deterministic `bysort`, silent merge mismatches, `if x == .`).

**Does NOT catch:**
- Whether the regression *produced* the reported number — that's [`/audit-reproducibility`](../audit-reproducibility/SKILL.md)'s job. This skill checks the *code*; audit-reproducibility checks the *outputs against the manuscript*.
- Whether the research design is appropriate — that's [`/review-paper`](../review-paper/SKILL.md)'s job.
- Stata syntax errors — Stata catches those at run time. This skill assumes the do-file executes.

## Cross-references

- [`.claude/agents/stata-reviewer.md`](../../agents/stata-reviewer.md) — the agent.
- [`.claude/rules/stata-code-conventions.md`](../../rules/stata-code-conventions.md) — the standards.
- [`.claude/rules/cross-artifact-review.md`](../../rules/cross-artifact-review.md) — when reviewing a manuscript, this skill is auto-invoked on referenced do-files.
- [`/review-r`](../review-r/SKILL.md) — R sibling skill.
- [`/audit-reproducibility`](../audit-reproducibility/SKILL.md) — numeric paper ↔ output verification.

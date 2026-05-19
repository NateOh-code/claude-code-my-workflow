# Data/

Data lives in two subdirectories with different policies:

```
Data/
├── raw/        # untouched source data — GITIGNORED, never committed
└── derived/    # cleaned, anonymized, aggregated — committed if small (<100MB)
```

## Privacy policy (read before adding anything)

- **`raw/` is gitignored by default** (see [`.gitignore`](../.gitignore)). Raw farmland transaction data is typically proprietary (CoreLogic, Zillow ZTRAX, county assessor extracts under DUA) and should never enter version control. If you accidentally commit a raw file, immediately `git rm --cached` it, then audit history with `git log --all --full-history -- Data/raw/<file>`.
- **`derived/` can be committed** if the file is (a) safe to publish (no PII, license permits redistribution) AND (b) small enough that the repo stays manageable (<100MB total; individual files <25MB).
- When in doubt, **don't commit**. Document the file in this README and store it in shared storage (Dropbox, cluster scratch, OSF).

## Project data folder

The user maintains the raw data in a folder named **`climate on agriculture`** on their machine (exact path TBD — fill in below once confirmed). Workflow conventions:

- **Symlink or copy into `Data/raw/`**: either symlink `Data/raw/source -> /path/to/climate on agriculture/source` (preserves single source of truth) or copy the files in (simpler, costs disk space). Stata's `profile.do` uses `$DATA_RAW = $PROJ_ROOT/Data/raw` — anything reachable from there works.
- **Never check the folder into git** — `Data/raw/*` is gitignored.
- Once the exact host path is known, replace `[path-to-folder]` in the provenance table below.

## Documenting sources

For each raw dataset, add a row below. Keep this table current — it's the project's data provenance log.

| File / dataset | Source | Vintage | License / DUA | Local path | Documented by |
|---|---|---|---|---|---|
| *e.g.* CoreLogic deeds | CoreLogic (purchased) | 2024 Q3 extract | Restricted, DUA #... | `Data/raw/corelogic/` | [user] |
| *e.g.* PRISM weather | PRISM Climate Group | 4 km daily, 1981-2024 | Public domain | `Data/raw/prism/` | [user] |
| *e.g.* USDA NASS county yields | NASS Quick Stats | 1950-2024 | Public domain | `Data/raw/nass/` | [user] |

## Derivation pipeline

Raw → derived flows through `Stata/do/01_load.do` and `02_clean.do`. Re-derivation should be deterministic: a fresh clone with `raw/` in place should reproduce `derived/` byte-for-byte after `do Stata/do/00_run_all.do`.

```
Data/raw/<source>/*       ──load.do──>   Data/derived/<source>_load.dta
Data/derived/*_load.dta   ──clean.do──>  Data/derived/analysis_sample.dta
```

## Backup and storage

- **Working storage:** repo on local disk + cluster scratch for large extracts.
- **Backup:** `raw/` snapshotted to `[institutional backup location]` — fill in once you have the path.
- **Archival:** at paper acceptance, prepare a replication package per JEEM's data-and-code policy. `derived/` plus the do-files plus the manuscript constitute the package. Raw data goes to a separate DUA-compliant archive if redistribution is restricted; cite the source so a replicator can request access.

## Pre-commit reminder

Before any `/commit`, double-check `git status` does not list files under `Data/raw/`. The `.gitignore` rule should keep them out, but if a `.gitkeep` or whitelist exception ever lets one slip through, it's a privacy / contract violation.

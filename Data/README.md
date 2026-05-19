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

The raw data lives outside the repo at:

```
C:\Users\user\Documents\my-project\climate on agriculture\
```

Total size: ~11 GB. Files present (as of 2026-05-19):

| File | Size | Description (working inference) |
|---|---|---|
| `D2_land_transaction_clean.dta` | 4.3 GB | Cleaned land transaction panel |
| `D2_land_transaction_climate.dta` | 5.3 GB | Land transactions joined with climate exposure |
| `D2_repeated_sales.dta` | 2.1 GB | Repeated-sales subsample (within-parcel ID) |
| `D3_land_transaction_city_final.dta` | 6.3 MB | City-level aggregate |
| `climate_annual.dta` | 192 KB | Annual climate covariates |

Naming suggests upstream `D1_*` raw extracts exist elsewhere (likely on a network share or external drive); D2/D3 are intermediate derivatives produced offline. Confirm + document upstream provenance before submission.

### Wiring to Stata

The data is too large to copy or commit. Three patterns, pick one:

**Option 1 — point `$DATA_RAW` directly at the source (recommended for single-machine work).** In `Stata/profile.do` (or a gitignored `Stata/profile.local.do` if multi-machine), override:

```stata
global DATA_RAW "C:/Users/user/Documents/my-project/climate on agriculture"
```

`profile.do` currently defaults `$DATA_RAW = $PROJ_ROOT/Data/raw`; the override above bypasses `Data/raw/` entirely. Cleanest, no filesystem changes.

**Option 2 — Windows directory junction.** From a Windows shell (cmd, not Git Bash), at the repo root:

```cmd
rmdir Data\raw
mklink /J Data\raw "C:\Users\user\Documents\my-project\climate on agriculture"
```

After this, `Data/raw/` appears to contain the .dta files but they physically live in the original folder. `profile.do` works unchanged. Junctions on Windows do not require admin rights. Caveat: `Data/raw/.gitkeep` must be deleted first; re-add it later only if you remove the junction.

**Option 3 — symlink (Git Bash, requires Windows Developer Mode or admin).** Same effect as Option 2 but cross-platform syntax:

```bash
rm -rf Data/raw && ln -s "C:/Users/user/Documents/my-project/climate on agriculture" Data/raw
```

Not recommended on Windows without Developer Mode — silently falls back to a junk hard-link in some configurations.

### Privacy guard

Raw transaction data is restricted (Korean land transaction records, KREI internal). Even if linked into `Data/raw/`, the `.gitignore` rule (`Data/raw/*` with whitelist for `.gitkeep` only) prevents accidental commits. **Never** add a `!Data/raw/<filename>` whitelist exception for any actual data file.

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

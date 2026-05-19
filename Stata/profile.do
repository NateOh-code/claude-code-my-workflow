// =============================================================================
// Stata/profile.do — project-local initialization.
//
// Source FIRST in every do-file (or set as Stata's PERSONAL profile.do for
// this session):
//     do "`c(pwd)'/Stata/profile.do"
//
// Sets the project root, locks Stata version, registers a project-local ado/,
// pins the seed, and installs a grstyle scheme matching Preambles/header.tex
// (so Stata figures share the LaTeX paper's palette).
// =============================================================================

clear all
set more off
set type double
version 18

// -----------------------------------------------------------------------------
// Project paths
//
// Assumes the working directory when sourcing is the REPO ROOT (one level
// above Stata/). If sourcing from inside Stata/, the global will resolve to
// the parent of Stata/.
// -----------------------------------------------------------------------------
global PROJ_ROOT  "`c(pwd)'"
if "`: subinstr local PROJ_ROOT "Stata" "", count(local n)'" != "$PROJ_ROOT" {
    // we were sourced from inside Stata/ — pop up one level
    local PROJ_ROOT : subinstr local PROJ_ROOT "/Stata" "", count(1)
    local PROJ_ROOT : subinstr local PROJ_ROOT "\Stata" "", count(1)
    global PROJ_ROOT "`PROJ_ROOT'"
}

global DATA_RAW     "$PROJ_ROOT/Data/raw"
global DATA_DERIVED "$PROJ_ROOT/Data/derived"
global TABLES       "$PROJ_ROOT/Tables"
global FIGURES      "$PROJ_ROOT/Figures"
global LOGS         "$PROJ_ROOT/Stata/log"
global DO           "$PROJ_ROOT/Stata/do"
global ADO          "$PROJ_ROOT/Stata/ado"

// -----------------------------------------------------------------------------
// Project-local ado/ — keeps package versions pinned to the repo. Install via
//     sysdir set PERSONAL "$ADO"
//     ssc install reghdfe, replace
//     ssc install ftools, replace
//     ssc install ivreghdfe, replace
//     ssc install estout, replace
//     ssc install grstyle, replace
//     ssc install palettes, replace
//     ssc install csdid, replace
//     ssc install drdid, replace
//     ssc install eventstudyinteract, replace
// -----------------------------------------------------------------------------
capture mkdir "$ADO"
sysdir set PERSONAL "$ADO"

// -----------------------------------------------------------------------------
// Seed — one place; YYYYMMDD format for traceability.
// -----------------------------------------------------------------------------
set seed 20260519

// -----------------------------------------------------------------------------
// Graph palette — matches Preambles/header.tex (palette contract).
//
// primary-blue   #012169   accent 1, main series
// primary-gold   #B9975B   accent 2, secondary series
// highlight-yel  #F2A900   alerts, treatment markers
// jet            #1A1A1A   body text / axis lines
// neutral        #525252   reference / context / muted
// positive       #15803D   good / observed / identified
// negative       #B91C1C   bad / problematic / bias / counterfactual
// hi-slate       #314F4F   highlight slate
// hi-green       #2E8B57   highlight green
// hi-red         #C41E3A   highlight red
//
// Requires `grstyle` and `palettes`:
//     ssc install grstyle, replace
//     ssc install palettes, replace
// -----------------------------------------------------------------------------
capture which grstyle
if _rc == 0 {
    grstyle clear
    grstyle init
    grstyle set plain, horizontal grid
    grstyle color background white
    grstyle color major_grid gs13
    grstyle linewidth major_grid thin
    grstyle yesno draw_major_hgrid yes
    grstyle anglestyle vertical_tick horizontal

    // Series colors — primary-blue first, then primary-gold, then accents.
    grstyle set color "12 33 105" "185 151 91" "242 169 0" ///
                      "21 128 61" "185 30 29" "82 82 82"   ///
                      "49 79 79" "46 139 87" "196 30 58"
    grstyle set symbol O D T S
    grstyle set legend 6, nobox
}
else {
    display as text "[profile.do] grstyle not installed — figures will use Stata's default scheme."
    display as text "             Install with: ssc install grstyle, replace"
}

// -----------------------------------------------------------------------------
// Default esttab options — keep table style consistent across the paper.
//
// JEEM/Elsevier allows significance stars (unlike AEA). Standard: 0.10, 0.05,
// 0.01. SE in parentheses. Three-decimal point estimates.
// -----------------------------------------------------------------------------
global ESTTAB_OPTS  ///
    cells("b(fmt(3) star) se(fmt(3) par)") ///
    starlevels(* 0.10 ** 0.05 *** 0.01)    ///
    label collabels(none) booktabs

display as text "[profile.do] Project initialized."
display as text "             PROJ_ROOT = $PROJ_ROOT"
display as text "             seed      = 20260519"
display as text "             version   = 18"


#' Helper function to install latex if it isn't already installed
#'
#' @param ... parameters that are passed on to `tinytex::install_tinytex(...)`
#' @param packages a character vector of Latex packages that are installed.
#'   By default, a number of essential packages.
#'
#' @returns `invisible(TRUE)` if the function runs through.
#'
#' @export
setup_latex <- function(..., packages = c("standalone", "pgf", "preview", "luatex85", "fontspec",
                                          "luaotfload", "latex-bin", "lm", "graphics", "grfext",
                                          "plex", "plex-otf", "unicode-math", "amsmath",
                                          "lualatex-math", "mathtools")){
  tinytex::install_tinytex(...)
  tinytex::tlmgr_install(packages)
  invisible(TRUE)
}

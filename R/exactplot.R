
#' @import ggplot2
NULL


xp <- new.env(parent = emptyenv())
xp$fontsize <- 7
xp$fontsize_small <- 6
xp$fontsize_tiny <- 5
xp$fontsize_large <- 10


#' Update the default ggplot theme, sets font defaults and extra latex packages
#'
#' To modify the Latex preamle defaults, take a look at `options("tikzDocumentDeclaration")`,
#' `options("tikzLatexPackages")`, `options("tikzLatexPackages")`. For all details, read the
#' `vignette("tikzDevice")`.
#'
#' @param font_main,font_math,font_mono the font choices for Latex. All IBM Plex fonts are
#'  freely available.
#' @param fontsize,fontsize_small,fontsize_tiny,fontsize_large the font sizes
#' @param additional_latex_packages latex packages that are added to `options("tikzLatexPackages")`.
#'
#' @details
#' I like the IBM Plex fonts for figures (and they are the recommended fonts by EMBL). You can install them on Mac
#' using `brew install --cask font-ibm-plex-sans font-ibm-plex-mono font-ibm-plex-math`.
#'
#' Here are some other font combinations that have been recommended:
#'
#' ```
#' # Classical Latex look (serif font)
#' \setmainfont{Latin Modern Roman}
#' \setmathfont{Latin Modern Math}
#' ```
#'
#' ```
#' # Times New Roman look (serif font)
#' \setmainfont{TeX Gyre Termes}
#' \setmathfont{TeX Gyre Termes Math}
#' ```
#'
#' ```
#' # Libertinus (serif font)
#' \setmainfont{Libertinus Serif}
#' \setmathfont{Libertinus Math}
#' ```
#'
#' ```
#' # Helvetica look (sans-serif font)
#' \setmainfont{Helvetica}
#' \setmathfont{Fira Math}
#' ```
#'
#' ```
#' # Palatino (serif font)
#' \setmainfont{Palatino}
#' \setmathfont{Asana Math}
#' ```
#'
#' @export
xp_init <- function(font_main = "IBM Plex Sans", font_math = "IBM Plex Math", font_mono = "IBM Plex Mono",
                    fontsize = 8, fontsize_small = 6, fontsize_tiny = 5, fontsize_large = 10,
                    additional_latex_packages = c("bm", "amsmath", "amssymb")){
  # Update xp object
  xp$fontsize <- fontsize
  xp$fontsize_small <- fontsize_small
  xp$fontsize_tiny <- fontsize_tiny
  xp$fontsize_large <- fontsize_large

  # Prepare tikzDevice
  tikzDevice::setTikzDefaults()
  xp_add_latex_package(additional_latex_packages)
  options(tikzDocumentDeclaration = union(getOption("tikzDocumentDeclaration"), c(
    r"(\usepackage{fontspec})",
    r"(\usepackage{unicode-math})",
    paste0(r"(\setmainfont{)",  font_main, "}"),
    paste0(r"(\setmathfont{)",  font_math, "}"),
    paste0(r"(\setmonofont[Color={0019D4}]{)",  font_mono, "}")
  )))

  # Update ggplot defaults
  theme_set(theme_xp(fontsize, fontsize_small, fontsize_tiny, fontsize_large))
  update_geom_defaults("text", list(size = fontsize_small / .pt))
  update_geom_defaults("label", list(size = fontsize_small / .pt))
}

#' Modify the tikzLatexPackages option
#'
#' @param packages the name of the packages. Can be the full import statement (`\usePackage{abcd}`)
#'   in which case it is not modified or just the package name in which case it is wrapped in
#'   `\usePackage{...}`.
#'
#' @export
xp_add_latex_package <- function(packages){
  packages <- stringr::str_trim(packages)
  packages <- ifelse(stringr::str_starts(packages, "\\\\usepackage\\{"), packages, paste0("\\usepackage{", packages, "}"))
  options(tikzLatexPackages = union(getOption("tikzLatexPackages"), packages))
}

#' A simple theme for publications with few superfluous lines
#'
#' This function extends [`cowplot::theme_cowplot`]
#'
#' @param fontsize,fontsize_small,fontsize_tiny,fontsize_large the font sizes
#'
#' @export
theme_xp <- function(fontsize = xp$fontsize, fontsize_small = xp$fontsize_small, fontsize_tiny = xp$fontsize_tiny, fontsize_large = xp$fontsize_large,
                     line_size = 0.3, panel.spacing = unit(2, "mm")){
  cowplot::theme_cowplot(font_size = fontsize, rel_small = fontsize_small / fontsize,
                                       rel_tiny = fontsize_tiny / fontsize, rel_large = fontsize_large / fontsize,
                                       line_size = line_size) +
    theme(plot.title = element_text(size = fontsize),
          axis.title = element_text(size = fontsize_small),
          legend.title = element_text(size = fontsize_small),
          strip.background = element_blank(),
          strip.text = element_text(size = fontsize_small),
          panel.spacing = panel.spacing)
}

#' Get legend
#'
#' Wraps `cowplot::get_plot_component`
#'
#' @param plot the plot from which the legend is extracted.
#'
#' @export
xp_get_legend <- function(plot){
  comps <- cowplot::get_plot_component(plot,  "guide-box",return_all = TRUE)
  comps <-  purrr::discard(comps, \(x) ggplot2:::is.zero(x))
  comps[[1]]
}



xp_umap_axis <- function(label = "UMAP", fontsize = xp$fontsize_small, arrow_length = 10, label_offset = 1, fix_coord = TRUE, remove_axes = TRUE,
                       arrow_spec = grid::arrow(ends = "both", type = "closed", angle = 20, length = unit(arrow_length / 7, units)),
                       units = "mm", ...){
  coord <- if(fix_coord){
    coord_fixed(clip = "off", ...)
  }else{
    NULL
  }
  axis_theme <- if(remove_axes){
    theme(axis.line = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          axis.title = element_blank())
  }else{
    NULL
  }
  lines <- annotation_custom(grid::polylineGrob(x = unit(c(0, 0, arrow_length), units), y = unit(c(arrow_length, 0, 0), units),
                                                gp = grid::gpar(fill = "black"),
                                                arrow = arrow_spec))
  text <- if(! is.null(label)){
    annotation_custom(grid::textGrob(label = label, gp = grid::gpar(fontsize = fontsize),
                                     x = unit(label_offset, units), y = unit(label_offset, units), hjust = 0, vjust = 0))
  }else{
    NULL
  }
  list(coord, axis_theme, lines, text)
}

xp_annotate_small_arrow <- function(position = c(0.8, 0.95), offset = 0.01, label = NULL, direction = c("x", "y"),
                        fontsize = xp$fontsize_small, arrow_length = unit(10 / 7, "mm"), label_offset = 0, label_hjust = NULL, label_vjust = NULL,
                        arrow_spec = grid::arrow(ends = "last", type = "closed", angle = 20, length = arrow_length),
                        units = "npc"){
  direction <- match.arg(direction)
  if(!grid::is.unit(position)){
    position <- grid::unit(position, units = units)
  }
  if(!grid::is.unit(offset)){
    offset <- grid::unit(offset, units = units)
  }
  if(!grid::is.unit(label_offset)){
    label_offset <- grid::unit(label_offset, units = units)
  }
  if(direction == "x"){
    arrow <- annotation_custom(grid::polylineGrob(x = position, y = c(offset, offset),
                                                  gp = grid::gpar(fill = "black"),
                                                  arrow = arrow_spec))
    text <- if(! is.null(label)){
      annotation_custom(grid::textGrob(label = label, gp = grid::gpar(fontsize = fontsize),
                                       x = (position[1] + position[2]) / 2, y = offset + label_offset,
                                       hjust = label_hjust, vjust = label_vjust))
    }
  }else{
    arrow <- annotation_custom(grid::polylineGrob(y = position, x = c(offset, offset),
                                                  gp = grid::gpar(fill = "black"),
                                                  arrow = arrow_spec))
    text <- if(! is.null(label)){
      annotation_custom(grid::textGrob(label = label, gp = grid::gpar(fontsize = fontsize),
                                       y = (position[1] + position[2]) / 2, x = offset + label_offset,
                                       hjust = label_hjust, vjust = label_vjust, rot = 90))
    }
  }
  list(arrow, text)
}







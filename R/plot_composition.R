

######### Custom plotting functions #########

convert_dims <- function(width, height, units = c("inches", "in", "cm", "mm", "px"), dpi = 300, scale = 1){
  units <- match.arg(units)
  if(units == "inches"){
    units <- "in"
  }
  to_inches <- function(x) x/c(`in` = 1, cm = 2.54, mm = 2.54 *
                                 10, px = dpi)[units]
  to_inches(c(width, height)) * scale
}

my_pdf <- function(filename, width, height, units = c("inches", "in", "cm", "mm", "px"), dpi = 300, scale = 1, ...){
  dim <- convert_dims(width, height, units, dpi, scale)
  grDevices::pdf(filename, width = dim[1], height = dim[2], useDingbats = FALSE, ...)
}


my_tikz <- function(filename, width, height, units = c("inches", "in", "cm", "mm", "px"), dpi = 300, scale = 1, stand_alone = TRUE, ...){
  dim <- convert_dims(width, height, units, dpi, scale)
  tikzDevice::tikz(filename, width = dim[1], height = dim[2], standAlone = stand_alone,
                   engine = "luatex",
                   documentDeclaration = getOption("tikzDocumentDeclaration"), ..., verbose = TRUE)
}

save_plot <- function(filename, plot = ggplot2::last_plot(), width = 6.2328, height = 3.71, units = c("inches", "cm", "mm", "px"), dpi = 300, scale = 1, latex_support = FALSE, ...){

  old_dev <- grDevices::dev.cur()
  if(latex_support){
    filename <- if(stringr::str_ends(filename, "\\.pdf")){
      paste0(stringr::str_sub(filename, end  = -5L), ".tex")
    }
    my_tikz(filename, width = width, height = height, units = units, dpi = dpi, scale = scale, stand_alone = TRUE)
  }else{
    dim <- convert_dims(width, height, units, dpi, scale)
    dev <- ggplot2:::plot_dev(NULL, filename, dpi = dpi)
    dev(filename = filename, width = dim[1], height = dim[2], ...)
    on.exit(utils::capture.output({
      grDevices::dev.off()
      if (old_dev > 1) grDevices::dev.set(old_dev)
    }))
  }

  grid::grid.draw(plot)

  if(latex_support){
    grDevices::dev.off()
    if (old_dev > 1) grDevices::dev.set(old_dev)

    withr::with_dir(dirname(filename), {
      tools::texi2pdf(basename(filename), clean = TRUE)
      # Remove .tex file
      file.remove(basename(filename))
      raw_file_name <- tools::file_path_sans_ext(basename(filename))
      # rastered images
      ras_files <- list.files(pattern = paste0("^", raw_file_name, "_ras\\d*.png"))
      if(length(ras_files) > 0){
        file.remove(ras_files)
      }
    })
  }

  invisible(filename)
}

#' Compose plots with millimeter precision
#'
#'
#' @param ... the panels (have to be grid objects)
#' @param .plot_objs alternative specification of the panels as a list
#' @param width,height the size of the total plot area. Defaults to the width of a plot in
#'   Nature.
#' @param units the unit of the plot dimensions.
#' @param show_grid_lines boolean that indicates if helper lines are displayed in the background
#'   to help align panels.
#' @param keep_tex_file boolean that indicates if the .tex file are retained after the latex
#'   compilation completes. Only applies if `filename` is not `NULL`.
#' @param latex_engine the Latex engine used to compile the .tex document.
#' @param filename optional filename where the plot is saved. If `NULL` it is plotted without rendering
#'   the latex.
#'
#' @details
#' Text that contains Latex code is only rendered when saving as a file.
#'
#'
#' @export
xp_compose_plots <- function(..., .plot_objs = NULL, width = 180, height = 110, units = c("mm", "cm", "inches", "px"),
                          show_grid_lines = FALSE, keep_tex_file = FALSE, latex_engine = "luatex", filename = NULL){
  units <- match.arg(units)
  old_latex_engine <- options(tikzDefaultEngine = latex_engine)
  on.exit({
    options(tikzDefaultEngine = old_latex_engine)
  })

  plots <- if(is.null(.plot_objs)){
    list(...)
  }else{
    .plot_objs
  }

  if(show_grid_lines){
    x_breaks <- scales::breaks_pretty(n = 10)(seq(0, width, length.out = 100))
    y_breaks <- scales::breaks_pretty(n = 10)(seq(0, height, length.out = 100))
  }else{
    x_breaks <- c(0,Inf)
    y_breaks <- c(0,Inf)
  }

  if(! is.null(filename)){
    old_dev <- grDevices::dev.cur()
    filename <- if(stringr::str_ends(filename, "\\.pdf")){
      paste0(stringr::str_sub(filename, end  = -5L), ".tex")
    }
    my_tikz(filename, width = width, height = height, units = units, stand_alone = TRUE)
  }


  plotgardener::pageCreate(width = width, height = height, default.units = units, xgrid = diff(x_breaks)[1], ygrid = diff(y_breaks)[1], showGuides = show_grid_lines)
  plot_elements <- function(plots, x0=0, y0=0){
    for(obj in plots){
      if(is.ggplot(obj)){
        plotgardener::plotGG(obj, x = 0, y = 0, width = width, height = height, default.units = units)
      }else if(grid::is.grob(obj)){
        grid::grid.draw(obj)
      }else if(inherits(obj, "tikz_")){
        grid::grid.draw(obj$FUN(width, height, units))
      }else if(inherits(obj, "exactplot_origin")){
        plot_elements(obj$plots, x0=x0+obj$x0, y0 = y0 + obj$y0)
      }else if(inherits(obj, "exactplot_panel")){
        stopifnot(! is.null(names(obj)))
        stopifnot("plot" %in% names(obj))
        .x <- obj$x %||% 0
        .y <- obj$y %||% 0
        .width <- obj$width %||% width
        .height <- obj$height %||% height
        .units <- obj$units %||% units
        plotgardener::plotGG(obj$plot, x = .x, y = .y, width = .width, height = .height, default.units = .units)
      }else{
        warning("Cannot handle object of class: ", toString(class(obj)))
      }
    }
  }
  plot_elements(plots)

  if(! is.null(filename)){
    grDevices::dev.off()
    if (old_dev > 1) grDevices::dev.set(old_dev)
    old <- setwd(dir = dirname(filename))
    on.exit({
      setwd(old)
    })
    on.exit({
      if(!keep_tex_file){
        # Remove .tex file
        file.remove(basename(filename))
        raw_file_name <- tools::file_path_sans_ext(basename(filename))
        # rastered images
        ras_files <- list.files(pattern = paste0("^", raw_file_name, "_ras\\d*.png"))
        if(length(ras_files) > 0){
          file.remove(ras_files)
        }
      }
    }, add=TRUE, after=FALSE)
    tinytex::latexmk(basename(filename), engine = latex_engine)
  }
}

panel <- function(plot, x = 0, y = 0, width = NULL, height = NULL, units = NULL){
  res <- list(plot = plot, x = x, y = y, width = width, height = height, units = units)
  class(res) <- "exactplot_panel"
  res
}

#' @rdname compose_plots
#' @export
xp_plot <- function(plot, x = 0, y = 0, width = NULL, height = NULL, units = NULL){
  panel(plot = plot, x = x, y = y, width = width, height = height, units = units)
}

#' @rdname compose_plots
#' @export
xp_text <- function(label, x = 0, y = 0, fontsize = xp$fontsize, hjust = 0, vjust = 1, ...){
  panel(plot = cowplot::ggdraw() + cowplot::draw_label(label, size = fontsize, hjust = hjust, vjust = vjust, ...), x = x, y = y, width = 0, height = 0)
}

#' @rdname compose_plots
#' @export
xp_origin <- function(..., .plot_objs = NULL, x = 0, y = 0){
  plots <- if(is.null(.plot_objs)){
    list(...)
  }else{
    .plot_objs
  }
  res <- list(plots = plots, x0 = x, y0 = y)
  class(res) <- "plotexact_origin"
  res
}

#' @rdname compose_plots
#' @export
xp_graphic <- function(filename, x = 0, y = 0, width = NULL, height = NULL,
                        units = c("inches", "cm", "mm", "px", "user"),
                        anchor = c("north west", "south west", "base")){
  # Note that x and y are from the lower left corner, instead of upper left :/
  stopifnot(file.exists(filename))
  units <- match.arg(units)
  anchor <- anchor[1]
  abs_filepath <- tools::file_path_as_absolute(filename)
  size_spec <- if(!is.null(height) && !is.null(width)){
    paste0("[width=", width, units, ", height=", height, units, "]")
  }else if(!is.null(height)){
    paste0("[height=", height, units, "]")
  }else if(! is.null(width)){
    paste0("[width=", width, units, "]")
  }else{
    ""
  }
  content <- paste0(r"(\includegraphics)", size_spec, r"({")", abs_filepath, r"("})")
  res <- list(FUN = (\(figure_width, figure_height, fig_unit){
    stopifnot(fig_unit == units)
    tikzDevice::grid.tikzNode(x = x, y = figure_height - y, units = units,
                              opts = paste0("draw=none,fill=none,anchor=", anchor),
                              content = content, draw = FALSE)
  }))
  class(res) <- "exactplotter_function"
  res
}


#' Save a trellis plot with sensible defaults.
#'
#' lsave is a convenient function for saving a plot. For a default size, it uses
#' the size of the current graphics device.  It also guesses the type of
#' graphics device from the extension.  This means the only arguments you
#' need to supply is the filename and the trellis plot.
#'
#' \code{lsave} currently recognises the extensions eps/ps, tex (pictex),
#' pdf, jpeg, tiff, png, bmp, svg and wmf (windows only).
#'
#' @param filename file name/filename of plot
#' @param plot plot to save
#' @param device device to use, automatically extract from file name extension
#' @param path path to save plot to (if you just want to set path and not
#'    filename)
#' @param scale scaling factor
#' @param width width (defaults to the width of current plotting window)
#' @param height height (defaults to the height of current plotting window)
#' @param units units for width and height when either one is explicitly specified (in, cm, or mm)
#' @param dpi dpi to use for raster graphics
#' @param limitsize when \code{TRUE} (the default), \code{ggsave} will not
#'   save images larger than 50x50 inches, to prevent the common error of
#'   specifying dimensions in pixels.
#' @param ... other arguments passed to graphics device
#' @export
#' @examples
#' \dontrun{
#' sp <- splom(iris)
#' lsave("sp.pdf", sp)
#' lsave("sp.png", sp)
#' lsave("sp.png", sp, width = 4, height = 4, dpi = 600)
#' # make twice as big as on screen
#' lsave("sp.png", sp, scale=2)
#' }
lsave <-
  function (filename = default_name(plot), plot, 
            device = default_device(filename), path = NULL, scale = 1, 
            width = par("din")[1], height = par("din")[2], 
            units = c("in", "cm", "mm"), dpi = 300, limitsize = TRUE, ...) {
    if (!inherits(plot, "trellis")) 
      stop("plot should be a trellis plot")
    eps <- ps <- function(..., width, height) grDevices::postscript(..., 
                                                                    width = width, height = height, onefile = FALSE, horizontal = FALSE, 
                                                                    paper = "special")
    tex <- function(..., width, height) grDevices::pictex(..., 
                                                          width = width, height = height)
    pdf <- function(..., version = "1.4") grDevices::pdf(..., 
                                                         version = version)
    svg <- function(...) grDevices::svg(...)
    wmf <- function(..., width, height) grDevices::win.metafile(..., 
                                                                width = width, height = height)
    emf <- function(..., width, height) grDevices::win.metafile(..., 
                                                                width = width, height = height)
    png <- function(..., width, height) grDevices::png(..., width = width, 
                                                       height = height, res = dpi, units = "in")
    jpg <- jpeg <- function(..., width, height) grDevices::jpeg(..., 
                                                                width = width, height = height, res = dpi, units = "in")
    bmp <- function(..., width, height) grDevices::bmp(..., width = width, 
                                                       height = height, res = dpi, units = "in")
    tiff <- function(..., width, height) grDevices::tiff(..., 
                                                         width = width, height = height, res = dpi, units = "in")
    default_name <- function(plot) {
      paste(digest.ggplot(plot), ".pdf", sep = "")
    }
    default_device <- function(filename) {
      pieces <- strsplit(filename, "\\.")[[1]]
      ext <- tolower(pieces[length(pieces)])
      match.fun(ext)
    }
    units <- match.arg(units)
    convert_to_inches <- function(x, units) {
      x <- switch(units, `in` = x, cm = x/2.54, mm = x/2.54/10)
    }
    convert_from_inches <- function(x, units) {
      x <- switch(units, `in` = x, cm = x * 2.54, mm = x * 
                  2.54 * 10)
    }
    if (!missing(width)) {
      width <- convert_to_inches(width, units)
    }
    if (!missing(height)) {
      height <- convert_to_inches(height, units)
    }
    if (missing(width) || missing(height)) {
      message("Saving ", prettyNum(convert_from_inches(width * 
                                                       scale, units), digits = 3), " x ", 
              prettyNum(convert_from_inches(height * scale, units), digits = 3), " ", units, " image")
    }
    width <- width * scale
    height <- height * scale
    if (limitsize && (width >= 50 || height >= 50)) {
      stop("Dimensions exceed 50 inches (height and width are specified in inches/cm/mm, not pixels).", 
           " If you are sure you want these dimensions, use 'limitsize=FALSE'.")
    }
    if (!is.null(path)) {
      filename <- file.path(path, filename)
    }
    device(file = filename, width = width, height = height, ...)
    on.exit(capture.output(dev.off()))
    print(plot)
    invisible()
  }

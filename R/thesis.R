#' Creates an R Markdown PDF Thesis document
#'
#' This is a function called in output in the YAML of the driver Rmd file
#' to specify using the University of Zurich Thesis LaTeX template and cls files.
#'
#' @export
#'
#' @param toc A Boolean (TRUE or FALSE) specifying whether table of contents
#'  should be created
#' @param toc_depth A positive integer
#' @param ... Further arguments passed to or from other methods.
#' @param highlight Syntax highlighting style. Supported styles include
#' "default", "tango", "pygments", "kate", "monochrome", "espresso", "zenburn",
#' and "haddock". Pass NULL to prevent syntax highlighting.
#'
#' @return A modified \code{pdf_document} based on the University of Zurich Thesis LaTeX
#'   template
#' @examples
#' \dontrun{
#' output:zurichdown::thesis_pdf
#' }
thesis_pdf <- function(toc = TRUE, toc_depth = 3, highlight = "default", pandoc_args = NULL, ...) {
  base <- bookdown::pdf_book(
    template = "template.tex",
    toc = toc,
    toc_depth = toc_depth,
    highlight = highlight,
    keep_tex = TRUE,
    pandoc_args = c(pandoc_args, "--top-level-division=chapter"),
    ...
  )

  # Mostly copied from knitr::render_sweave
  base$knitr$opts_chunk$comment <- NA
  # base$knitr$opts_chunk$fig.align <- "center"

  old_opt <- getOption("bookdown.post.latex")
  options(bookdown.post.latex = fix_envs)
  on.exit(options(bookdown.post.latex = old_opt))

  base
}

#' Creates an R Markdown gitbook Thesis document
#'
#' This is a function called in output in the YAML of the driver Rmd file
#' to specify the creation of a webpage version of the thesis.
#'
#' @param ... Further arguments passed to or from other methods.
#'
#' @export
#' @return A gitbook webpage
#' @examples
#' \dontrun{
#' output:zurichdown::thesis_gitbook
#' }
thesis_gitbook <- function(...) {
  config_default <- list(
    toc = list(
      collapse = "section",
      before = '<li><a href="./"></a></li>',
      after = paste(
        '<li><a href="https://github.com/rstudio/bookdown',
        'target="blank">Published with bookdown</a></li>'
      )
    )
  )

  listarg <- list(...)

  if (!"split_by" %in% names(listarg)) {
    listarg$split_by <- "chapter+number"
  }

  if (!"config" %in% names(listarg)) {
    listarg$config <- config_default
  } else {
    if (!"toc" %in% names(listarg$config)) {
      listarg$config$toc <- config_default$toc
    } else {
      if (!"collapse" %in% names(listarg$config$toc)) {
        listarg$config$toc$collapse <- config_default$toc$collapse
      }
      if (!"before" %in% names(listarg$config$toc)) {
        listarg$config$toc$before <- config_default$toc$before
      }
      if (!"after" %in% names(listarg$config$toc)) {
        listarg$config$toc$after <- config_default$toc$after
      }
    }
  }

  base <- do.call(bookdown::gitbook, listarg)

  # Mostly copied from knitr::render_sweave
  base$knitr$opts_chunk$comment <- NA
  base$knitr$opts_chunk$fig.align <- "center"

  base
}

#' Creates an R Markdown Word Thesis document
#'
#' This is a function called in output in the YAML of the driver Rmd file
#' to specify the creation of a Microsoft Word version of the thesis.
#'
#' @param ... Further arguments passed to or from other methods.
#'
#' @export
#' @return A Word Document based on (hopefully soon, but not currently)
#' the University of Zurich Thesis Word template
#' @examples
#' \dontrun{
#' output:zurichdown::thesis_word
#' }
thesis_word <- function(...) {
  base <- bookdown::word_document2(...)

  # Mostly copied from knitr::render_sweave
  base$knitr$opts_chunk$comment <- NA
  base$knitr$opts_chunk$fig.align <- "center"

  base
}

#' Creates an R Markdown epub Thesis document
#'
#' This is a function called in output in the YAML of the driver Rmd file
#' to specify the creation of a epub version of the thesis.
#'
#' @param ... Further arguments passed to or from other methods.
#'
#' @export
#' @return A ebook version of the thesis
#' @examples
#' \dontrun{
#' output:zurichdown::thesis_epub
#' }
thesis_epub <- function(...) {
  base <- bookdown::epub_book(...)

  # Mostly copied from knitr::render_sweave
  base$knitr$opts_chunk$comment <- NA
  base$knitr$opts_chunk$fig.align <- "center"

  base
}

fix_envs <- function(x) {
  beg_reg <- "^\\s*\\\\begin\\{.*\\}"
  end_reg <- "^\\s*\\\\end\\{.*\\}"
  i3 <- if (length(i1 <- grep(beg_reg, x))) {
    (i1 - 1)[grepl("^\\s*$", x[i1 - 1])]
  }

  i3 <- c(
    i3,
    if (length(i2 <- grep(end_reg, x))) {
      (i2 + 1)[grepl("^\\s*$", x[i2 + 1])]
    }
  )
  if (length(i3)) x <- x[-i3]
  x
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/exactplot.R
\name{xp_init}
\alias{xp_init}
\title{Update the default ggplot theme, sets font defaults and extra latex packages}
\usage{
xp_init(
  font_main = "IBM Plex Sans",
  font_math = "IBM Plex Math",
  font_mono = "IBM Plex Mono",
  fontsize = 8,
  fontsize_small = 6,
  fontsize_tiny = 5,
  fontsize_large = 10,
  additional_latex_packages = c("amsmath")
)
}
\arguments{
\item{font_main, font_math, font_mono}{the font choices for Latex. All IBM Plex fonts are
freely available.}

\item{fontsize, fontsize_small, fontsize_tiny, fontsize_large}{the font sizes}

\item{additional_latex_packages}{latex packages that are added to \code{options("tikzLualatexPackages")}.}
}
\description{
To modify the Latex preamle defaults, take a look at \code{options("tikzDocumentDeclaration")} and
\code{options("tikzLatexPackages")}. For all details, read the \code{vignette("tikzDevice")}.
}
\details{
I like the IBM Plex fonts for figures (and they are the recommended fonts by EMBL). You can install them on Mac
using \verb{brew install --cask font-ibm-plex-sans font-ibm-plex-mono font-ibm-plex-math}.

Here are some other font combinations that have been recommended:

\if{html}{\out{<div class="sourceCode">}}\preformatted{# Classical Latex look (serif font)
\\setmainfont\{Latin Modern Roman\}
\\setmathfont\{Latin Modern Math\}
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{# Times New Roman look (serif font)
\\setmainfont\{TeX Gyre Termes\}
\\setmathfont\{TeX Gyre Termes Math\}
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{# Libertinus (serif font)
\\setmainfont\{Libertinus Serif\}
\\setmathfont\{Libertinus Math\}
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{# Helvetica look (sans-serif font)
\\setmainfont\{Helvetica\}
\\setmathfont\{Fira Math\}
}\if{html}{\out{</div>}}

\if{html}{\out{<div class="sourceCode">}}\preformatted{# Palatino (serif font)
\\setmainfont\{Palatino\}
\\setmathfont\{Asana Math\}
}\if{html}{\out{</div>}}
}

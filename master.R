################################################################################
#' @export master
#'
#' @title Main script to run the ACD-App
#'
#' @description It runs the ACD-App within the ACD_standalone folder. It 
#' checks the availability of the R-packages required and installs them if
#' necessary. It also checks whether specific software is already available and,
#' if not, it will be installed.
#'
#'
#' @details This script is not an R-function and, therefore, does not require
#' any input parameters. 
#' It is recommended to run it through the batch file "ACD.bat". If
#' it is desired to run the App within an R-Session, please refer to 
#' the "Example" section.
#'
#' @examples 
#' source('master.R')
#'
#' @author Rafael Posada and Jens Riede (SASSCAL/DWD), November 2016

#############################################################################
#
#                                 SET PORT
#
#############################################################################
if (exists("usr_nr")){
}else{
  usr_nr <- sprintf("%02d",1)
}
print(paste0("log: Number of users set to: ", usr_nr))
port <- as.numeric(paste0("40", usr_nr))

################################################################################
# 
#                               SET DEFAULTS
#
################################################################################
rversion_prev <- R.Version()
rversion <- paste0(rversion_prev$major, ".", rversion_prev$minor)
pkgs.type <- "win.binary"

################################################################################
#
#                                 SET PATH
#
################################################################################
setwd(file.path(dirname(parent.frame(2)$ofile)))

################################################################################
#
#                           SOURCE R-SCRIPTS
#
################################################################################
# Source the R-Scripts placed in the App
dirR <- file.path(".", "R")
pathnames <- list.files(pattern="[.]R$", path=dirR, full.names=TRUE)
sapply(pathnames, FUN=source)

################################################################################
#
#                               LOCAL SETTINGS
#
################################################################################
local_settings()

################################################################################
#
#                                 WORKING PATH
#
################################################################################
appDir_prev <<- file.path(dirname(parent.frame(2)$ofile), "ACD_App")
setwd(appDir_prev)
appDir <<- getwd()
print(paste0("Current Path: ",appDir))

################################################################################
#
#                           LIBRARIES PATH
#
################################################################################
# Get the libPaths available from where the libraries can be called
libPath <- path.expand(file.path(appDir, "www", "libraries", rversion))
print(paste("Library Path:", libPath))

# Create directory where libraries are to be saved
if (exists("libPath")){
  dir.create(libPath, showWarnings = FALSE, recursive = T)
  .libPaths(c(path.expand(libPath)))
}else{
  .libPaths(c(.libPaths()))
}

################################################################################
#
#                         DOWNLOAD & INSTALL PACKAGES
#
################################################################################
packs <- c("climssc", # local pkg to create climate objects
           "assertthat", #
           "backports", #
           "bitops", #
           "data.from.climsoft.db", # local pkg to download data from climsoft
           "data.table", # provides enhanced version of data.frames
           "DBI", # defines a common interface between the R and DBMS
           "digest", 
           "downloader", # to download programs (e.g. Pandoc)
           "dplyr", #
           "DT", # provides an R interface to the JavaScript library DataTables
           "dygraphs", # to create interactive timeseries
           "evaluate", #
           "get.plots.from.ftp", # local pkg to create graphics?
           "ggvis", # to create interactive histograms
           "hexbin", #
           "highr", #
           "htmltools", # required by shiny
           "htmlwidgets", # required by shiny
           "httpuv", #
           "installr", # functions for software installation and updating 
           "jsonlite", # 
           "knitr", # to create pdf reports and help files
           "lazyeval", #
           "latticeExtra", #
           "leaflet", # to create a map
           "lubridate", # to handle date times variables (v.1.5.6 required)
           "magrittr", #
           "mapproj", #
           "maps", #
           "mime", #
           "openair", # to create windroses
           "plyr", # to split data apart
           "randomNames", # to create random names  
           "R6", # 
           "RColorBrewer", #
           "Rcpp", #
           "RCurl", # to connect to an url
           "reshape2", # 
           "rhandsontable", # to create interactive tables
           "RJSONIO", # to allow conversion to and from data in Javascript
           "rlang", # required by "ggvis"
           "rmarkdown", # create help documentation
           "R.methodsS3", #
           "RMySQL", # to connect to a mysql (or mariadb) db
           "RODBC", # to connect to an ODBC connection
           "R.oo", #
           "rprojroot", #
           "rtf", # to output Rich Text Format (RTF) files
           "R.utils", # to get dditional basic functions of R
           "shiny", # to create the App
           "shinyBS", # to create pop-up windows in shiny
           "stringi", #
           "stringr", #
           "tcltk",  # to create an easy GUI 
           "tibble", #
           "uuid", # to create random ids
           "webshot", # to print an screenshot
           "XML", # to read HTML files
           "yaml", #
           "xtable", # to create tables in a Latex format
           "xts", #
           "zoo") # to handle time-series data

# Check if packages are already installed
directory <- path.expand(file.path(appDir, "www", "R_pkgs", pkgs.type))
download_and_install_packages(packs = packs, packs.loc = directory,
                              lib.loc = libPath, type = pkgs.type)

################################################################################
#
#                         DOWNLOAD & INSTALL PROGRAMS
#
#############################################################################
programs <- c("phantom", "pandoc", "miktex")
directory <- path.expand(file.path(appDir, "www", "programs"))
download_and_install_programs(programs = programs, programs.loc = directory)

#############################################################################
#
#                          GLOBAL PATH FOR 'PHANTOM'
#
#############################################################################
# Phantom is required to save the map
path.global <- normalizePath(file.path(appDir, "www", "programs"))
path.phantom <- normalizePath(file.path(path.global, "phantom"))
Sys.setenv(PATH=paste(Sys.getenv("PATH"), path.phantom, sep=";"))

#############################################################################
# 
#                               RUN APP
#
#############################################################################
#Run the app (when all packages are installed)
print("The App is ready to run...")
# Run the App
shiny::runApp(file.path(appDir), launch.browser=T,
              host = "0.0.0.0", port = port)

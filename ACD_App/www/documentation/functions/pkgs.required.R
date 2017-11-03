pkgs.required <- function(){
pkgs.online <- sort(c("RODBC", "plyr", "zoo", "dygraphs", "shiny",
                      "R.utils", "RCurl", "XML","ggvis", "openair",
                      "cluster", "tcltk", "reshape2", "rtf", "uuid",
                      "leaflet", "DT", "data.table", "webshot",
                      "htmltools", "htmlwidgets", "xtable", "shinyBS",
                      "rhandsontable", "downloader", "RMySQL", "DBI",
                      "mapdata", "rmarkdown", "caTools", "RJSONIO", "rprojroot",
                      "randomNames", "installr"))

pkgs.offline <- c("climssc", "data.from.climsoft.db", "get.plots.from.ftp")

pkgs.frozen <- c("lubridate", "rlang", "knitr")

return(list(pkgs.online, pkgs.offline, pkgs.frozen))
}
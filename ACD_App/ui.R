####################################################################
# All packages required for running the program
options(warn = -1, message = F)
suppressMessages(library(RODBC))
suppressMessages(library(plyr))
suppressMessages(library(zoo))
suppressMessages(library(dygraphs))
suppressMessages(library(shiny))
suppressMessages(library(R.utils))
suppressMessages(library(RCurl))
suppressMessages(library(XML))
suppressMessages(library(get.plots.from.ftp))
suppressMessages(library(data.from.climsoft.db))
suppressMessages(library(ggvis))
suppressMessages(library(openair))
suppressMessages(library(cluster))
suppressMessages(library(tcltk))
suppressMessages(library(openair))
suppressMessages(library(climssc))
suppressMessages(library(reshape2))
suppressMessages(library(lubridate))
suppressMessages(library(rtf))
suppressMessages(library(openair))
suppressMessages(library(uuid))
suppressMessages(library(leaflet))
suppressMessages(library(DT))
suppressMessages(library(data.table))
suppressMessages(library(knitr))
suppressMessages(library(webshot))
suppressMessages(library(htmltools))
suppressMessages(library(htmlwidgets))
suppressMessages(library(xtable))
suppressMessages(library(shinyBS))
suppressMessages(library(rhandsontable))
suppressMessages(library(RMySQL))
suppressMessages(library(DBI))
suppressMessages(library(rmarkdown))

################################################################################
# SOURCE R-SCRIPTS
dirR <- file.path(".", "www", "R")
pathnames <- list.files(pattern="[.]R$", path=dirR, full.names=TRUE)
sapply(pathnames, FUN=source)

################################################################################
# SET TIMEZONE
Sys.setenv(TZ = "UTC")

################################################################################
# SET LOCAL SETTINGS
if (file.exists("../localSettings.rda")){
  load("../localSettings.rda")
  language <<- localSettings$language
  metService <- localSettings$metService
}else{
  language <<- "english"
  metService <- "other"
}

################################################################################
# SET LOCAL LANGUAGE
if (language == "portuguese"){
  Sys.setlocale("LC_COLLATE", "Portuguese_Portugal.1252")
  language_abbr <- "pt"
  documentation <- "Ajuda"
}else if (language == "english"){
  Sys.setlocale("LC_COLLATE", "English_United Kingdom.1252")
  language_abbr <- "en"
  documentation <- "Help"
}else{
  print("No language identified. English used as default")
  Sys.setlocale("LC_COLLATE", "English_United Kingdom.1252")
  language_abbr <- "en"
  documentation <- "Help"
} 

################################################################################
# SET MET SERVICE

if (tolower(metService) == "inamet"){
  theme <- "inamet.css"
  logo <- "logoINAMET.png"
  logoSize <- "50%"
  dbase_choices <- sort(c(" ","CLIMSOFT", "LOCAL_FILE"))
}else if (tolower(metService) == "zmd"){
  theme <- "sasscal.css"
  logo <- "logoZMD.png"
  logoSize <- "50%"
  dbase_choices <- sort(c(" ","CLIMSOFT", "LOCAL_FILE"))
}else if (tolower(metService) == "dms"){
  theme <- "sasscal.css"
  logo <- "DMS.png"
  logoSize <- "50%"
  dbase_choices <- sort(c(" ","CLIMSOFT", "LOCAL_FILE"))
}else{
  print("No metService identified.")
  theme <- "sasscal.css"
  logo <- "logoNULL.png"
  logoSize <- "30%"
  dbase_choices <- sort(c(" ","CLIMSOFT", "LOCAL_FILE"))
}

################################################################################
# CREATE DOCUMENTATION
dirDoc <<- file.path(".", "www", "documentation", language_abbr)
rmarkdown::render(file.path(dirDoc, "documentation.Rmd"), encoding = 'UTF-8')

# Copy the rmarkdowns
newFolder <- file.path("..","docs", language_abbr)
dir.create(newFolder, showWarnings = T, recursive = T)
files_from <- grep(list.files(dirDoc), pattern = ".Rmd$", inv = T, value = T)
files_to <- file.path(newFolder, files_from)
file.copy(file.path(dirDoc,files_from), newFolder, recursive = F)


################################################################################
# GET TEXT
textInfo <<- translation(language)
for (i1 in c(1:length(textInfo))){
  assign(names(textInfo[i1]),textInfo[[i1]], envir = .GlobalEnv)
}

################################################################################
# INTERFACE
shinyUI(
  fluidPage(theme = file.path("bootstrap",theme),
            titlePanel(title = NULL,windowTitle = textTitlePanel),
            fluidRow(
              column(11),
              column(1, a(documentation, target="_blank", 
                          href=file.path("documentation",language_abbr, 
                                         "documentation.html")))
            ),
            fluidRow(
              column(2, div(img(src=file.path("images", logo), width = logoSize, 
                                height = logoSize),
                            style = "text-align: left;")),
              column(8, h1(textTitlePanel, align = "center")),
              column(2, div(img(src=file.path("images","logoSASSCAL.png"), 
                                width = "65%", height = "65%"),
                            style = "text-align: right;"))
            ),
            HTML('<hr>'),
            sidebarLayout(
              
              
              ##################################################################
              # SIDEBAR PANEL
              sidebarPanel(id="sidebar",
                           uiOutput("UItags"),
                           tags$head(tags$script(HTML('
              Shiny.addCustomMessageHandler("jsCode",
                                           function(message) {
                                           console.log(message)
                                           eval(message.code);
                                           }
                );
                                           '))),
                           tags$script('
            Shiny.addCustomMessageHandler("resetFileInputHandler", function(x) {
                            var id = "#" + x + "_progress";      # name of progress bar is file1_progress
                            var idBar = id + " .bar";
                            $(id).css("visibility", "hidden");   # change visibility
                            $(idBar).css("width", "0%");         # reset bar to 0%
                            });
                            '),
                           # Select database
                           selectInput("dbase",
                                       label = h3(textSidePanel00),
                                       choices = dbase_choices,
                                       selected = ""
                           ),
                           
                           # Other inputs
                           uiOutput("UIsSidePanel"),
                           
                           # Action buttons
                           uiOutput("UIsActionButtons")
              ),
              
              ##################################################################
              mainPanel(
                uiOutput("uiMessages"),
                uiOutput("UIsMainPanel")
              )
            )
  )
)

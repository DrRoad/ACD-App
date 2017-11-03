################################################################################
#' @export climsoft_db_report
#'
#' @title Create a Report
#'
#' @description Creates a Report with metadata information of a selected
#' location. It is used only when the option 'CLIMSOFT' is selected.
#'
#' @param input shiny object. It is a list-like object.
#' It stores the current values of all of the widgets in the
#' application. The Shiny App uses the \code{input}
#' to receive user input from the client web browser.
#' 
#' @param output shiny object. It is a list-like object that stores
#' instructions for building the R objects in the Shiny application.
#' Shiny application.
#' 
#' @param session shiny object. It is a special object that is used for finer
#' control over a user's app session.
#'
#' @details This function will be called by the functions
#' \code{\link[ACD]{climsoft_db_access}} and
#' \code{\link[ACD]{climsoft_db_mariadb}}.
#'
################################################################################

climsoft_db_report <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid1 <- substr(UUIDgenerate(), 1, 4)
  # Check option to create a map
  uiReportInputs <- paste0("uiReportInputs", uid1)
  reportCheck <- paste0("reportCheck", uid1)
  output[[uiReportCheck]] <- renderUI({
    uiOutputs <- list(
      conditionalPanel(
        condition = connectCondition,
        h3(checkboxInput(reportCheck, (textReport00), F)),
        h5(helpText(textReport01))
      ),
      uiOutput(uiReportInputs)
    )
    do.call(tagList, uiOutputs)
  })
  
  observe({
    if (!is.null(input[[reportCheck]]) && (input[[reportCheck]] == T) 
        && openConn(channel2)){
      print("log: Create Report")
      # get original Work Directory
      wd_old <- getwd()
      
      # Create outputs for the sidePanel
      output[[uiReportInputs]] <- renderUI({
        uiOutputs <- list(uiOutput("uiReportStation"),
                          uiOutput("uiReportButtons"))
        do.call(tagList,uiOutputs)
      })
      
      ##########################################################################
      # Find out which stations are available
      # Station Metadata
      request <- paste0("SELECT ",
                        station.id, " AS id, ",
                        station.station_name, " AS station_name, ",
                        station.authority, " AS authority, ",
                        station_location.begin_datetime, " AS begin_datetime, ",
                        station_location.end_datetime, " AS end_datetime, ",
                        station_location.longitude, " AS longitude, ",
                        station_location.latitude, " AS latitude, ",
                        station_location.elevation, " AS elevation ",
                        "FROM (", station,
                        " INNER JOIN ", station_location,
                        " ON ", station.id, " = ", station_location.occupied_by, ");")
      df <- getQuery(input[[dbType]], channel2, request)
      df$id_alias <- NA
      df$refers_to <- NA
      df$belongs_to <- NA
      
      ##########################################################################
      # Check whether the stations have a WMO ID
      request <- paste0("SELECT ",
                        stationid_alias.belongs_to, " AS belongs_to, ",
                        stationid_alias.id_alias, " AS id_alias, ",
                        stationid_alias.refers_to, " AS refers_to ",
                        " FROM ", stationid_alias, ";")
      result0 <- getQuery(input[[dbType]], channel2, request)
      
      id0000 <- match(result0$refers_to, df$id)
      result1 <- data.frame(result0, id0000)
      result1 <- result1[!is.na(result1$id0000),]
      
      df$id_alias[result1$id0000] <- as.character(result1$id_alias)
      df$refers_to[result1$id0000] <- as.character(result1$refers_to)
      df$belongs_to[result1$id0000] <- as.character(result1$belongs_to)
      
      df$colors2 <- NA
      new.authority <- as.vector(df$authority)
      new.authority[which(is.na(new.authority))] <-
        substr(df$id[which(is.na(df$authority))], 1, 3)
      df$authority <- new.authority
      sources <- unique(df$authority)
      colors2 <- rainbow(length(sources))
      colors <- rgb(t(col2rgb(colors2) / 255))
      for (i in 1:length(sources)){
        id <- which(df$authority == sources[i])
        df$colors2[id] <- colors[i]
      }
      
      df$authority2 <- paste0("<div style=color:",tolower(df$colors2),
                              "; display: inline-block;height: 20px;",
                              "margin-top: 4px;line-height: 20px;
      font-family:bold'>",
                              "<b>",df$authority, "</b></div>")
      
      station_names_prev <- sort(unique(toupper(df$station_name)))#[id0]))
      
      output$uiReportStation <- renderUI({
        selectInput("reportStations", label = textReport07, multiple = T,
                    choices = station_names_prev)
      })
      # Define "OK" button
      uid <- substr( UUIDgenerate(),1,4)
      reportButtons <- paste0("reportButtons", uid)
      output$uiReportButtons <- renderUI({
        actionButton(reportButtons, label = h4("OK"))})
      
      # Observe if the ok button has been selected
      observeEvent(input[[reportButtons]],{
        station_names <<- input$reportStations
        
        ########################################################################
        # Create a temporary folder where all files will be saved
        tmpDir <<- file.path(wd_old, "www","ACDReport")
        tmpFile <<- "007-latex.Rtex"
        dir.create(tmpDir, showWarnings = F)
        fileConn <- file.path(tmpDir, tmpFile)
        write("\\documentclass[10pt,a4paper]{article}", fileConn, append = F)
        write("\\usepackage{lscape}", fileConn, append = T)
        write("\\usepackage[left=.5in,right=.5in,top=.4in,bottom=.4in, includefoot,heightrounded]{geometry}", 
              fileConn, append = T)
        write("\\usepackage{graphicx}", fileConn, append = T)
        write("\\usepackage{hyperref}", fileConn, append = T)
        write("\\usepackage[latin1]{inputenc}", fileConn, append = T)
        write(paste0("\\usepackage[noconfigs,", language, "]{babel}"), 
              fileConn, append = T)
        write("\\usepackage{tabularx}", fileConn, append = T)
        # To avoid error associated with number of floats
        write("\\setcounter{topnumber}{8}", fileConn, append = T)
        write("\\setcounter{bottomnumber}{8}", fileConn, append = T)
        write("\\setcounter{totalnumber}{8}", fileConn, append = T)
        tit <- toupper(gsub("_", " ", as.character(odbcGetInfo(channel2)["Data_Source_Name"])))
        write(paste0("\\title{",textReport06, ": \\newline \\textbf{\\Large{", tit,"}}}"),
              fileConn, append = T)
        
        
        write("\\begin{document}", fileConn, append = T)
        write("\\begin{titlepage}", fileConn, append = T)
        write("\\vspace*{\\fill}", fileConn, append = T)
        write("\\begin{center}", fileConn, append = T)
        write(paste0("{\\Huge Report}\\\\[.6cm]{\\Huge\\textbf{", tit,"}}\\\\[0.6cm]"),
              fileConn, append = T)
        write("\\Large \\today\\\\[2cm]", fileConn, append = T)
        write(paste0("\\Large \\textbf{", textReport08, "} \\\\[.4cm] "),
              fileConn, append = T)
        
        write(paste(station_names,  collapse = "\\\\[.3cm]"), fileConn, append = T)
        write("\\end{center}", fileConn, append = T)
        write("\\vspace*{\\fill}", fileConn, append = T)
        write("\\end{titlepage}", fileConn, append = T)
        
        write("\\newpage", fileConn, append = T)
        write("\\pagenumbering{Roman}", fileConn, append = T)
        write("\\tableofcontents", fileConn, append = T)
        write("\\newpage", fileConn, append = T)
        write("\\pagenumbering{arabic}", fileConn, append = T)
        
        if (is.null(station_names)){
          print("No location selected")
          output[[uiReport]] <- renderUI({h3(textReport03)})
          return()
        }else{
          # Create outputs for the mainPanel
          output[[uiReport]] <- renderUI({
            uiOutputs <- list(uiOutput("uiReportHeader"),
                              downloadButton("reportSaveData", textReport04),
                              uiOutput("reportBreak"))
            do.call(tagList,uiOutputs)
          })
          
          # Header
          output$uiReportHeader <- renderUI({h3(textReport05)})
          # Create progress message
          withProgress(message = textReport02, value = 0, {
            for (i in 1:length(station_names)){
              incProgress(1/length(station_names))
              
              # Create the section with the "station_name"
              write("\\newpage", fileConn, append = T)
              write(paste0("\\section{",station_names[i],"}"), fileConn, append =T)
              
              # Create data.frame with the data for the selected station_name
              id1 <- which(toupper(df$station_name) == station_names[i])
              df2 <<- df[id1,]
              
              # Create a map
              mymap <<- leaflet(df2) %>%
                addTiles(group = "OSM (default)") %>%
                addProviderTiles("Stamen.Toner", group = "Toner") %>%
                addProviderTiles("Stamen.TonerLite", group = "Toner Lite",
                                 options = providerTileOptions(noWrap = TRUE)) %>%
                addCircleMarkers(lat = ~ latitude,
                                 lng = ~ longitude,
                                 group = ~ authority2,
                                 radius = 5,
                                 weight = 0,
                                 fillColor = ~ colors2,
                                 fillOpacity = 1,
                                 popup = ~(paste(
                                   paste0('<b><font color="red">',
                                          station_name, '</font></b>'),
                                   paste0("<b>", id, "</b>", " (", authority, ")"),
                                   paste0("Lat: ", latitude),
                                   paste0("Lon: ", longitude),
                                   paste0("WMO id: ", id_alias),
                                   sep="<br/>")), layerId= ~ id) %>%
                addLayersControl(baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
                                 overlayGroups =  ~authority2,
                                 options = layersControlOptions(collapsed = FALSE)
                )
              
              # Save the map
              saveWidget(mymap, "temp.html", selfcontained = FALSE)
              fileMap <- paste0(tmpDir,"/Map", sprintf("%03d",i), ".png")
              fileMap2 <- paste0("./Map", sprintf("%03d",i), ".png")
              fileMap3 <- paste0("Map", sprintf("%03d",i), ".png")
              fileMap4 <- paste0("www/ACDReport/Map",sprintf("%03d",i), ".png")
              print(fileMap)
              webshot("temp.html", file = fileMap2, cliprect = "viewport")
              file.copy(fileMap2, fileMap, overwrite = T)
              file.remove(fileMap2)
             
              # create subsection "Locations"
              write(paste0("\\subsection{", textReport09, "}"), fileConn, append = T)
              
              # paste the map into the LaTeX document
              write(paste0('\\begin{center}{',
                           '\\includegraphics[width=0.72\\textwidth]{',fileMap4,'}}',
                           '\\end{center}'), fileConn, append = T)
              
              # Create subsection "Metadata"
              write(paste0("\\subsection{", textReport10, "}"), fileConn, append = T)
              df3 <- df2[,c("id", "authority", "begin_datetime",
                            "end_datetime", "longitude", "latitude", "elevation",
                            "id_alias")]
              colnames(df3) <- c("station_id", "authority", "begin_date", "end_date",
                                 "long", "lat", "height", "id_alias")
              df3$begin_date <- as.character(df3$begin_date)
              df3$end_date <- as.character(df3$end_date)
              df3$long <- as.character(df3$long)
              df3$lat <- as.character(df3$lat)
              
              # Change the headers of df3 according to the language
              df4 <- df3
              colnames(df4) <- textReport12
              write(print(xtable(df4),  include.rownames=FALSE, print.results = F),
                    fileConn, append = T)
              
              # Get elements available for each station_name
              station_id_request <- paste0("'", df3$station_id, "'", collapse =", ")
              request <- paste0("SELECT ",
                                obs_element.element_name, " AS element_name, ",
                                obs_element.code, " AS code, ",
                                observation.obs_value, " AS obs_value, ",
                                observation.recorded_at, " AS recorded_at, ",
                                observation.recorded_from, " AS recorded_from",
                                " FROM ", obs_element,
                                " INNER JOIN ", observation,
                                " ON ", obs_element.code, " = ", observation.described_by,
                                " WHERE ", observation.recorded_from,
                                " IN (", station_id_request,")",
                                " ORDER BY ", observation.recorded_at,";")
              result2 <- getQuery(input[[dbType]], channel2, request)
              elements <- unique(result2$element_name)
              station_ids <- unique(result2$recorded_from)
              
              # Create subsection "Elements available"
              write(paste0("\\subsection{",textReport11,"}"), fileConn, append = T)
              if (length(elements)==0){
                txt <-paste(textReport14, station_id_request, collapse = ",")
                write(txt, fileConn, append = T)
              }else{
                dd2 <- data.frame(matrix(NA, nrow=length(elements), ncol=length(station_ids)))
                colnames(dd2) <- station_ids
                rownames(dd2) <- elements
                for(i00 in c(1:length(elements))){
                  element <- as.character(elements[i00])
                  id <- which(result2$element_name == element)
                  station_id <- unique(result2$recorded_from[id])
                  id22 <- which(colnames(dd2) %in% station_id)
                  id33 <- which(rownames(dd2) %in% element)
                  dd2[id33,id22] <- "x"
                }
                
                if (ncol(dd2)>5){
                  scalebox <- .8
                }else{
                  scalebox <- 1
                }
                align <- paste0("r", paste(rep("c", ncol(dd2)), collapse = ""))
                write(print(xtable(dd2, align = align), scalebox = scalebox,
                            print.results = F, floating = F),
                      fileConn, append = T)
                if (nrow(dd2) > 6){
                  write("\\clearpage", fileConn, append = T)
                }
                for (i0 in c(1:length(elements))){
                  if (i0%%6 == 0){
                    write("\\clearpage", fileConn, append = T)
                  }
                  element <- as.character(elements[i0])
                  
                  # Remove extrange characters
                  element_new <- gsub("_", " ", element)
                  element_new <- gsub("[][°%]", "", element_new)
                  elemen_new <- gsub("[][()]", "", element_new)
                  
                  # Create subsubsections with the name of the elements
                  write(paste0("\\subsubsection{", element_new,"}"), fileConn, append = T)
                  
                  id2 <- which(result2$element_name == element)
                  df4 <- as.data.frame(as.matrix(result2[id2,]))
                  colnames(df4) <- c("element_name", "code", element, "date", "station_id")
                  
                  
                  df7 <- data.frame(sapply(1:length(unique(df4$station_id)),function(i){
                    station_id <- as.character(unique(df4$station_id)[i])
                    id <- which(df4$station_id == station_id)
                    df5 <- df4[id,]
                    df5_list <- check_dataframe(df5)
                    date_format <- df5_list$dateformat
                    #date_time_period <- df5_list$datetimeperiod
                    if (is.null(date_format)){
                      date_format <- "%Y-%m-%d"
                    }
                    
                    x <- as.POSIXct(df5$date, format = date_format, tz = "UTC")
                    time_diff <- diff(x)
                    
                    # Count cases with the same time stamp
                    time_stamp <- table(time_diff)
                    
                    # a) get the time difference units (minutes, hours, etc.)
                    time_units <- units(time_diff)
                    id <- which(time_stamp==max(time_stamp))
                    
                    # If there are more than one time stamp that appears with the maximum
                    # frecuence, then the program will take the shortest time stamp
                    if (length(id)>1){
                      id <- id[1]
                    }
                    
                    time_interval <- names(time_stamp)[id]
                    
                    if (is.null(time_interval)){
                      time_interval <- 1
                    }
                    
                    data_time_interval <- paste(time_interval,time_units)[1]
                    
                    # Check if the data_time_interval is 29, 30 or 31 days, then it refers
                    # to monthly interval
                    if (data_time_interval %in% paste(c(28:31),"days")==T){
                      data_time_interval <- "1 month"
                    }
                    
                    full <- seq.POSIXt(x[1], x[length(x)], by = data_time_interval)
                    names(full) <- c(1:length(full))
                    all.dates.frame <- data.frame(list(x=full))
                    
                    number_records <- nrow(!is.na(df5[element]))
                    number_expected_records <- as.numeric(length(full))
                    missing_values <- round((1-(number_records/number_expected_records))*100,1)
                    as.matrix(data.frame(station_id,
                                         #date_time_period,
                                         x[1],
                                         x[length(x)],
                                         number_expected_records,
                                         number_records,
                                         missing_values))
                  })
                  )
                  
                  df77 <- as.data.frame(df7[-1,])
                  row.names(df77) <- textReport13
                  colnames(df77) <- as.matrix(df7[1,])
                  
                  write(print(xtable(df77), print.results = F),
                        fileConn, append = T)
                }
              }
            }
            
            ####################################################################
            # Close "latex" document
            write(paste0("\\end{document}"), fileConn, append = T)
            output$reportBreak <- renderUI({HTML("<br/>")})
            
            ####################################################################
            # Create Table
            output$reportSaveData <- downloadHandler(
              filename = paste0(textReport06, ".pdf"),
              
              content = function(file) {
                out = knit2pdf(paste0(tmpDir,"/", tmpFile), clean = TRUE)
                file.rename(out, file) # move pdf to file for downloading
                unlink(tmpDir, recursive = T)
              },
              
              contentType = 'application/pdf'
            )
          })
        }
        # set old working repository again
        setwd(wd_old)
      })
    }else{
      output[[uiReport]] <- renderUI({})
      output[[uiReportInputs]] <- renderUI({})
    }
  })
  return(output)
}

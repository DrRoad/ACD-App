################################################################################
#' @export climsoft_db_export
#'
#' @title Download the data from the CLIMSOFT db
#'
#' @description This function allows the download of data from the CLIMSOFT db
#' through the ACD-App
#'
#' @param input shiny object. It is a list-like object.
#' It stores the current values of all of the widgets in the
#' application. The Shiny App uses the \code{input}
#' to receive user input from the client web browser.
#' @param output shiny object. It is a list-like object that stores
#' instructions for building the R objects in the Shiny application.
#' Shiny application.
#' @param session shiny object. It is a special object that is used for finer
#' control over a user's app session.
#'
#' @details This function will be called by the function
#' \code{\link[ACD]{climsoft_db_access}} and 
#' \code{\link[ACD]{climsoft_db_mariadb}}.
#'
################################################################################

climsoft_db_export2 <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid <- substr(UUIDgenerate(), 1, 4)
  exportCheckId <- paste0("exportCheckId", uid)
  output[[uiExportCheck]] <- renderUI({
    conditionalPanel(
      condition = connectCondition,
      h3(checkboxInput(exportCheckId, textExport00, F)),
      h5(helpText(textExport01))
    )
  })
  
  ##############################################################################
  #
  #                         MAIN PANEL
  #
  ##############################################################################
  
  observe({
    if (!is.null(input[[exportCheckId]]) && (input[[exportCheckId]] == T) 
        && openConn(channel2)){
      print("log: Download data selected")
      uid3 <- substr(UUIDgenerate(), 1, 4)
      uiExportStation <- paste0("uiExportStation_", uid3)
      uiExportElement <- paste0("uiExportElement_", uid3)
      uiExportButton <- paste0("uiExportButton_", uid3)
      uiExportTable <- paste0("uiExportTable_", uid3)
      uiExportDateRange <- paste0("uiExportDateRange_", uid3)
      
      output[[uiExport]] <- renderUI({
        uiOutputs <- list(HTML("<br>"),
                          uiOutput("uiExportHeader"),
                          uiOutput(uiExportStation),
                          uiOutput(uiExportElement),
                          uiOutput(uiExportDateRange),
                          uiOutput(uiExportButton),
                          uiOutput(uiExportTable)
        )
        do.call(tagList,uiOutputs)
      })
      
      
      # Header
      output$uiExportHeader <- renderUI({h3(textExport00)})
      
      ##########################################################################
      # Get the stations available
      
      ##########################################################################
      # STATION ID - REQUEST 1
      requestExport01 <- paste0(
        "SELECT DISTINCT ", station.id, " AS id, ", 
        station.station_name, " AS station_name ",
        "FROM ", station, 
        " INNER JOIN ", observation, 
        " ON ", station.id, 
        " = ", observation.recorded_from,
        " ORDER BY ", station.station_name, ";")
      
      result <- getQuery(input[[dbType]], channel2, requestExport01)
      
      station_id <- unique(as.character(as.matrix(result$id)))
      station_id_list <<- as.vector(apply(result, 1, paste, collapse = " - "))
      
      exportStation <- paste0("exportStation_", uid3)
      output[[uiExportStation]] <- renderUI({
        column(3, selectInput(inputId = exportStation,
                              label = textExport02,
                              choices = c(NULL, "all", station_id_list),
                              multiple = T)
        )
      })
      observe({
        if (!is.null(input[[exportStation]]) && openConn(channel2)){
          if (input[[exportStation]] == "all"){
            station_ids <- station_id
          }else{
            tr <- input[[exportStation]]
            station_ids <- unlist(lapply(1:length(tr), function(i) {
              strsplit(tr[i], " - ")[[1]][1]
            }))
          }
          
          ######################################################################
          # ELEMENTS - REQUEST 2
          station_id_request <<- paste0("'", station_ids, "'", collapse =", ")
          #sh5("Selection of an Element is not possible")
          requestExport02 <<- paste0(
            "SELECT DISTINCT ", obs_element.element_name, " AS element_name ",
            " FROM ", obs_element,
            " INNER JOIN ", observation,
            " ON ", obs_element.code, 
            " = ", observation.described_by,
            " WHERE ", observation.recorded_from, 
            " IN (",station_id_request, ");")
          
          element <- as.character(as.matrix(getQuery(input[[dbType]], channel2, 
                                                     requestExport02)))
          uid4 <- substr(UUIDgenerate(), 1, 4)
          exportElement <- paste0("exportElement_", uid4)
          output[[uiExportElement]] <- renderUI({
            column(3, selectInput(inputId = exportElement,
                                  label = textExport03,
                                  choices = c(NULL, "all", element),
                                  multiple = T)
            )
          })
          
          observe({
            if (openConn(channel2)){
              if (!is.null(input[[exportElement]])){
                if (input[[exportElement]] == "all"){
                  elements <- element
                }else{
                  elements <- input[[exportElement]]
                }
                
                elements_request <<- paste0("'", elements, "'", collapse =", ")
                
                ################################################################
                # DATES
                # Date range
                uid5 <- substr(UUIDgenerate(), 1, 4)
                exportDateRange <- paste0("exportDateRange_", uid5)
                exportButton <- paste0("exportButton_", uid5)
                output[[uiExportDateRange]] <- renderUI({
                  column(3, dateRangeInput(exportDateRange, label = textExport04, 
                                           start = "1800-01-01"))
                })
                
                output[[uiExportButton]] <- renderUI({
                  column(3, list(HTML("<br>"), actionButton(exportButton,
                                                            textExport05)
                  )
                  )
                })
                
                if (input[[dbType]] == "mariadb"){
                  dateDelimiter <- '"' 
                }else{
                  dateDelimiter <- "#"
                }
                
                observeEvent(input[[exportButton]],{
                  withProgress(message = textExport09, value = 0, {
                    # Request 3
                    requestExport03 <<- paste0(
                      "SELECT DISTINCT ",
                      station.station_name, " AS station_name, ",
                      observation.recorded_from, " AS recorded_from, ",
                      station.authority, " AS authority,",
                      obs_element.element_name, " AS element_name, ",
                      observation.recorded_at, " AS recorded_at, ",
                      observation.obs_value, " AS obs_value, ",
                      obs_element.element_scale, " AS element_scale, ",
                      obs_element.units, " AS units",
                      " FROM ", obs_element,
                      " INNER JOIN (", station,
                      " INNER JOIN ", observation,
                      " ON ", station.id, " = ", observation.recorded_from, ")",
                      " ON ", obs_element.code, " = ", observation.described_by,
                      " WHERE (((",
                      observation.recorded_at, ")>= ", dateDelimiter, 
                      input[[exportDateRange]][1], dateDelimiter, ")",
                      " AND ((",
                      observation.recorded_at, ")<= ", dateDelimiter, 
                      input[[exportDateRange]][2], dateDelimiter, ")",
                      " AND (",
                      station.id, " IN (", station_id_request,"))",
                      " AND (",
                      obs_element.element_name, " IN (", elements_request,")))",
                      " ORDER BY ", station.station_name,", ",
                      observation.recorded_at,";"
                    )
                    requestExport04 <<- noquote(requestExport03)
                    result <<- getQuery(input[[dbType]],channel2, requestExport04)
                    
                    
                    data2 <- result
                    data3 <- data2
                    if (nrow(data3) > 0){
                      data3$obs_value <- signif(data2$obs_value*signif(data2$element_scale))
                    }
                    data3 <- data3[, !(names(data3) %in% "element_scale")]
                    
                    colnames(data3) <- textExport07
                    
                    uid6 <- substr(UUIDgenerate(), 1, 4)
                    exportTable <- paste0("exportTable_", uid6)
                    exportSaveData <- paste0("exportSaveData_", uid6)
                    # Create Table
                    output[[uiExportTable]] <- renderUI({
                      uiOutputs <- list(
                        DT::dataTableOutput(exportTable),
                        downloadButton(exportSaveData, textExport06)
                      )
                      do.call(tagList,uiOutputs)
                    })
                    
                    output[[exportTable]] <-
                      DT::renderDataTable({data3},
                                          options = list(language = list(
                                            url = paste0('translation/',
                                                         language, '.json'))),
                                          filter = list(position = "top",
                                                        clear = FALSE)
                      )
                    
                    incProgress(1/10)
                    exportTable_rows_all <- paste0(exportTable, "_rows_all")
                    output[[exportSaveData]] <-
                      downloadHandler(
                        filename = function() {textExport08},
                        content = function(file) {
                          ss = input[[exportTable_rows_all]]
                          write.csv(data3[ss, ], file,row.names = FALSE)
                        }
                      )
                    
                  })
                })
              }
            }
          })
          
        }
        
      })
      
    }else{
      output[[uiExport]] <- renderUI({})
    }
  })
  return(output)
  
}

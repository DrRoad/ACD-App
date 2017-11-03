##########################################################################
#' @export climsoft_db_table
#'
#' @title Create a Table
#'
#' @description Creates a table with the data available in a given CLIMSOFT
#' database. It works jointly with \code{\link[ACD]{climsoft_db_map}}, so that
#' the table will show the data available for a station that is previously
#' selected in the Map.
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
#'
climsoft_db_table <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid1 <- substr(UUIDgenerate(), 1, 4)
  tableCheck <- paste0("tableCheck_", uid1)
  # Create a table
  output[[uiTableCheck]] <- renderUI({
    conditionalPanel(
      condition = connectCondition,
      h3(checkboxInput(tableCheck, (textTable00), F)),
      h5(helpText(textTable01))
    )
  })
  
  ##############################################################################
  #
  #                         MAIN PANEL
  #
  ##############################################################################
  # Create new uiOutputs for mainPanel if check Box is TRUE
  observe({
    if (!is.null(input[[tableCheck]]) && (input[[tableCheck]] == T) 
        && openConn(channel2)){
      print("log: Create Table selected")
      observe({
        # If a station has been selected from the map
        if (!is.null(mapMarkerClick) && !is.null(input[[mapMarkerClick]]) 
            && !is.na(input[[mapMarkerClick]]) && openConn(channel2)){
          ######################################################################
          # Create uiOutputs
          output[[uiTable]] <- renderUI({
            uiOutputs <- list(uiOutput("uiTableHeader"),
                              DT::dataTableOutput("table"),
                              uiOutput("uiTableSaveData"),
                              uiOutput("tableBreak"))
            do.call(tagList,uiOutputs)
          })
          
          
          ######################################################################
          # HEADER
          output$uiTableHeader <- renderUI({h3(textTable02)})
          
          ######################################################################
          # REQUEST 1
          input.id <- input[[mapMarkerClick]]$id
          requestTable01 <<-  paste0(
            "SELECT ", observation.recorded_from, " AS recorded_from ,",
            obs_element.element_name, " AS element_name, ",
            observation.described_by, " AS described_by, ",
            observation.recorded_at, " AS recorded_at,  ",
            observation.obs_value, " AS obs_value, ",
            obs_element.element_scale, " AS element_scale ",
            " FROM ", observation,
            " INNER JOIN ", obs_element,
            " ON ", observation.described_by, " = ", obs_element.code,
            " WHERE ", observation.recorded_from, " = '",
            input.id, "'")
          
          df.table <<- getQuery(input[[dbType]], channel2, requestTable01)
          
          df.table$described_by <- as.factor(df.table$described_by)
          if(nrow(df.table)>0){
            df.table$obs_value <- signif(as.numeric(df.table$obs_value)*df.table$element_scale)
          }
          # Remove "element_scale"
          df.table.new <- df.table[,-ncol(df.table)]
          
          # Remove extrange characters
          df.table.new$element_name <- gsub("[][°%]", "", df.table$element_name)
          df.table.new$element_name <- as.factor(df.table.new$element_name)
          
          df.table.new2 <- df.table.new
          colnames(df.table.new2) <- textTable05
          
          # Create Table
          output$table <- DT::renderDataTable(
            {df.table.new2}, filter = list(
              position = "top",
              clear = FALSE),
            options = list(pageLength = 10,
                           language = list(
                             url = paste0('translation/',
                                          language, '.json'))))
          
          ######################################################################
          # Download data
          observe({
            if (!is.null(download_right) && download_right == T){
              output$uiTableSaveData <- renderUI({
                downloadButton("tableSaveData", textTable04)
              })
              output$tableSaveData <- downloadHandler(
                filename = function() { paste(input[[mapMarkerClick]]$id,
                                              '.csv', sep='') },
                content = function(file) {
                  ss = input$table_rows_all
                  write.csv(df.table.new[ss, ], file,row.names = FALSE, sep = ";")
                }
              )
            }else{
              output$uiTableSaveData <- renderUI({HTML("<br/>")})
            }
          })
          # End download data
          ######################################################################
        }else{
          ######################################################################
          # Create uiOutputs
          output[[uiTable]] <- renderUI({
            uiOutputs <- list(uiOutput("uiTableHeader"),
                              uiOutput("uiTableSaveData"),
                              uiOutput("tableBreak"))
            do.call(tagList,uiOutputs)
          })
          # If no station is selected on the map
          output$uiTableHeader <- renderUI({h3(textTable03)})
          output$table <- DT::renderDataTable({})
        }
      })
      output$tableBreak <- renderUI({HTML("<br/>")})
    }else{
      # If Table Check box is not selected
      output[[uiTable]] <- renderUI({})
    }
  })
  return(output)
}

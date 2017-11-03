################################################################################
#' @export local_db
#'
#' @title Display options when LOCAL_FILE is selected
#'
#' @description It displays the options available when LOCAL_FILE is selected as
#' 'Data Source'.
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
#' @details This function will be called by the function
#' \code{\link[ACD]{server.R}}.
#'
################################################################################
local_db <- function(input, output, session){
  library(data.from.climsoft.db)
  detach("package:data.from.climsoft.db")
  library(get.plots.from.ftp)
  library(data.table)
  options(shiny.maxRequestSize=100*1024^2)
  
  ##############################################################################
  #
  #                           CREATE UI OUTPUTS
  #
  ##############################################################################
  uid <- substr(UUIDgenerate(FALSE),1, 4)
  
  # Action Buttons - uiOutputs
  okButtonId <- paste0("action_", uid)
  resetButtonId <- paste0("reset_", uid)
  
  output$UIsActionButtons <-  renderUI({
    conditionalPanel(
      condition = "input.dbase == 'LOCAL_FILE'",
      
      # Create uiOutputs for the "Action Buttons"
      bootstrapPage(
        div(style="display:inline-block",
            actionButton(okButtonId, label = h4(textOKButton))),
        div(style="display:inline-block",
            actionButton(resetButtonId, label = h4(textClearButton)))
      )
    )
  })
  
  # sidePanel - uiOutputs
  output$UIsSidePanel <-  renderUI({
    uiOutputs <- list(uiOutput("uiLoadFiles"),
                      uiOutput("uiPlotsInputs"))
    do.call(tagList, uiOutputs)
  })
  
  # mainPanel - uiOutputs
  # The uiOutputs of the mainPanel are created dinamically (see section of
  # "MAIN PANEL" below)
  
  ##############################################################################
  
  
  ##############################################################################
  #
  #                             SIDE PANEL
  #
  ##############################################################################
  # Load files (uiLoadFiles)
  file_name <- paste0("file1_", uid)
  
  output$uiLoadFiles <- renderUI({
    conditionalPanel(
      condition = "input.dbase == 'LOCAL_FILE'",
      fileInput(file_name, textSidePanel04,
                accept=c('text/csv',
                         'text/comma-separated-values',
                         'text/plain',
                         '.csv'),
                multiple = T),
      helpText(textSidePanel04),
      tags$hr()
    )
  })
  
  ##############################################################################
  # Read file
  observe({
    output$uiMessages <- renderUI({})
    messageMain <<- c("")
    temp <- 1
    if(is.null(input[[file_name]])){
      output$uiPlotsInputs <- renderUI({})
    }else{
      # Create uiOutputs
      output$uiPlotsInputs <- renderUI({
        uiOutputs <- list(
          uiOutput("uiDataSet"),
          uiOutput("uiGraphic"),
          uiOutput("uiWindrose"))
        do.call(tagList,uiOutputs)
      })
      
      # Separators allowed
      separator <- c(";",",","\t","")
      j=0
      
      files <-  input[[file_name]]$datapath
      dateformat <<-  list()
      datetimeperiod <<-  list()
      dd2 <<-  list()
      for (i000 in 1:length(files)){
        local({
          my_i000 <- i000
          tr <-  my_i000
          while(temp == 1){
            j<-j+1
            dd1 <- read.csv(files[my_i000], sep=separator[j])
            temp <- length(dd1)
          }
          
          # Specific for dataset with "abbreviation" as header
          if("abbreviation" %in% names(dd1)){
            var.name <- as.character(unique(dd1$abbreviation))
            if(length(var.name == 1)){
              header.names<-names(dd1)
              pos <- which(header.names == "obs")
              header.names[pos] <- var.name
              colnames(dd1) <- header.names
            }
          }else{
            
            ####################################################################
            # Check labels of dataset ("dd1")
            variables <<-  ident_var(dd1, variables = NULL)
            if(length(variables) == 0){
              messageMain <<- paste(textLocalFile01, textLocalFile02)
              return()
            }else{
              messageMain <<- NULL
            }
          }
          
          ######################################################################
          # Guess date time format of dataset ("dd1")
          df_list <- check_dataframe(dd1)
          if (!is.null(df_list$message)){
            
            messageMain <<-  df_list$message
            output$uiMessages <- renderUI({h5(messageMain)})
            return()
          }else{
            messageMain <<- NULL
          }
          
          # Create new dataset ("dd2")
          dd2[[my_i000]] <<-  df_list$df
          dateformat[[my_i000]] <<-  df_list$dateformat
          datetimeperiod[[my_i000]] <<-  df_list$datetimeperiod
        })
      }
      ##########################################################################
      # Create climate Object (climObj)
      local({
        climObj <<-  climate$new(data_tables= dd2,
                                 date_format = dateformat,
                                 data_time_periods = datetimeperiod)
      })
      
      ##########################################################################
      # Set uiPlotsInputs
      # 1) Graphics
      
      if ("wind_speed" %in% names(variables) &
          "wind_direction" %in% names(variables)){
        graphic_list <<- data.frame("Histogram" = textPlot04,
                                    "Timeseries" = textPlot05,
                                    "Timeseries_comparison" = textPlot06,
                                    "Windrose" = textPlot07)
      }else{
        graphic_list <<- data.frame("Histogram" = textPlot04,
                                    "Timeseries" = textPlot05,
                                    "Timeseries_comparison" = textPlot06)
      }
      graphic_list2 <- as.character(as.matrix(graphic_list))
      output$uiGraphic <- renderUI({
        selectInput("graphic", label = (textPlot08),
                    choices = graphic_list2, selected = graphic_list2[1])
      })
      
      # Create a conditional panel if windrose is selected
      conditionWindrose <- paste0("input['graphic'] == '",
                                  graphic_list$Windrose, "'")
      output$uiWindrose <- renderUI({
        conditionalPanel(conditionWindrose,
                         selectInput("WR.type2",
                                     label = textPlot09,
                                     choices = c("single", "weekday","season",
                                                 "year"),
                                     selected = "single"),
                         radioButtons("ws.units2",
                                      label = textPlot09a,
                                      choices = list("meter/second" = "meters", 
                                                     "knots" = "knots",
                                                     "beaufort" = "bft"), 
                                      inline = TRUE),
                         textInput("wd.scaleFactor2",
                                   label = textPlot09b,
                                   value = "1")
        )
      })
      
      # 2) Datasets
      text <- input[[file_name]]$name
      tr <- c(1:length(text))
      text2 <- paste0( "dataset_",sprintf("%03d", tr))
      h5(helpText("Datasets:"))
      output$uiDataSet <- renderUI({
        uiOutputs <- list(uiOutput("dataSetTitle"),
                          uiOutput("dataSetNames"))
        do.call(tagList, uiOutputs)
      })
      
      output$dataSetTitle <- renderUI({h5(helpText(textLocalFile03))})
      output$dataSetNames <- renderText({
        HTML(paste(paste0(text2,":","<br/>", text, paste = "<br/><br/>"),
                   sep = "<br/>"))
      })
    }
    
    ############################################################################
    # Check if "warnings" are available for the user (messageMain)
    if (!is.null(messageMain)){
      # uiOutputs when messageMain is available
      output$uiMessages <- renderUI({h5(messageMain)})
      output$uiPlotsInputs <- renderUI({})
      output$UIsMainPanel <- renderUI({})
      
      # Disable "OK" button
      session$sendCustomMessage(
        type = "jsCode",list(code = paste0("$('#", okButtonId,
                                           "').prop('disabled',true)")))
    }else{
      # Enable "OK" button
      session$sendCustomMessage(
        type = "jsCode",list(code = paste0("$('#", okButtonId,
                                           "').prop('disabled',false)")))
    }
  })
  
  ##############################################################################
  #
  #                       MAIN PANEL
  #
  ##############################################################################
  # Main Panel
  
  observeEvent(input[[okButtonId]],{
    # Create uiOutputs for the "mainpanel"
    uid2 <- substr(UUIDgenerate(FALSE),1, 4)
    uiPlots <- paste0("uiPlots_", uid2)
    output$UIsMainPanel <- renderUI({
      uiOutputs <- list(uiOutput(uiPlots))
      do.call(tagList, uiOutputs)
    })
    #})
    
    # Get the right graphic name
    graphic_name.prev <- input$graphic
    id0 <- which(graphic_list == graphic_name.prev)
    graphic_name <- colnames(graphic_list[id0])
    print(graphic_name)
    
    # Create "Making plots" bar
    withProgress(message = textPlot12, value = 0, {
      n <- 10
      for (i in 1:n) {
        local({
          my_i <- i
          incProgress(1/n)
          Sys.sleep(0.1)
          if (my_i==1){
            # Create the plots
            output[[uiPlots]] <- renderUI({
              uiOutputs <- list(uiOutput("uiPlotsHeader"),
                                uiOutput("uiOutputs"))
              do.call(tagList, uiOutputs)
            })
            output$uiPlotsHeader <- renderUI({h3(textPlot13)})
            # isolate({
            if (!is.null(graphic_list$Windrose) && input$graphic == graphic_list$Windrose){
              wr_inputs <<- data.frame(wr_type = input$WR.type2,
                                       ws_units = input$ws.units2,
                                       wd_scaleFactor = input$wd.scaleFactor2,
                                       stringsAsFactors = F)
              
              
            }else{
              wr_inputs <<- NULL
            }
            output <- climObj$shiny_server(input,output,
                                           selected_plot = graphic_name, 
                                           wr_inputs, "uiOutputs")
            #})
          }
        })
      }
    })
  })
  
  ##############################################################################
  #
  #                       ACTION BUTTONS
  #
  ##############################################################################
  # Clear button
  observeEvent(input[[resetButtonId]],{
    rm(list= ls(all=TRUE)[!(ls() %in% c('input','output'))])
    output$uiMessages <- renderUI({})
    output$uiPlotsInputs <- renderUI({})
    output$UIsMainPanel <- renderUI({})
    output$uiLoadFiles <- renderUI({
      conditionalPanel(
        condition = "input.dbase == 'LOCAL_FILE'",
        fileInput(file_name, textSidePanel04,
                  accept=c('text/csv',
                           'text/comma-separated-values',
                           'text/plain',
                           '.csv'),
                  multiple = T),
        helpText(textSidePanel05),
        tags$hr()
      )
    })
    
    # Disable "OK" button
    session$sendCustomMessage(
      type = "jsCode",list(code = paste0("$('#", okButtonId,
                                         "').prop('disabled',true)")))
    # Reset "fileInput"
    session$sendCustomMessage(type = "resetFileInputHandler", file_name)
  })
  return(output)
}

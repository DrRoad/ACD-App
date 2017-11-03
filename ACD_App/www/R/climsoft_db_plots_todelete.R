################################################################################
#' @export climsoft_db_plots
#'
#' @title Create Plots
#'
#' @description Creates Plots using the data available in a given
#' CLIMSOFT database.
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
#' @details This function runs when the functions
#' \code{\link[ACD]{climsoft_db_access}} and
#' \code{\link[ACD]{climsoft_db_mariadb}} are called.
#' 
################################################################################

climsoft_db_plots_todelete <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  data_tables <- list(list())
  date_format <- list(list())
  data_time_period <- list(list())
  df <- list()
  
  uid1 <- substr(UUIDgenerate(), 1, 4)
  uiPlotsInputs <- paste0("uiPlotsInputs_", uid1)
  plotsCheck <<- paste0("plotsCheck_", uid1)
  output[[uiPlotsCheck]] <- renderUI({
    uiOutputs <- list(
      conditionalPanel(condition = connectCondition,
                       h3(checkboxInput(plotsCheck, (textPlot00), F)),
                       h5(helpText(textPlot01))),
      uiOutput(uiPlotsInputs)
    )
    do.call(tagList, uiOutputs)
  })

  # Create new uiOutputs for sidePanel if check Box is TRUE
  observe({
    if (!is.null(input[[plotsCheck]]) && (input[[plotsCheck]] == T) 
        && openConn(channel2)){
      print("log: Create Graphics selected")
      # Create uiOutputs
      uid4 <- substr(UUIDgenerate(), 1, 4)
      uiStationId <- paste0("uiStationId", uid4)
      uiElement <- paste0("uiElement", uid4)
      uiGraphic <- paste0("uiGraphic", uid4)
      uiWindrose <- paste0("uiWindrose", uid4)
      uiDateRange <- paste0("uiDateRange", uid4)
      uiPlotsButtons <- paste0("uiPlotsButtons", uid4)
      output[[uiPlotsInputs]] <- renderUI({
        uiOutputs <- list(uiOutput(uiStationId),
                          uiOutput(uiElement),
                          uiOutput(uiGraphic),
                          uiOutput(uiWindrose),
                          uiOutput(uiDateRange),
                          uiOutput(uiPlotsButtons))
        do.call(tagList,uiOutputs)
      })

      ##########################################################################
      # Station ID
      ptm <- proc.time()

      ##########################################################################
      # REQUEST 1
      requestPlot01 <- paste0("SELECT DISTINCT ",
                              station.id, " AS id, ",
                              station.station_name, " AS station_name ",
                              "FROM ", station, " INNER JOIN ", observation, 
                              " ON ", station.id, 
                              " = ", observation.recorded_from,
                              " ORDER BY ", station.station_name, ";")
      result <- getQuery(input[[dbType]], channel2, requestPlot01)

      ##########################################################################
      station_id <- unique(as.character(as.matrix(result$id)))
      station_id_list <<- as.vector(apply(result, 1, paste, collapse = " - "))
      if (exists("mapMarkerClick") && !is.null(mapMarkerClick)){
        station_selected <- station_id_list[
          which(station_id == input[[mapMarkerClick]]$id)]
      }else{
        station_selected <- NULL
      }
      stationId <<- paste0("stationId_", uid4)
      output[[uiStationId]] <- renderUI({
        selectInput(stationId, label = textPlot02,multiple = T,
                    choices = station_id_list,
                    selected = station_selected)

      })

      ##########################################################################
      # Element
      observe({
        if (!is.null(input[[stationId]]) && openConn(channel2)){
          tr <- input[[stationId]]
          station_id_new <- unlist(lapply(1:length(tr), function(i) {
            strsplit(tr[i], " - ")[[1]][1]
          }))
          if (length(tr)>1){
            station_id_request <<- paste0("'", station_id_new, "'", 
                                          collapse =", ")
            #sh5("Selection of an Element is not possible")
            request <<- paste0("SELECT DISTINCT ",
                              obs_element.element_name, " AS element_name ",
                              " FROM ", obs_element,
                              " INNER JOIN ", observation,
                              " ON ", obs_element.code, 
                              " = ", observation.described_by,
                              " WHERE ", observation.recorded_from, " IN (",
                              station_id_request, ");")

          }else{
            station_id_new <- strsplit(input[[stationId]]," - ")[[1]][1]
            request <<- paste0("SELECT DISTINCT ",
                              obs_element.element_name , " AS element_name ",
                              " FROM ", obs_element,
                              " INNER JOIN ", observation ,
                              " ON ", obs_element.code, 
                              " = ", observation.described_by,
                              " WHERE ", observation.recorded_from, " = '",
                              station_id_new,"';")
          }
          dbtype <- input[[dbType]]
          result <<- getQuery(input[[dbType]], channel2, request)
          element.names <<- sort(unique(as.character(result$element_name)))
        }else{
          element.names <<- NULL
        }

        output[[uiElement]] <- renderUI({
          selectInput("elementName",
                      label = (textPlot03),
                      choices = element.names,
                      #selected = "Temp; daily max",
                      multiple = TRUE)

        })
      })

      ##########################################################################
      # Graphics
      graphic_list <<- data.frame("Histogram" = textPlot04,
                                 "Timeseries" = textPlot05,
                                 "Timeseries_comparison" = textPlot06,
                                 "Windrose" = textPlot07)
      graphic_list2 <- as.character(as.matrix(graphic_list))
      output[[uiGraphic]] <- renderUI({
        selectInput("graphic",
                    label = (textPlot08),
                    choices = graphic_list2,
                    selected = graphic_list2[1])
      })

      # Create a conditional panel if windrose is selected
      conditionWindrose <- paste0("input['graphic'] == '",
                                  graphic_list$Windrose, "'")
      output[[uiWindrose]] <- renderUI({
        conditionalPanel(conditionWindrose,
                         selectInput("WR.type",
                                     label = textPlot09,
                                     choices = c("single", "weekday","season",
                                                 "year"),
                                     selected = "single")
        )
      })

      ##########################################################################
      # Date range
      output[[uiDateRange]] <- renderUI({
        dateRangeInput("dates", label = textPlot10, start = "1800-01-01")
      })

      ##########################################################################
      # Action buttons
      uid3 <- substr(UUIDgenerate(), 1, 4)
      okButtonId <- paste0("action_", uid3)

      output[[uiPlotsButtons]] <-  renderUI({
        conditionalPanel(
          condition = connectCondition,
          # Create uiOutputs for the "Action Buttons"
          bootstrapPage(
            div(style="display:inline-block",
                actionButton(okButtonId, label = h4("OK")))
          )
        )
      })

      ##########################################################################
      #
      #                         MAIN PANEL
      #
      ##########################################################################
      observeEvent(input[[okButtonId]], {
        # Get the right graphic name
        graphic_name.prev <- input$graphic
        id0 <- which(graphic_list == graphic_name.prev)
        graphic_name <- colnames(graphic_list[id0])
        print(graphic_name)

        # Create uiOutputs for the "mainpanel"
        uid2 <- substr(UUIDgenerate(FALSE), 1, 4)
        uiPlotsTest <- paste0("uiPlotsTest_", uid2)
        uiOutputs <<- paste0("uiOutputs_", uid2)
        output[[uiPlots]] <- renderUI({
          uiOutputs <- list(uiOutput(uiPlotsTest))
          do.call(tagList, uiOutputs)
        })
        output[[uiPlotsTest]] <- renderUI({
          uiOutputs <- list(uiOutput("uiPlotsHeader"),
                            uiOutput(uiOutputs),
                            uiOutput("plotsBreak"))
          do.call(tagList, uiOutputs)
        })

        if (is.null(input$elementName)){
          output$uiPlotsHeader <- renderUI({h3(textPlot11)})
          output[[uiOutputs]] <- renderUI({})
          output$plotsBreak <- renderUI({})
          return()
        }else{
          # Create "Making plots" bar
          withProgress(message = textPlot12, value = 0, {
            n <- 10
            for (i in 1:n) {
              local({
                my_i <- i
                incProgress(1/n)
                Sys.sleep(0.1)
                
                if (my_i==1){
                  
                  output$uiPlotsHeader <- renderUI({h3(textPlot13)})
                  element_names <<- input$elementName
                  station_ids <<- input$stationId
                  
                  ftp_data <<- get_climsoft_data(input, output)
                  climObj_prev <- list()
                  
                  if (length(ftp_data)==0){
                    
                    output[[uiMessages]] <- renderUI({h4(textPlot17)})
                    return()
                  }
                  
                  # for (station_data in ftp_data){
                  for (j0 in 1:length(ftp_data)){
                    
                    for (i0 in 1:length(element_names)){
                      
                      if ((nrow(ftp_data[[j0]]$ftp_data[[i0]]$data) == 0) ||
                          (is.null(ftp_data[[j0]]$ftp_data[[i0]]$data)) ||
                          !(element_names[i0] %in% colnames(ftp_data[[j0]]$ftp_data[[i0]]$data))){
                        # output[[uiMessage]] <- renderUI({h4("No data available")})
                      }else{
                        
                        metadata <- ftp_data[[j0]]$ftp_data[[i0]]$metadata
                        metadata2 <<- metadata
                        data2 <<- ftp_data[[j0]]$ftp_data[[i0]]$data
                        changes2 <<- ftp_data[[j0]]$ftp_data[[i0]]$changes
                        
#                         tmp.file <- get_tmp_file_name(metadata[[5]], metadata[[6]], metadata[[7]], element_names[i0], metadata[[4]])
#                         
                        # check for duplicated entries in dataframe
                        df_list <<- check_dataframe(data2)
                        
                        if (!is.null(df_list$message)){
                          
                          messageMain <<-  df_list$message
                          output$uiMessages <- renderUI({h5(messageMain)})
                          return()
                          
                        }else{
                          
                          messageMain <<- NULL
                        }
                        
                        # create climobject
                        climObj_prev[[i0]] <- get_climObj(metadata, data2, changes2)
                        climObj_prev[[i0]] <- climObj_prev[!sapply(climObj_prev, is.null)]
                        
                        if (length(climObj_prev)==0){
                          
                          output[[uiMessages]] <- renderUI({h4(textPlot18)})
                          return()
                        }
                        
                        # real dynamic list growing is not possible, only if we initalize the new list element with empty list
                        # before using. ( e.g. data_tables[[2]][[1]] )
                        if (j0 > 1 && i0 == 1){
                          data_tables[[j0]] <- list(list())
                          date_format[[j0]] <- list(list())
                          data_time_period[[j0]] <- list(list())
                        }
                        
                        data_tables[[j0]][[i0]]      <- climObj_prev[[i0]][[i0]]$climate_data_objects[[1]]$data
                        date_format[[j0]][[1]]      <- climObj_prev[[i0]][[i0]]$climate_data_objects[[1]]$date_format
                        data_time_period[[j0]][[1]] <- climObj_prev[[i0]][[i0]]$climate_data_objects[[1]]$data_time_period
                      }
                      
                    } # for (i0 in 1:length(element_names))
                    
                    data_tables <- data_tables[ ! sapply(data_tables, is.null) ]
                    df[[j0]] <- join_all(data_tables[[j0]],by = 'mess_datum', type = 'full')
                  } # for (j0 in 1:length(ftp_data))
                  
                  date_format_new      <- do.call(list, unlist(date_format, recursive=FALSE))
                  data_time_period_new <- do.call(list, unlist(data_time_period, recursive=FALSE))
                  df2 <<- df
                  climObj <<- climate$new(data_tables = df,
                                          date_format = date_format_new,
                                          data_time_periods = data_time_period_new)
                  
                  output <- climObj$shiny_server(input, output,
                                                 selected_plot = graphic_name,
                                                 uiOutputs = uiOutputs)
                }
                
                
#                 if (my_i==1){
#                   output$uiPlotsHeader <- renderUI({h3(textPlot13)})
#                   element_names <<- input$elementName
# 
#                   ftp_data <<- get_climsoft_data(input, output)
#                   j <- 0
#                   df <- list()
#                   dateformat <- list()
#                   datatimeperiod <- list()
#                   for (i00 in 1:length(ftp_data)){
#                     for (i0 in 1:length(element_names)){
#                       metadata2 <<- ftp_data[[i00]][[i0]]$metadata
#                       data2 <<- ftp_data[[i00]][[i0]]$data
#                       changes <<- ftp_data[[i00]][[i0]]$changes
# 
#                       if (!is.null(data2)){
#                         j <- j+1
#                         # Check the dataset
#                         df_list <- check_dataframe(data2)
#                         df[[j]] <- df_list$df
#                         dateformat[[j]] <- df_list$dateformat
#                         datatimeperiod[[j]] <- df_list$datetimeperiod
#                       }
#                     }
#                   }
#                   climObj <<- climate(data_tables = df,
#                                       date_formats = dateformat,
#                                       data_time_periods = datatimeperiod)
# 
#                   output <- climObj$shiny_server(input, output,
#                                                  selected_plot = graphic_name,
#                                                  uiOutputs = uiOutputs)
#                 }
              })
            }
            output$plotsBreak <- renderUI({HTML("<br/>")})
          })
          return()
        }
      })
    }
  })

  ##############################################################################
  # Remove plots if check Box is FALSE
  observe({
    if (!is.null(input[[plotsCheck]]) && (input[[plotsCheck]] == F)){
      output[[uiPlotsInputs]] <- renderUI({})
      uid3 <- substr(UUIDgenerate(FALSE),1, 4)
      uiPlotsTest <- paste0("uiPlotsTest_", uid3)
      output[[uiPlots]] <- renderUI({
        uiOutputs <- list(uiOutput(uiPlotsTest))
        do.call(tagList, uiOutputs)
      })
      output$uiPlotsHeader <- renderUI({})
      output$plotsBreak <- renderUI({})
    }
  })

  observe({
    if (!is.null(input[[plotsCheck]]) && (input[[plotsCheck]] == F) 
        && (exists("uiStationId"))){
      output[[uiStationId]] <- renderUI({})

    }
  })
  return(output)
}

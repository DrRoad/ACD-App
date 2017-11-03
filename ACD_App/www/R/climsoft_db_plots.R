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

climsoft_db_plots <- function(input, output, session){
  
  ##############################################################################
  #   
  #                     DEFAULTS
  # 
  ##############################################################################
  data_tables <- list(list())
  date_format <- list(list())
  data_time_period <- list(list())
  data_tables_station <- list()
  date_format_station <- list()
  data_time_period_station <- list()
  df <- list()
  climObj <- NULL
  bNodata <- F
  
  
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  
  
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
        uiMessages2 <<- paste0("uiMessages2_", uid)
        output[[uiPlots]] <- renderUI({
          uiOutputs <- list(uiOutput(uiPlotsTest), uiOutput(uiMessages2))
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
                  #                   output[[uiMessages]] <- renderUI({h4(NULL)})
                  #                   output$uiMessages <- renderUI({h5(NULL)})
                  messageMain <<- NULL
                  tttt <<- input[[stationId]]
                  station_ids <<- input[[stationId]]
                  print(station_ids)
                  element_names <<- input$elementName
                  time_resol <<- input$timeResol
                  begin_date <<- input[[uiDateRange]][1]
                  end_date <<- input[[uiDateRange]][2]
                  graphic_type <<- input$graphic
                  change <<- input$change
                  
                  length.stations <<- length(station_ids)
                  length.elements <<- length(element_names)
                  
                  ##############################################################
                  # BY STATION
                  climObj <- NULL
                  for (j0 in 1:length.stations){
                    print(paste0("log: Station Nr.: ",j0))
                    climObj_prev <- list()
                    ftp_data_prev <- get_climsoft_data(input, output)
                    ftp_data <<- ftp_data_prev[[j0]]$ftp_data
                    
                    ############################################################
                    # BY ELEMENT
                    for (i0 in 1:length.elements){
                      print(paste0("log: Element Nr.: ",i0))
                      bNodata <- F
                      
                      if (is.null(ftp_data) ||
                          length(ftp_data) == 0 ||
                          i0 > length(ftp_data) ||
                          (nrow(ftp_data[[i0]]$data) == 0) ||
                          (is.null(ftp_data[[i0]]$data)) ||
                          !(element_names[i0] %in% colnames(ftp_data[[i0]]$data))){
                        bNodata <- T
                        print(paste0("No data available for element: ", element_names[i0]))
                        climObj_prev[[i0]] <- NULL
                      }else{
                        print(paste0("Data available for element: ", element_names[i0]))
                        metadata <- ftp_data[[i0]]$metadata
                        metadata2 <<- metadata
                        data2 <<- ftp_data[[i0]]$data
                        changes2 <<- ftp_data[[i0]]$changes
                        
                        #############################################
                        # check for duplicated entries in dataframe
                        df_list <<- check_dataframe(data2)
                        
                        if (!is.null(df_list$message)){
                          messageMain <<-  df_list$message
                          output$uiMessages <- renderUI({h5(messageMain)})
                          climObj_prev[[i0]] <- NULL
                          #return()
                        }else{
                          #create Temp ClimObject
                          climObj_prev[[i0]] <- climate(
                            data_tables = list(df_list$df), 
                            date_formats = list(df_list$dateformat),
                            data_time_periods = list(df_list$datetimeperiod))
                          print("climObj_prev created")
                        }
                        
                        #climObj_prev[[i0]] <- climObj_prev[!sapply(climObj_prev, is.null)]
                        
                        if (length(climObj_prev)==0){
                          print("log: climObj_prev is empty. Not possible to create plots")
                          output[[uiMessages]] <- renderUI({h4(textPlot18)})
                          return()
                        }
                        
                        data_tables <- list()
                        date_format <- list()
                        data_time_period <- list()
                        
                        data_tables      <- lapply(climObj_prev, function(x) x$climate_data_objects[[1]]$data)
                        date_format      <- lapply(climObj_prev, function(x) x$climate_data_objects[[1]]$date_format)
                        data_time_period <- lapply(climObj_prev, function(x) x$climate_data_objects[[1]]$data_time_period)
                        
                        # Remove null lists
                        data_tables <- data_tables[ ! sapply(data_tables, is.null) ]
                        date_format <- date_format[ ! sapply(date_format, is.null)]
                        data_time_period <- data_time_period[ ! sapply(data_time_period, is.null)]
                        
                        data_tables_station[[j0]]      <- data_tables
                        date_format_station[[j0]]      <- date_format
                        data_time_period_station[[j0]] <- data_time_period
                        
                        
                        #                         dtaat <<- climObj_prev[[i0]]$climate_data_objects[[1]]$data
                        #                         data_tables[[j0]][[i0]]      <- climObj_prev[[i0]]$climate_data_objects[[1]]$data
                        #                         date_format[[j0]][[i0]]      <- climObj_prev[[i0]]$climate_data_objects[[1]]$date_format
                        #                         data_time_period[[j0]][[i0]] <- climObj_prev[[i0]]$climate_data_objects[[1]]$data_time_period
                      }
                      
                    }#for (i0 in 1:length(element_names))
                    
                    
                    
                    data_tables <- data_tables[ ! sapply(data_tables, is.null) ]
                    #                   df[[j0]] <- join_all(data_tables[[j0]],by = 'mess_datum', type = 'full')
                    #                   date_format_station[[j0]] <- as.character(as.matrix(join_all(date_format[[j0]])))
                    #                   data_time_period_station[[j0]] <- as.character(as.matrix(join_all(data_time_period[[j0]])))
                    
                    
                  }#for (j0 in 1:length(station_ids))
                  ftp_data_todelete <<- ftp_data
                  
                  
                }
                
                
                
                ftp_data_todelete <<- ftp_data
                
                date_format_station2 <<- unlist(date_format_station, recursive = F)
                data_time_period_station2 <<- unlist(data_time_period_station, recursive = F)
                data_tables_station2 <<- unlist(data_tables_station, recursive =  F)
                df <- data_tables_station2
                
                
                
                # No data for station
                if (is.null(climObj) && length(df) == 0){
                  #output[[uiMessages2]] <- renderUI({h4(textPlot18)})
                  return()
                } 
                
                if (is.null(climObj)){
                  
                  ##############################################################
                  #
                  #                       WINDROSE SOLUTION
                  #
                  ##############################################################
                  # Note: This solution should allow plotting "Windroses". 
                  # However, this is only the case if only ONE station and only
                  # TWO elements (wind_dir & wind_speed) are selected.
                  # This code assumes that both elements have the same time_period
                  # and date format.
                  ##############################################################
                  
                  # Check if windrose has been selected. If so, the data 
                  # have to be reorganized
                  #observe({
                  if (!is.null(graphic_list$Windrose) && input$graphic == graphic_list$Windrose){
                    print("Re-organizing the data")
                    if (length(df) == 2 && length(station_ids) == 1){
                      ##########################################################
                      # First element
                      climObj_wind1 <- climate(data_tables = list(data_tables_station2[[1]]),
                                               data_time_periods = list(data_time_period_station2[[1]]),
                                               date_formats = list(date_format_station2[[1]]))
                      data_wind1 <- climObj_wind1$climate_data_objects$data_set_001$data
                      # Rename the wind variable
                      name_label1 <- names(climObj_wind1$climate_data_objects$data_set_001$get_var_labels())
                      new_name1 <- unlist(get(name_label1))
                      old_name1 <- unlist(climObj_wind1$climate_data_objects$data_set_001$get_variables()[[new_name1]])
                      # Replace th headers
                      id00 <- grep(old_name1, colnames(data_wind1))
                      colnames(data_wind1)[id00] <- new_name1
                      
                      ##########################################################
                      # Second element
                      climObj_wind2 <- climate(data_tables = list(data_tables_station2[[2]]),
                                               data_time_periods = list(data_time_period_station2[[2]]),
                                               date_formats = list(date_format_station2[[2]]))
                      data_wind2 <- climObj_wind2$climate_data_objects$data_set_001$data
                      
                      # Rename the wind variable
                      name_label2 <- names(climObj_wind2$climate_data_objects$data_set_001$get_var_labels())
                      new_name2 <- unlist(get(name_label2))
                      old_name2 <- unlist(climObj_wind2$climate_data_objects$data_set_001$get_variables()[[new_name2]])
                      # Replace th headers
                      id00 <- grep(old_name2, colnames(data_wind2))
                      colnames(data_wind2)[id00] <- new_name2
                      
                      ##########################################################
                      # Merge both elements in one data.frame
                      # Check if "data_wind1" & "data_wind2" have the same length
                      if (nrow(data_wind1) == nrow(data_wind2)){
                        print("Proceeding to merge both datasets")
                        data_wind <- data.frame(data_wind1, data_wind2[,id00])
                        colnames(data_wind)[ncol(data_wind)] <- new_name2
                        
                        ########################################################
                        # Create new climObj
                        climObj <- climate(data_tables = list(data_wind), 
                                           data_time_periods = list(data_time_period_station2[[1]]),
                                           date_formats = list(date_format_station2[[1]]))
                      }else{
                        print("Not possible to merge both datasets")
                        return()
                      }
                    }else{
                      print("Not able to create windrose")
                      return()
                    }
                  ##############################################################
                  #
                  #                     END OF WINDROSE SOLUTION
                  #
                  ##############################################################
                  }else{
                    #})
                    # if more than 1 element or station is selected create climObj
                    # No changes will be shown
                    
                    # Remove NULL elements of the list
                    #                   df <- df[ ! sapply(df, is.null) ]
                    #                   df_date_format <- date_format_station[! sapply(date_format_station, is.null)]
                    #                   dfdata_time_periods <- data_time_period_station[! sapply(data_time_period_station, is.null)]
                    #                   date_format_station <- date_format_station[ ! sapply(date_format_station, is.null)]
                    #                   data_time_period_station <- data_time_period_station[ ! sapply(data_time_period_station, is.null)]
                    #                   
                    #                   date_format_station <- lapply(date_format_station, function(x){
                    #                     if (is.null(x)) x <- ""
                    #                     return(x)
                    #                   })
                    
                    #                   data_time_period_station <- lapply(data_time_period_station, function(x){
                    #                     if (is.null(x)) x <- ""
                    #                     return(x)
                    #                   })
                    
                    climObj <- climate$new(data_tables = df,
                                           date_formats = date_format_station2,
                                           data_time_periods = data_time_period_station2)
                  }
                }
                climObj2 <<- climObj
                
                
                if (!is.null(graphic_list$Windrose) && input$graphic == graphic_list$Windrose){
                  wr_inputs <<- data.frame(wr_type = input$WR.type2,
                                           ws_units = input$ws.units2,
                                           wd_scaleFactor = input$wd.scaleFactor2,
                                           stringsAsFactors = F)
                  
                  
                }else{
                  wr_inputs <<- NULL
                }
                output <- climObj2$shiny_server(input,output,
                                               selected_plot = graphic_name, 
                                               wr_inputs, uiOutputs)
                
                #output <- climObj$shiny_server(input, output,
                #                               selected_plot = graphic_name,
                #                               uiOutputs = uiOutputs)
              })
            }
          })
        }
      })
    }else{
      return()
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

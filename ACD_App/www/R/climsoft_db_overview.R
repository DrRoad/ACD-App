################################################################################
#' @export climsoft_db_overview
#'
#' @title Create an Overviow of Database
#'
#' @description Creates an overview of the data available in a given
#' Climsoft database.
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

climsoft_db_overview <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid <- substr(UUIDgenerate(), 1, 4)
  viewCheckId <- paste0("viewCheckId", uid)
  output[[uiViewCheck]] <- renderUI({
    conditionalPanel(
      condition = connectCondition,
      h3(checkboxInput(viewCheckId, (textOverview00), F)),
      h5(helpText(textOverview01))
    )
  })
  
  ##############################################################################
  #
  #                         MAIN PANEL
  #
  ##############################################################################
  
  observe({
    if (!is.null(input[[viewCheckId]]) && (input[[viewCheckId]] == T) 
        && openConn(channel2)){
      print("log: Create Overview selected")
      withProgress(message = textOverview02, value = 0, {
        ##########################################################################
        #
        #                             GENERAL OVERVIEW
        #
        ##########################################################################
        output[[uiView]] <- renderUI({
          Tabs1 <- lapply(1:3,function(i){
            tabs1_name <- h3(textOverview04[i])
            tabs2_id <- paste0(uiView, "2",i)
            tabPanel(tabs1_name,uiOutput(tabs2_id))
          })
          do.call(tabsetPanel,Tabs1)
        })
        
        uiView2 <- paste0(uiView, "21")
        output[[uiView2]] <- renderUI({
          uiOutputs <- list(uiOutput("uiViewHeader"),
                            DT::dataTableOutput("view"),
                            uiOutput("uiViewSaveData"),
                            uiOutput("viewBreak"))
          do.call(tagList,uiOutputs)
        })
        
        request10 <- paste0("SELECT DISTINCT ",
                            observation.recorded_from, " AS recorded_from",
                            " FROM ", observation)
        result10 <- getQuery(input[[dbType]], channel2, request10)
        
        request11 <- paste0("SELECT ",
                            station.id, " AS id, ",
                            station.station_name, " AS station_name, ",
                            station.authority, " AS authority, ",
                            station.country, " AS country, ",
                            station.district, " AS district ",
                            " FROM ", station, ";")
        result11 <- getQuery(input[[dbType]], channel2, request11)
        id10 <- which(result11$id %in% result10$recorded_from)
        sources <- as.character(unique(result11$authority[id10]))
        sources[is.na(sources)] <- "N.A."
        
        df <- result11
        df$authority <- as.character(df$authority)
        df$authority[is.na(df$authority)] <- "N.A."
        
        data2 <- data.frame()
        for (i1 in 1:length(sources)){
          incProgress(1/length(sources))
          id1 <- which(df$authority == sources[i1])
          station_ids <- df$id[id1]
          station_id_request <- paste0("'", station_ids, "'", collapse =", ")
          request <- paste0("SELECT DISTINCT ",
                            obs_element.element_name, " AS element_name, ",
                            obs_element.code, " AS code ",
                            " FROM ", obs_element,
                            " INNER JOIN ", observation,
                            " ON ", obs_element.code, 
                            " = ", observation.described_by,
                            " WHERE ", observation.recorded_from,
                            " IN (", station_id_request, ");")
          result1 <- getQuery(input[[dbType]],channel2, request)
          if (length(result1)>0){
            codes <- result1$code
            for (i2 in 1:nrow(result1)){
              request <- paste0("SELECT ",
                                observation.recorded_from, " AS recorded_from, ",
                                observation.described_by, " AS described_by, ",
                                "MIN(", observation.recorded_at, ") AS min_date, ",
                                "MAX(", observation.recorded_at, ") AS max_date, ",
                                "COUNT(", observation.obs_value, ") AS number_records, ",
                                obs_element.element_name, " AS element_name",
                                " FROM ", obs_element,
                                " INNER JOIN ",observation,
                                " ON ", obs_element.code, " = ", observation.described_by,
                                " GROUP BY ", observation.recorded_from, ", ",
                                observation.described_by, ", ",
                                obs_element.element_name,
                                " HAVING (((", observation.recorded_from, ")",
                                " IN (", station_id_request, "))",
                                " AND ((", observation.described_by, ") = ", codes[i2], "))",
                                " ORDER BY MIN(",observation.recorded_at, "), ",
                                " MAX(", observation.recorded_at, ");")
              
              result14 <- getQuery(input[[dbType]],channel2,request)
              
              element_available <- unique(result14$element_name)
              number_of_stations <- nrow(result14)
              date_of_first_record <- as.character(min(as.POSIXct(result14$min_date,tz= "UTC")))
              date_of_end_record <- as.character(max(as.POSIXct(result14$max_date,tz= "UTC")))
              
              # find which station had the maximum number of records
              max_number_records <- max(result14$number_records)
              id101 <- which(result14$number_records == max_number_records)
              station_max_records <- paste(result14$recorded_from[id101], collapse = ", ")
              data1 <- data.frame(source = sources[i1],element_available,number_of_stations,
                                  date_of_first_record,date_of_end_record,
                                  max_number_records =
                                    paste0(max_number_records, " (",station_max_records,
                                           ")"))
              data2 <- rbind(data2,data1)
            }
          }
        }
        data3 <- data2
        data3$date_of_first_record <- as.Date(data3$date_of_first_record)
        data3$date_of_end_record <- as.Date(data3$date_of_end_record)
        colnames(data3) <- textOverview06
        
        # Create Table
        output$view <- DT::renderDataTable({data3},
                                           options = list(language = list(
                                             url = paste0('translation/',
                                                          language, '.json'))),
                                           rownames = FALSE,
                                           filter = list(position = "top",
                                                         clear = FALSE)
        )
        
        ########################################################################
        # Download data
        observe({
          if (!is.null(download_right) && download_right == T){
            output$uiViewSaveData <- renderUI({
              downloadButton("viewSaveData", textTable04)
            })
            output$viewSaveData <- downloadHandler(
              filename = function() { textOverview05},
              content = function(file) {
                ss = input$view_rows_all
                write.csv(data3[ss, ], file,row.names = FALSE)
              }
            )
          }else{
            output$uiViewSaveData <- renderUI({HTML("<br/>")})
          }
        })
        # End download data
        ########################################################################
        output$viewBreak <- renderUI({HTML("<br/>")})
      })
      
      ##########################################################################
      #
      #                             OVERVIEW BY STATION
      #
      ##########################################################################
      uiView2 <- paste0(uiView, "22")
      output[[uiView2]] <- renderUI({
        uiOutputs <- list(uiOutput("uiViewHeader2"),
                          DT::dataTableOutput("view2"),
                          uiOutput("uiViewSaveData2"),
                          uiOutput("viewBreak2"))
        do.call(tagList,uiOutputs)
      })
      
      # Requests
      requestOverview <- paste0("SELECT ",
                                station.station_name, " AS station_name,",
                                observation.recorded_from, " AS recorded_from,",
                                obs_element.element_name, " AS element_name,",
                                "LCASE(",obs_element.element_type, ") AS element_type,",
                                " Min(", observation.recorded_at, ") AS min_recorded_at,",
                                " Max(", observation.recorded_at, ") AS max_recorded_at,",
                                " Count(", observation.obs_value, ") AS number_records ",
                                " FROM ", obs_element ,
                                " INNER JOIN (", station, " INNER JOIN ", observation, " ON ",
                                station.id, " = ", observation.recorded_from, ") ON ",
                                obs_element.code, " = ", observation.described_by,
                                " GROUP BY ", station.station_name,",",
                                observation.recorded_from, ",",
                                obs_element.element_name, ",",
                                obs_element.element_type,
                                " ORDER BY ", station.station_name,";")
      
      result12 <- getQuery(input[[dbType]], channel2, requestOverview)
      
      if (nrow(result12)>0){
        data4 <- result12
        data4$percent_records <- NA
        for (i in 1:nrow(data4)){
          if (data4$element_type[i] == "monthly"){
            data_time_interval <- "1 month"
          }else if (data4$element_name[i] == "daily"){
            data_time_interval <- "1 day"
          }else if (data4$element_name[i] == "hourly"){
            data_time_interval <- "1 hour"
          }else{
            data_time_interval <- NA
          }
          if (is.na(data_time_interval)){
            available_values <- NA
          }else{
            full <- seq.POSIXt(data4$min_recorded_at[i], data4$max_recorded_at[i], by = data_time_interval)
            
            number_records <- as.numeric(data4$number_records[i])
            number_expected_records <- as.numeric(length(full))
            missing_values <- round((1-(number_records/number_expected_records))*100,1)
            available_values <- round(100-missing_values)
          }
          data4$percent_records[i] <- available_values
        }
        colnames(data4) <- textOverview07
        output$view2 <- DT::renderDataTable({data4},
                                            options = list(language = list(
                                              url = paste0('translation/',
                                                           language, '.json'))),
                                            rownames = FALSE,
                                            filter = list(position = "top",
                                                          clear = FALSE)
        )
      }
      
      ##########################################################################
      # Download data
      observe({
        if (!is.null(download_right) && download_right == T){
          output$uiViewSaveData2 <- renderUI({
            downloadButton("viewSaveData2", textTable04)
          })
          output$viewSaveData2 <- downloadHandler(
            filename = function() { textOverview05},
            content = function(file) {
              ss = input$view2_rows_all
              write.csv(data4[ss, ], file,row.names = FALSE)
            }
          )
        }else{
          output$uiViewSaveData2 <- renderUI({HTML("<br/>")})
        }
      })
      # End download data
      ##########################################################################
      
      
      ##########################################################################
      #
      #                             OVERVIEW BY ELEMENT
      #
      ##########################################################################
      uiView2 <- paste0(uiView, "23")
      output[[uiView2]] <- renderUI({
        uiOutputs <- list(uiOutput("uiViewHeader3"),
                          DT::dataTableOutput("view3"),
                          uiOutput("uiViewSaveData3"),
                          uiOutput("viewBreak3"))
        do.call(tagList,uiOutputs)
      })
      
      request13 <- paste0("SELECT ",
                          obs_element.element_name, " AS element_name,",
                          obs_element.description, " AS description,",
                          "LCASE(", obs_element.element_type,  ") AS time_period,",
                          " by_element.described_by,  ",
                          " Count(by_element.recorded_from) AS number_stations,",
                          " min(by_element.min_recorded_at) AS first_date,",
                          " max(by_element.max_recorded_at) AS last_date",
                          " FROM (",
                          " SELECT ", observation.recorded_from, " AS recorded_from, ",
                          " Min(", observation.recorded_at, ") AS min_recorded_at,",
                          " Max(", observation.recorded_at, ") AS max_recorded_at,",
                          observation.described_by  ," AS described_by",
                          " FROM ", observation,
                          " GROUP BY ",
                          observation.recorded_from, ", ",
                          observation.described_by,
                          ")  AS by_element",
                          " INNER JOIN ", obs_element,
                          " ON by_element.described_by = ", obs_element.code,
                          " GROUP BY ", obs_element.element_name, ",",
                          obs_element.description, ", ",
                          obs_element.element_type,  ", ",
                          "by_element.described_by  ",
                          "ORDER BY ", obs_element.element_name, ";")
      
      
      result13 <- getQuery(input[[dbType]], channel2, request13)
      
      data5 <- result13
      colnames(data5) <- textOverview08
      output$view3 <- DT::renderDataTable({data5},
                                          options = list(language = list(
                                            url = paste0('translation/',
                                                         language, '.json'))),
                                          rownames = FALSE,
                                          filter = list(position = "top",
                                                        clear = FALSE)
      )
      ##########################################################################
      # Download data
      observe({
        if (!is.null(download_right) && download_right == T){
          output$uiViewSaveData3 <- renderUI({
            downloadButton("viewSaveData3", textTable04)
          })
          output$viewSaveData3 <- downloadHandler(
            filename = function() { textOverview05},
            content = function(file) {
              ss = input$view3_rows_all
              write.csv(data5[ss, ], file,row.names = FALSE)
            }
          )
        }else{
          output$uiViewSaveData3 <- renderUI({HTML("<br/>")})
        }
      })
      
    }else{
      output[[uiView]] <- renderUI({})
    }
    
    # End download data
    ############################################################################
  })
  return(output)
}

climsoft_db_rclimdex <- function(input, output, session){
  uid <- substr(UUIDgenerate(), 1, 4)
  uiRclimInputs <- paste0("uiRclimInputs_", uid)
  # Action buttons
  okButtonRClimDexId <- paste0("actionRClimDex_", uid)
  # Side Panel
  # Check option to calculate RClimDex
  output[[uiRclimCheck]] <- renderUI({
    conditionalPanel(condition = connectCondition,
                     h3(checkboxInput("rclimCheck", ("RClimDex"), F)),
                     h5(helpText("RClimDex will create up to 27 climate indices. ",
                                 "Therefore daily data and the available precipitation",
                                 "dataset will be used."))
    )
  })



  observe({
    if (!is.null(input$rclimCheck) && (input$rclimCheck == T) && openConn(channel2)){
      print("RClimDex Calculation")

      # Create uiOutputs
      output[[uiRclimInputs]] <- renderUI({
        uiOutputs <- list(uiOutput("uiStationIdRClim"),
                          uiOutput("uiRclimButtons"))
        do.call(tagList, uiOutputs)
      })

      output$uiRclimButtons <-  renderUI({
        conditionalPanel(
          condition = connectCondition,
          # Create uiOutputs for the "Action Buttons"
          bootstrapPage(
            div(style="display:inline-block",
                actionButton(okButtonRClimDexId, label = h4("OK")))
          )
        )
      })

      output$uiStationIdRClim <- renderUI({
        # Select only those stations that have, at least one of the three
        # required elements ("PRECIP", "TMPMAX" or "TMPMIN")
        request <- paste0("SELECT DISTINCT id, station_name ",
                          "FROM station INNER JOIN observation ",
                          "ON station.id = observation.recorded_from ",
                          "WHERE (observation.described_by = ",
                          paste(c(2,3,5),
                                collapse=" OR observation.described_by = "),");")
        result <- get.query(channel2,request)
        station_id_list2 <- as.vector(apply(result,1,paste,collapse = " - "))
        selectInput("stationIdRClim",
                    label = ("Select station:"),
                    choices = station_id_list2,
                    selected = station_id_list2[1])
      })
    }else{
      output[[uiRclimInputs]] <- renderUI({})
      output[[uiRclim]] <- renderUI({})
    }
  })

  observeEvent(input[[okButtonRClimDexId]],{
    output[[uiRclim]] <- renderUI({
      uiOutputs <- list(uiOutput("uiRClimHeader"),
                        uiOutput("uiRClimPlots"))
      do.call(tagList,uiOutputs)
    })
    output <- get_rclimdex_data(input, output)
    output <- get_rclim_graphics(input,output)
  })
}

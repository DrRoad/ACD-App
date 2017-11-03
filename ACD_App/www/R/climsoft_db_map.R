################################################################################
#' @export climsoft_db_map
#'
#' @title Create a Map
#'
#' @description Creates a Map with the station locations available in a given
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
#' @details This function will be called by the functions
#' \code{\link[ACD]{climsoft_db_access}} and
#' \code{\link[ACD]{climsoft_db_mariadb}}.
#'
################################################################################
#'
#'
climsoft_db_map <- function(input, output, session){
  ##############################################################################
  #
  #                         SIDE PANEL
  #
  ##############################################################################
  uid1 <- substr(UUIDgenerate(), 1, 4)
  mapCheck <<- paste0("mapCheck_", uid1)
  output[[uiMapCheck]] <- renderUI({
    conditionalPanel(
      condition = connectCondition,
      h3(checkboxInput(mapCheck, (textMap00), F)),
      h5(helpText(textMap01))
    )
  })
  
  ##############################################################################
  #
  #                         MAIN PANEL
  #
  ##############################################################################
  # Create new uiOutputs for mainPanel
  observe({
    if (!is.null(input[[mapCheck]]) && (input[[mapCheck]] == T) 
        && openConn(channel2)){
      uid2 <- substr(UUIDgenerate(),1,4)
      # Create uiOutputs
      map <- paste0("map_",uid2)
      clickText <- paste0("clickText_",uid2)
      output[[uiMap]] <- renderUI({
        uiOutputs <- list(
          uiOutput("uiMapHeader"),
          leafletOutput(map, height = "550"),
          verbatimTextOutput(clickText),
          downloadButton("pngLink", textMap04),
          uiOutput("mapBreak")
        )
        do.call(tagList,uiOutputs)
      })
      
      # Header
      output$uiMapHeader <- renderUI({h3(textMap02)})
      
      ##########################################################################
      # REQUEST 1
      # Get information of the station and station_location
      db.type <- input[[dbType]]
      requestMap01 <- paste0("SELECT ",
                             station.id, " AS id, ",
                             station.station_name, " AS station_name, ",
                             station.authority, " AS authority, ",
                             station_location.begin_datetime, " AS begin_datetime, ",
                             station_location.end_datetime, " AS end_datetime, ",
                             station_location.longitude, " AS longitude, ",
                             station_location.latitude, " AS latitude, ",
                             station_location.elevation, " AS elevation ",
                             " FROM (",station, " INNER JOIN ", station_location,
                             " ON ", station.id ,"=", station_location.occupied_by,");")
      df <- getQuery(db.type, channel2, requestMap01)
      
      ##########################################################################
      # REQUEST 2
      # Check whether the stations have a WMO ID
      requestMap02 <<-  paste0("SELECT ",
                               stationid_alias.id_alias, " AS id_alias, ",
                               stationid_alias.refers_to, " AS refers_to, ",
                               stationid_alias.belongs_to, " AS belongs_to ",
                               " FROM ", stationid_alias, ";")
      result0 <<- getQuery(db.type, channel2, requestMap02)
      id0000 <<- match(result0$refers_to, df$id)
      result1 <<- data.frame(result0, id0000)
      result1 <<- result1[!is.na(result1$id0000),]
      
      df$id_alias <- NA
      df$refers_to <- NA
      df$belongs_to <- NA
      df$id_alias[result1$id0000] <- as.character(result1$id_alias)
      df$refers_to[result1$id0000] <- as.character(result1$refers_to)
      df$belongs_to[result1$id0000] <- as.character(result1$belongs_to)
      
      ##########################################################################
      # Ignore the stations with no latitude/longitude
      id000 <- which((is.na(df$latitude)) | (is.na(df$longitude)))
      if (length(id000)>0){
        df <- df[-id000,]
      }
      df$authority <- as.character(df$authority)
      df$authority[is.na(df$authority)] <- "N.A."
      
      sources <- unique(df$authority)
      
      ##########################################################################
      # SET UP COLORS
      df$colors2 <- NA
      colors2 <- rainbow(length(sources))
      colors <- rgb(t(col2rgb(colors2) / 255))
      for (i in 1:length(sources)){
        id <- which(df$authority == sources[i])
        df$colors2[id] <- colors[i]
      }
      
      ##########################################################################
      # OBSERVE IF STATION_ID EXISTS AND IF CHECK PLOTS IS TRUE OR FALSE
      observe({
        if(exists('stationId') && !is.null(input[[stationId]]) 
           && !is.na(input[[stationId]]) &&
           !is.null(input[[plotsCheck]]) && !is.na(input[[plotsCheck]]) &&
           input[[plotsCheck]] == T){
          tr <- input[[stationId]]
          station_id_prev <- unlist(lapply(1:length(tr), function(i) {
            strsplit(tr[i], " - ")[[1]][1]}))
          id00 <- which(df$id %in% station_id_prev)
          print("log: Creating a map with stations selected by the user")
          df2 <<- unique(df[id00,])
        }else{
          print("log: Creating a Global map")
          df2 <<- df
        }
        
        # Specify the color of the authority
        authority2 <- paste0("<div style=color:",tolower(df2$colors2),
                             "; display: inline-block;height: 20px;",
                             "margin-top: 4px;line-height: 20px;
                             font-family:bold'>",
                             "<b>",df2$authority, "</b></div>")
        
        ########################################################################
        # CREATE MAP
        mymap <<- leaflet(df2) %>%
          addTiles(group = "OSM (default)") %>%
          addProviderTiles("Stamen.Toner", group = "Toner") %>%
          addProviderTiles("Stamen.TonerLite", group = "Toner Lite",
                           options = providerTileOptions(noWrap = TRUE)) %>%
          addCircleMarkers(lat = ~ latitude,
                           lng = ~ longitude,
                           group = authority2,
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
                           overlayGroups =  authority2,
                           options = layersControlOptions(collapsed = FALSE)
          )
        output[[map]] <- renderLeaflet({mymap})
      })
      
      # Text to be shown at the buttom of the map
      observe({
        mapMarkerClick <<- paste0(map,"_marker_click")
        click <<- input[[mapMarkerClick]]
        if (!is.null(click)){
          text2 <- paste(textMap03, click$id)
          output[[clickText]] <- renderText({text2})
        }
        
        ########################################################################
        # GET THE ZOOM
        mapZoom <<- paste0(map,"_zoom")
        zoom <<- input[[mapZoom]]
        mapBounds <- paste0(map, "_bounds")
        bounds <<- input[[mapBounds]]
        meanLat <<- mean(c(bounds$north, bounds$south), na.rm = T)
        meanLon <<- mean(c(bounds$east, bounds$west), na.rm = T)
        
        ########################################################################
        # DOWNLOAD THE MAP
        output$pngLink <- downloadHandler(
          filename = 'plot.png',
          content = function(file) {
            owd <- setwd(tempdir())
            on.exit(setwd(owd))
            mymap2 <<- mymap %>% setView(meanLon,
                                         meanLat,
                                         zoom = zoom)
            saveWidget(mymap2 , "temp.html", selfcontained = FALSE)
            webshot("temp.html", file = file, cliprect = "viewport")
          }
        )
        
        ########################################################################
        # SET THE BREACK AFTER THE MAP
        output$mapBreak <- renderUI({HTML("<br/>")})
      })
    }else{
      output[[uiMap]] <- renderUI({})
    }
  })
  return(output)
}

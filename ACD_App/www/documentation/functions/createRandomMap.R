createRandomMap <- function(df2){
  df3 <- df2
  authority_prev <- unique(df3$authority)
  
  rows <- c()
  for (i in 1:length(authority_prev)){
    id1 <- which(df3$authority == authority_prev[i])
    df3$authority[id1] <- paste0("Source ", LETTERS[i])
    id2 <- id1[1:4]
    rows <- c(rows, id2[!is.na(id2)])
  }
  df4 <- df3[rows, ]
  
  
  authority2 <- paste0("<div style=color:",tolower(df4$colors2),
                       "; display: inline-block;height: 20px;",
                       "margin-top: 4px;line-height: 20px;
                             font-family:bold'>",
                       "<b>",df4$authority, "</b></div>")
  df4$authority2 <- authority2
  
  latitude <- runif(nrow(df4), -33, -3)
  longitude <- runif(nrow(df4), 17, 30)
  id <- c(1:nrow(df4))
  station_name <- randomNames(nrow(df4), which.names = "last")
  id_alias <- round(runif(nrow(df4), 60000,66000), digits = 0)
  
  df4$latitude <- round(latitude, 4)
  df4$longitude <- round(longitude,4)
  df4$id <- sprintf("%03d", id)
  df4$station_name <- station_name
  df4$id_alias <- id_alias
  authority2 <- df4$authority2
  
  mymap4 <- leaflet(df4) %>%
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
  mymap4
}
################################################################################
#' @export get_climsoft_data_rclimdex
#'
#' @title Retrieve data to use for RClimDex
#'
#' @description It retrieves the data required by the RClimDex to run
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
################################################################################
get_climsoft_data_rclimdex <- function(input,output){
  Sys.setenv(TZ = "UTC")
  element_name <<- c(2,3,5)
  station_id <- input$stationIdRClim
  station.id <- strsplit(station_id," - ")[[1]][1]

  request <<- paste0("SELECT observation.recorded_from,",
                    "obs_element.abbreviation,",
                    "observation.recorded_at,",
                    "observation.obs_value,",
                    "obs_element.element_scale ",
                    "FROM observation INNER JOIN obs_element ",
                    "ON obs_element.code = observation.described_by ",
                    "WHERE observation.recorded_from = '",
                    station.id,"' AND (observation.described_by = ",
                    paste(element_name,
                          collapse=" OR observation.described_by = "),");")

  # Set the directory
  wd <- getwd()
  setwd(path.expand("~/"))
  home <- getwd()
  newPath <- paste(home, "/", station.id, sep="")
  dir.create(station.id,showWarnings = F)
  setwd(newPath)


  # Variables to lookfor in the dataset
  result <<- get.query(channel,request)
  print(head(result))

  if (nrow(result)>0){
    elements <- as.character(unique(result$abbreviation))
    df <- split(result,result$abbreviation)

    # Change headers
    df4 <<- lapply(1:length(elements),function(i){
      df2 <- df[[elements[i]]][order(df[[elements[i]]]$recorded_at),]

      # Check if the Climsoft db is a main database, because
      # in a main_database, the "obs_value" does not need to
      # be divided by the element_scale

      # Extract the name of the database from the connection
      db_path <- strsplit(
        strsplit(attr(channel,"connection.string"),";")[[1]][2],
        "\\\\")[[1]]
      db_name <- db_path[length(db_path)]
      if (length(grep("main_climsoft",db_name))==0){
        # multiply by "element_scale"
        obs_value2 <- df2$obs_value*df2$element_scale
        df2$obs_value <- obs_value2
      }
      # Change "obs_value" header
      id <- which(colnames(df[[elements[i]]]) == "obs_value2")
      colnames(df2)[id] <- elements[i]

      # Change "recorded_from" header
      id <- which(colnames(df[[elements[i]]]) == "recorded_from")
      colnames(df2)[id] <- "station_id"

      # Change "recorded_at" header
      id <- which(colnames(df[[elements[i]]]) == "recorded_at")
      colnames(df2)[id] <- "date"
      df2[,-5] # To remove the "element_scale" column
    })

    # Create R-climdex
    # set start- and end-date
    id <- which.min(lapply(df4, function(x) min(x[, c("date")])))
    start.date <- df4[[id]]$date[1]
    id <- which.max(lapply(df4, function(x) max(x[, c("date")])))
    end.date <- df4[[id]]$date[nrow(df4[[id]])]

    # create a complete timereference
    date.full <- seq.POSIXt(from=start.date, to=end.date, by="day")

    # merge the data with the complete timereference
    df5 <- lapply(1:length(elements),function(i){
      df5 <- merge(date.full,df4[[i]],by.x = "x",by.y = "date",
                   all.x = T)
      colnames(df5)[1] <- "date"
      colnames(df5)[4] <- elements[i]
      df5
    })


    # Create a single data.frame with all the variables;
    df6 <- join_all(df5,by="date",type="full")

    # Split the date of the data.base
    year <- year(df6$date)
    month <- month(df6$date)
    day <- day(df6$date)
    df.data <- as.data.frame(df6[,c(4:ncol(df6))])
    colnames(df.data) <- colnames(df6)[c(4:ncol(df6))]
    final.data <<- data.frame(year,month,day,df.data)

    # Check if there is an element missing
    colnames1 <- elements
    colnames2 <- c("PRECIP","TMPMAX","TMPMIN")
    missing.col <- colnames2[which(colnames2 %in% colnames1==F)]
    if (!is.null(missing.col)){
      final.data[missing.col] <- NA
    }

    # Reallocate the position of the columns
    final.data2 <<- data.frame(year= final.data$year,
                              month =final.data$month,
                              day = final.data$day,
                              PRECIP = final.data$PRECIP,
                              TMPMAX = final.data$TMPMAX,
                              TMPMIN = final.data$TMPMIN)

    # Replace NA with -99.9
    final.data2[is.na(final.data2)] <- -99.9

    if (ncol(final.data2)==6){
      # Save the final "data.frame"
      write.table(signif(final.data2), file = paste(station.id, ".txt", sep=""), sep = " ",
                  row.names=F, col.names=F,quote=F)
    }else{
      print("Not enough data")
    }

  }else{
    print("Data not available for the RClimDex Calculation")
  }
  return(output)
}

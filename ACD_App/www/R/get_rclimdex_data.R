################################################################################
#' @export get_data_rclimdex
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
get_rclimdex_data <- function(input,output){
  element_name <- c(2,3,5)
  station.id <- strsplit(input$stationIdRClim," - ")[[1]][1]

  request <- paste0("SELECT observation.recorded_from,",
                    "obs_element.abbreviation,",
                    "observation.recorded_at,",
                    "observation.obs_value ",
                    "FROM OBSERVATION INNER JOIN obs_element ",
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

  print(station.id)
  date.begin = "1700-01-01"
  date.end = Sys.Date()


  # Variables to lookfor in the dataset
  result <- get.query(channel,request)
  print(head(result))

  if (nrow(result)>0){
    elements <- as.character(unique(result$abbreviation))
    df <- split(result,result$abbreviation)

    # Change headers
    df4 <- lapply(1:length(elements),function(i){
      df2 <- df[[elements[i]]]


      # Change "obs_value" header
      id <- which(colnames(df[[elements[i]]]) == "obs_value")
      colnames(df2)[id] <- elements[i]

      # Change "recorded_from" header
      id <- which(colnames(df[[elements[i]]]) == "recorded_from")
      colnames(df2)[id] <- "station_id"

      # Change "recorded_at" header
      id <- which(colnames(df[[elements[i]]]) == "recorded_at")
      colnames(df2)[id] <- "date"
      df2
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
      df5
    })


    # Create a single data.frame with all the variables;
    df6 <- join_all(df5,by="date",type="full")

    # Split the date of the data.base
    year <- year(df6$date)
    month <- month(df6$date)
    day <- day(df6$date)
    df.data <- df6[,c(4:ncol(df6))]/10
    final.data <- data.frame(year,month,day,df.data)
    if (ncol(final.data)==6){
      # Save the final "data.frame"
      write.table(final.data, file = paste(station.id, ".txt", sep=""), sep = " ",
                  na = "-99.9", row.names=F, col.names=F)
    }else{
      print("Not enough data")
    }

  }else{
    print("Data not available for the RClimDex Calculation")
  }
  return(output)
}

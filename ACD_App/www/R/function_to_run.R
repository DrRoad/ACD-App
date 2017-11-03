################################################################################
#' @export function_to_run
#'
#' @title Function to get the data in a "zoo" object
#' 
#' @description This function that has to be run in order to get 
#' the data in the right format for plotting "timeseries" and "histograms". 
#' It has been created based on the function 
#' \code{\link[get.plots.from.ftp]{get_timeseries}} .
#' 
#' @param metadata list. A list with the metadata of the data of interest.
#' 
#' @param data data.frame. Contains the data that correspond 
#' to the given metadata.
#' 
#' @param changes.in string. Refers to the type of 
#' changes made in a given weather station. Three options 
#' are available: 1) changes in the sensor 
#' (\code{changes.in = "sensor"}); 2) changes in the
#' structure of the dataset(\code{changes.in = "structure"}),
#' or 3) no changes (\code{changes.in = "none"})
#' 
################################################################################
function_to_run <- function(metadata, data, changes){
  
  ##############################################################################

  x <- as.POSIXct(with(data,get("mess_datum")), tz = "UTC")
  y <- with(data,get(as.character(metadata[[3]]$element_name)))
  y[which(y==-999)]<-NA
  changes.date.index <- changes[[5]]
  if (is.null(changes.date.index)){
    nchanges <- 1
    z6 <- as.data.frame(matrix(NA,nrow=length(x),ncol=nchanges))
    z6[,nchanges] <- y
    colnames(z6) <- "Total"
    time.resol <- tolower(metadata[[3]]$element_type)
  }else{
    # Create an empty data.frame with the appropiate length
    nchanges <- nrow(changes.date.index)

    z6 <- as.data.frame(matrix(NA,nrow=length(x),ncol=nchanges))

    name.changes <- c()
    for (i2 in c(1:nrow(changes.date.index))){
      interval <- c(changes.date.index$id1[i2]:
                      changes.date.index$id2[i2])
      z6[interval,i2] <- y[interval]
      if(i2==1){
        name.changes[i2] <- "Total"
      }else{
        name.changes[i2] <- paste("change_Nr_",i2-1,sep="")
      }
    }
    colnames(z6) <- name.changes

    time.resol <- metadata[[4]]
  }

  ##############################################################################
  # Find whether the time.resolution of the data is "subdaily", "daily", or
  # others (tested only in the Climsoft option)

  time_diff <- diff(x)
  # Count cases with the same time stamp
  time_stamp <- table(diff(x))

  # a) get the time difference units (minutes, hours, etc.)
  time_units <- units(time_diff)
  id <- which(time_stamp==max(time_stamp))
  time_interval <- names(time_stamp)[id]
  data_time_interval <- paste(time_interval,time_units)[1]

  # Check if the data_time_interval is 29, 30 or 31 days, then it refers
  # to monthly interval
  if (data_time_interval %in% paste(c(28:31),"days")==T){
    data_time_interval <- "1 month"
  }


  # Split the dataset if the time_interval is higher than 1 (meaning
  # that the timeseries is not a continuum)
  if ((time_interval > 1) && (time_units == "hours")){
    time.resol <- "subdaily"
  }

  # Add "date time" column
  first.date <- as.POSIXct(as.Date(x[1]), tz = "UTC")
  last.date <- as.POSIXct(as.Date(x[length(x)])+1, tz = "UTC")
  if (time.resol== "subdaily"){
    x2 <- as.POSIXct(strptime(x,format="%Y-%m-%d %H:%M:%S"),
                     format="%Y-%m-%d %H:%M:%S",tz="UTC")
    full <- seq.POSIXt(first.date,last.date,by = data_time_interval)
  }
  if (time.resol=="hourly" || time.resol == "aws"){
    x2 <- as.POSIXct(strptime(x,format="%Y-%m-%d %H:%M:%S"),
                     format="%Y-%m-%d %H:%M:%S",tz="UTC")
    full <- seq.POSIXt(first.date,last.date,by='hour')
  }

  if (time.resol=="daily"){
    x2 <- as.POSIXct(strptime(x,format="%Y-%m-%d"),
                     format="%Y-%m-%d %H:%M:%S",tz="UTC")
    full <- seq.POSIXt(first.date,last.date,by='day')
  }

  if (time.resol=="monthly"){
    x2 <- as.POSIXct(strptime(x,format="%Y-%m-%d"),
                     format="%Y-%m-%d %H:%M:%S",tz="UTC")
    full <- seq.POSIXt(first.date,last.date,by='month')
  }

  data2 <- data.frame(x2,z6)

  all.dates.frame <- data.frame(list(x2=full))

  # Merge data
  merged.data <- merge(all.dates.frame,data2,all=T)

  # Split the dataset if the time_interval is higher than 1 (meaning
  # that the timeseries is not a continuum)
  if (time.resol == "subdaily"){
    if ((tolower(data_time_interval) != "1 hours") &&
        (tolower(data_time_interval) != "60 min") &&
        (tolower(data_time_interval) != "3600 secs")){
      #if (as.numeric(time_interval) > 1){
      times <- sort(unique(strftime(merged.data$x2,format="%H:%M:%S",
                                    tz="UTC")))
      dates <- unique(strftime(merged.data$x2,format="%Y-%m-%d",
                               tz="UTC"))

      full.new <- as.Date(seq.POSIXt(first.date,last.date,by="1 day"),
                          format = "%Y-%m-%d")
      all.dates.frame.new <- data.frame(list(x2=full.new))
      merged.data.new <- data.frame(x2=all.dates.frame.new$x2)
      tmp1 <- merged.data
      for (i0 in c(1:length(times))){
        data00 <- subset(tmp1,
                         strftime(tmp1$x2,
                                  format="%H:%M:%S",tz="UTC")==times[i0])
        data00$x2 <- as.Date(data00$x2,"%Y-%m-%d",tz="UTC")
        colnames(data00)[2] <- times[i0]
        tmp2 <- merge(all.dates.frame.new,data00,all=T)
        merged.data.new <- cbind(merged.data.new,tmp2[,2])
        colnames(merged.data.new)[i0+1] <- times[i0]
      }
      merged.data <- merged.data.new
    }
  }

  # Create a "zoo" variable. This will allow us to plot
  # the timeseries correctly
  z5 <- with(merged.data,zoo(merged.data[,c(2:ncol(merged.data))],
                             order.by=merged.data$x2))
  return(z5)
}

################################################################################
#' @export check_dataframe
#'
#' @title Automatically detect colnames in dataframe
#'
#' @description Function used to detect the content of a given dataframe. It
#' checks if there is 'date-time' header and what is its format; what is the
#' time period available (subdaily, daily, subyearly, yearly); removes not
#' available values and checks if there are duplicates.
#'
#' @param df dataframe. Data frame with the data to be checked.
#'
#' @note It requires the packages 'lubridate' (version == 1.5.6) and 'climssc'
#' 
################################################################################
check_dataframe <- function(df){
  
  # Libraries
  library(lubridate) # requires v.1.5.6
  library(climssc)
  
  # Create an empty list to save the outputs
  df_list <- list()
  time.zone = "UTC"
  ##############################################################################
  #
  #                           REMOVE EXTRANGE CHARACTERS
  #
  ##############################################################################
  # Remove extrange characters from the headers
  print(colnames(df))
  newcolnames <- gsub("[][°%]", "", colnames(df))
  newcolnames <- gsub("[][()]", "", newcolnames)
  colnames(df) <- newcolnames
  print(newcolnames)
  print(colnames(df))
  
  ##############################################################################
  #
  #                     CHECK IF THE DATE TIME HEADER IS PRESENT
  #
  ##############################################################################
  # List of labels to be found
  list_date_labels <- c("date", "date_time", "year", "month", "day", "time")
  
  # Identify the variables
  variables <- ident_var(df, c())
  id <- which(names(variables) %in% list_date_labels)
  
  if (length(id)==0){
    message <- paste("No 'Date' column could not be identified.",
                     "Please check the headers of your dataset.")
    df_list$message <- message
    print(message)
    return(df_list)
  }
  ##############################################################################
  #
  #                           CHECK DATE FORMAT
  #
  ##############################################################################
  # List of labels to be found
  list_date_labels <- c("date", "date_time", "year", "month", "day", "time")
  
  # Identify the variables
  variables <- ident_var(df, c())
  id <- which(names(variables) %in% list_date_labels)
  
  date_labels <- names(variables)[id]
  date_columns <- unique(variables[id])
  if (length(date_columns)>1){
    date_together <- apply(df[,date_columns],1, paste, collapse = " ")
  }else{
    date_together <- df[,date_columns]
  }
  formats <- c(
    "mdY HMS", "BdY HMS", "Bdy HMS", "bdY HMS", "bdy HMS", "Ymd HMS", "ymd HMS",
    "mdY HM",  "BdY HM",  "Bdy HM",  "bdY HM",  "bdy HM",  "Ymd HM",  "ymd HM",
    "mdY H",   "BdY H",   "Bdy H",   "bdY H",   "bdy H",   "Ymd H",   "ymd H",
    "mdY",     "BdY",     "Bdy",     "bdY",     "bdy",     "Ymd",     "ymd",
    "mY",      "BY",      "By",      "bY",      "by",      "Ym",      "ym",
    "Y",       "y",
    "dmY HMS", "dBY HMS", "dBy HMS", "dbY HMS", "dby HMS",
    "dmY HM",  "dBY HM",  "dBy HM",  "dbY HM",  "dby HM",
    "dmY H",   "dBY H",   "dBy H",   "dbY H",   "dby H",
    "dmY",     "dBY",     "dBy",     "dbY",     "dby"
  )
  
  if (length(date_together)>100){
    guess <- unique(guess_formats(date_together[1:100], orders = formats))
  }else{
    guess <- unique(guess_formats(date_together, orders = formats))
  }
  tt0 <- paste0(guess, collapse = ", ")
  print(paste0("Possible date format(s): ", tt0))
  if (length(guess) > 1){
    id00 <- sapply(1:length(guess), function(i2){
      new_col_prev = as.POSIXct(as.character(date_together), 
                                format = guess[i2],tz=time.zone)
      length(which(!is.na(new_col_prev)))
    })
    date_format_prev = guess[which(id00 == max(id00))]
    #dates <- list()
    if (length(date_format_prev) > 1){
      tt <- paste0(date_format_prev,collapse = " or ")
      message <- paste0("No date format recognized (Options detected: ", 
                        tt, " )")
      df_list$message <- message
      print(message)
      return(df_list)
    }
  }else{
    date_format_prev = guess
  }
  dateformat <- date_format_prev
  
  # Print message
  print(paste0("Date format detected: ", dateformat))
  
  ##############################################################################
  #
  #                     CHECK DATE TIME PERIOD
  #
  ##############################################################################
  if(grepl("%H", date_format_prev)){
    date_time_period <- "subdaily"
  }else if (grepl("%d", date_format_prev)){
    date_time_period <- "daily"
  }else if (grepl("%m", date_format_prev)){
    date_time_period <- "subyearly"
  }else if (grepl("%Y", date_format_prev)){
    date_time_period <- "yearly"
  }
  
  ##############################################################################
  #
  #                     CHECK IF THERE ARE DATA AVAILABLE TO PLOT
  #
  ##############################################################################
  id1 <- which(colnames(df) %in% date_columns)
  df_new <- df[,-id1]
  if (class(df_new) != "data.frame"){
    print("No data available")
    message <- "No data available"
    df_list$message <- message
    print(message)
    return(df_list)
  }else{
    
    ############################################################################
    #
    #   CHECK IF THERE ARE DATES THAT DO NOT MATCH THE DETECTED FORMAT
    #
    ############################################################################
    dateformat_prev <- dateformat
    if (!grepl("%m", dateformat)){
      date_together <- paste0(date_together, "01")
      dateformat <- paste0(dateformat,"%m")
    }
    if (!grepl("%d", dateformat)){
      date_together <- paste0(date_together, "01")
      dateformat <- paste0(dateformat,"%d")
    }
    
    
    date_prev <- as.POSIXct(as.character(date_together), format = dateformat,
                            tz = time.zone)
    id000 <- which(is.na(date_prev))
    if (length(id000)>0){
      tt <- paste("Some dates do not match the date format detected",
                  "(",dateformat_prev,").", "For instance, at around Row Nr. '",
                  id000[1],"' .",
                  "Please check the date format of your dataset and try again.")
      message <- tt
    }else{
      message <- NULL
    }
    df_new$date <- date_together
  }
  # Change header of date if 'date_time_period' = "subdaily
  if (date_time_period == "subdaily"){
    colnames(df_new)[ncol(df_new)] <- "date_time"
  }
  
  ##############################################################################
  #
  #                           REMOVE NOT AVAILABLE VALUES
  #
  ##############################################################################
  # Replace not available values
  na.value <- c(-999, 9999, 99999908, 99999991, 9999990.8, 99999901, 999)
  for (i2 in (1:length(na.value))){
    df_new[df_new == na.value[i2]] <- NA
  }
  
  ##############################################################################
  #
  #             CHECK IF THE DECIMALS ARE SEPARATED WITH ","
  #
  ##############################################################################
  variables2 <- ident_var(df_new, c())
  id <- which(!names(variables2) %in% c(list_date_labels, "station"))
  var_labels <- names(variables2)[id]
  var_columns <- unique(variables2[id])
  
  if (length(var_columns) == 0){
    message <- "An element was not detected in the headers"
    df_list$message <- message
    return(df_list)
  }else{
    # Replace "," with "."
    for (i3 in (1:length(var_columns))){
      df_new[,var_columns[i3]] <- as.numeric(gsub(",", ".", 
                                                  df_new[,var_columns[i3]]))
    }
  }
  
  ##############################################################################
  #
  #             CHECK IF THERE ARE DUPLICATED DATES
  #
  ##############################################################################
  # Check for duplicated station_id and date
  id <- which(names(variables2) %in% c("station"))
  id0000 <- which(duplicated(df_new[,c(id,ncol(df_new))])==T)
  if (length(id0000) > 0){
    message <- paste0("There are '", length(id0000),
                      "' duplicated dates (e.g. in Row Nr. ", id0000,
                      "). Please, check your dataset")
    df_new2 <- df_new[!id0000,]
    df_list$message <- message
    print(message)
    return(df_list)
  }
  
  ##############################################################################
  #
  #                                    SORT BY DATE
  #
  ##############################################################################
  df_new <- df_new[order(as.POSIXct(as.character(df_new[,ncol(df_new)]), 
                                    format = dateformat)),]
  
  ##############################################################################
  #
  #                                 CREATE "DF_LIST"
  #
  ##############################################################################
  df_list$dateformat <- dateformat
  df_list$df <- df_new
  df_list$datetimeperiod <- date_time_period
  df_list$message <- message
  print(message)
  return(df_list)
}

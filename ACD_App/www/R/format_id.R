################################################################################
#' @title Format given station-id
#' @description Function that formats the given station-id to a character of 
#' length five. If given id is shorter it will be filled with 0.
#' 
#' @param station.id character/numeric. Station-id to be formated.
#' 
#' @return character. Of length five.
#' 
#' @examples
#' # format the numeric id 282 to character "00282"
#' station.id <- FormatID(282)
#' print(station.id)  # return should be "00282"
################################################################################

FormatID <- function(station.id) {

  station.id <- as.character(station.id)
  if (nchar(station.id < 5)){
    for (i in 4:1) {
      if (nchar(station.id) <= 4) {
        station.id <- paste(0, station.id, sep="")
      }
    }
  }
  
  return(station.id)
}
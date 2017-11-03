################################################################################
#' @export climsoft_db_users
#'
#' @title Setup and store user rights
#'
#' @description It sets up the user rights to access the ACD-App. The default
#' users are 'admin' and 'operator'. The user accounts can be modified
#' in the App.
#'
#' @return df.users dataframe. It contains the rights of the users to access
#' each section of the ACD-App. The dataframe is saved in the file
#' 'loginData.Rda'.
#' ## TODO ## This information should be hidden.
#'
#' @details This function will be called by the functions
#' \code{\link[ACD]{climsoft.db.access}} and
#' \code{\link[ACD]{climsoft.db.mariadb}}.
#'
################################################################################

climsoft_db_users <- function(){
  fileName <- "loginData.Rda"
  if (file.exists(fileName)){
    aa <- load(fileName)
    print(paste0("log: ", fileName, " already exists"))
    df.users <- get(aa)
  }else{
    # Defaults
    users <- c("operator", "admin")
    pswd <- c("operator", "admin")
    rights <- c("Map", "Table", "Plots", "Report", "Overview", 
                "RClimDex", "UserRights", "Export")
    df.users <- data.frame(matrix(NA, nrow = length(users),
                                  ncol = length(rights)+2))
    colnames(df.users) <- c("users", "pswd", rights)

    df.users$users <- users
    df.users$pswd <- pswd
    df.users$Map <- c(T, T)
    df.users$Table <- c(F, T)
    df.users$Plots <- c(T, T)
    df.users$Report <- c(T, T)
    df.users$Overview <- c(T, T)
    df.users$RClimDex <- c(F, T)
    df.users$UserRights <- c(F, T)
    df.users$Export <- c(F, T)
    save(df.users, file=fileName)
  }
  return(df.users)
}

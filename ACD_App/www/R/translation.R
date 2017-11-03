################################################################################
#' @export translation
#'
#' @title Translation of the 'ACD-App'
#'
#' @description Used to translate the 'ACD-App' into English or Portuguese.
#'
#' @param language character. Language under which the 'ACD-App' has to run.
#' There are two possible options: \code{'english'} or \code{'portuguese'}.
#' Usually the 'ACD-App' will detect the language of the local machine
#' automatically and set up the text of the App accordingly.
#'
#' @return textInfo list. A list containing all the text used in the App.
#' The text is saved in different R objects which names begin with the word
#' \code{text}. E.g. \code{textMap00} contains the text that has to be use
#' to label the input \code{checkMap}.
#' @details This function is run directly by the \code{ui.R} file of the
#' 'ACD-App'.
#'
################################################################################

translation <- function(language){
  
  ##############################################################################
  #
  #                         ENGLISCH
  #
  ##############################################################################
  if (language == "english"){
    ############################################################################
    # Side Panel
    textTitlePanel <- "Analysis of Climate Data (ACD)"
    textSidePanel00 <- "Select Data Source:"
    textSidePanel01 <- "Select type of database:"
    textSidePanel02 <- "Select database:"
    textSidePanel03 <- "Select database (DNS):"
    textSidePanel04 <- 'Choose File (s)'
    textSidePanel05 <-"The file(s) must be in ASCII format"
    textConnectButton <- "Connect"
    textDisconnectButton <- "Disconnect"
    textLoginUser <- "Username:"
    textLoginPassword <- "Password:"
    textClearButton <- "Clear"
    textOKButton <- "OK"
    textConnectMessage01 <- "Connected!"
    textConnectMessage02 <- "Connection failed!"
    textDisconnectMessage <- "Disconnected!"
    textODBCMessage <- "ODBC connection not successfull"
    textWrongLogin <- "Wrong username/password"
    
    ############################################################################
    # Table
    textTable00 <- "Create Table"
    textTable01 <- "See the values available in a table"
    textTable02 <- "Table with data"
    textTable03 <- "Please, create a Map and select a station"
    textTable04 <- "Save data"
    textTable05 <- c("Station id",
                     "Element name",
                     "Element code",
                     "Date",
                     "Value")
    
    ############################################################################
    # Map
    textMap00 <- "Create Map"
    textMap01 <- "Place the stations in a map"
    textMap02 <- "Interactive Map"
    textMap03 <- "You've selected station:"
    textMap04 <- "Download Map"
    
    ############################################################################
    # Plots
    textPlot00 <- "Create Plots"
    textPlot01 <- "Plots will be shown"
    textPlot02 <- "Select one or more stations:"
    textPlot03 <- "Select one or more elements:"
    textPlot04 <- "Histogram"
    textPlot05 <- "Timeseries"
    textPlot06 <- "Comparison of Timeseries"
    textPlot07 <- "Windrose"
    textPlot08 <- "Select graphic:"
    textPlot09 <- "Type of windrose"
    textPlot09a <- "Wind speed units"
    textPlot09b <- "Wind direction scale factor"
    textPlot10 <- "Date range:"
    textPlot11 <- "Please, select at least one element"
    textPlot12 <- 'Making plots...'
    textPlot13 <- "Plots from the data"
    textPlot14 <- "Select Station:"
    textPlot15 <- "Select type of change:"
    textPlot16 <- "Time period"
    textPlot17 <- "Station not available"
    textPlot18 <- "No data available"
    
    ############################################################################
    # Report
    textReport00 <- "Create Report"
    textReport01 <- "Creates a report with metadata from a selected location"
    textReport02 <- "Making report..."
    textReport03 <- "Please, select at least one location"
    textReport04 <- "Save report"
    textReport05 <- "Download Report"
    textReport06 <- "Report"
    textReport07 <- "Select location:"
    textReport08 <- "Locations:"
    textReport09 <- "Locations"
    textReport10 <- "Metadata"
    textReport11 <- "Elements available"
    textReport12 <- c("Station ID", "Authority", "Begin date", "End date",
                      "Longitude", "Latitude", "Height", "ID Alias")
    textReport13 <- c("Begin date",
                      "End date",
                      "Number of records expected",
                      "Actual number of records",
                      "Missing records (%)")
    textReport14 <- c("No elements for station(s):")
    
    ############################################################################
    # Overview
    textOverview00 <- "Database Overview"
    textOverview01 <- "Overview of data available in the database"
    textOverview02 <- 'Creating overview (this may take several minutes)...'
    textOverview03 <- "Save table"
    textOverview04 <- c("Overview", "By station", "By element")
    textOverview05 <- "Overview.csv"
    textOverview06 <- c("Authority",
                        "Elements available",
                        "Number of stations",
                        "Date of first record",
                        "Date of last record",
                        "Station with max. number of records ('station_id')")
    textOverview07 <- c("Station name",
                        "Station ID",
                        "Element name",
                        "Time period",
                        "Date of first record",
                        "Date of last record",
                        "Number of records",
                        "Percent (%)")
    
    textOverview08 <- c("Element Name",
                        "Element description",
                        "Time period",
                        "Element ID",
                        "Number of stations",
                        "Date of first record",
                        "Date of last record")
    
    ############################################################################
    # Users and rights
    textUserRights00 <- "Set up User Rights"
    textUserRights01 <- "Set up the rights of the users"
    textUserRights02 <- "Save changes"
    textUserRights03 <- "List of users and rights"
    textUserRights04 <- c("User",
                          "Password", "Map", "Table",
                          "Plots",
                          "Report",
                          "Overview",
                          "RClimDex",
                          "User Rights",
                          "Download")
    
    ############################################################################
    # Export data
    textExport00 <- "Download data"
    textExport01 <- "Download data stored in the database"
    textExport02 <- "Select station(s)"
    textExport03 <- "Select element(s)"
    textExport04 <- "Date Range"
    textExport05 <- "Request Data"
    textExport06 <- "Download Data"
    textExport07 <- c("Station Name", "Station ID",
                      "Authority", "Longitude", "Latitude",
                      "Elevation (m)", "Element Name",
                      "Date/Time", "Value", "Units")
    textExport08 <- "Data.csv"
    textExport09 <- "Requesting data..."
    
    ############################################################################
    # RClimDex
    textRClimDex00 <- "RClimDex"
    textRClimDex01 <- paste0("RClimDex will create up to 27 climate indices. ",
                             "Therefore daily data and the available precipitation",
                             "dataset will be used.")
    textRClimDex02 <- "RClimDex Calculation"
    
    ############################################################################
    # Check precipitation
    textPrecipCheck00 <- "Precipitation Check"
    textPrecipCheck01 <- paste(
      "A comparison of 'more prcp-data' and 'kl-data'",
      "will be executed. It is based on daily data.")
    
    ############################################################################
    # LOCAL_FILE
    textLocalFile01 <- "Please check the Headers of the file."
    textLocalFile02 <- "Variables not found"
    textLocalFile03 <- "Selected datasets:"
  }
  
  ##############################################################################
  #
  #                         PORTUGUESE
  #
  ##############################################################################
  if (language == "portuguese"){
    ############################################################################
    # Side Panel
    textTitlePanel <- "An\u{00E1}lise de Dados Clim\u{00E1}ticos (ACD)"
    textSidePanel00 <- "Selecione fonte de dados:"
    textSidePanel01 <- "Selecione o tipo de banco de dados:"
    textSidePanel02 <- "Selecione banco de dados:"
    textSidePanel03 <- "Selecione banco de dados (DNS):"
    textSidePanel04 <- 'Escolha o(s) arquivo(s)'
    textSidePanel05 <- "O(s) arquivo(s) deve(n) estar em formato ASCII"
    textConnectButton <- "Conectar"
    textDisconnectButton <- "Desconectar"
    textLoginUser <- "Utilizador:"
    textLoginPassword <- "Senha:"
    textClearButton <- "Limpar"
    textOKButton <- "OK"
    textConnectMessage01 <- "Conectado!"
    textConnectMessage02 <- "Conex\u{00E3}o falhou!"
    textDisconnectMessage <- "Desconectado!"
    textODBCMessage <- "Conex\u{00E3}o ODBC sem sucesso"
    textWrongLogin <- "Nome de usu\u{00E1}rio e/ou senha incorretos"
    
    ############################################################################
    # Table
    textTable00 <- "Criar Tabela"
    textTable01 <- "Veja os valores dispon\u{00ED}veis em uma tabela"
    textTable02 <- "Tabela com dados"
    textTable03 <- "Por favor, crie um Mapa e selecione uma esta\u{00E7}\u{00E3}o"
    textTable04 <- "Guardar dados"
    textTable05 <- c ( "ID da esta\u{00E7}\u{00E3}o",
                       "Nome do elemento",
                       "C\u{00F3}digo do elemento",
                       "Data",
                       "Valor")
    
    ############################################################################
    # Map
    textMap00 <- "Criar Mapa"
    textMap01 <- "Ver as esta\u{00E7}\u{00F5}es num mapa"
    textMap02 <- "Mapa Interativo"
    textMap03 <- "Voc\u{00EA} selecionou a esta\u{00E7}\u{00E3}o:"
    textMap04 <- "Baixar Mapa"
    
    ############################################################################
    # Plots
    textPlot00 <- "Criar Gr\u{00E1}ficos"
    textPlot01 <- "Os gr\u{00E1}ficos ser\u{00E3}o mostrados"
    textPlot02 <- "Selecione uma ou mais esta\u{00E7}\u{00F5}es:"
    textPlot03 <- "Selecione um ou mais elementos:"
    textPlot04 <- "Histograma"
    textPlot05 <- "S\u{00E9}rie temporal"
    textPlot06 <- "Compara\u{00E7}\u{00E3}o de s\u{00E9}ries temporais"
    textPlot07 <- "Rosa dos ventos"
    textPlot08 <- "Selecione o tipo de gr\u{00E1}fico:"
    textPlot09 <- "Tipo de rosa do vento"
    textPlot09a <- "Unidades de velocidade do vento"
    textPlot09b <- "Factor de escala da dire\u{00E7}\u{00E3}o do vento"
    textPlot10 <- "Intervalo de datas:"
    textPlot11 <- "Por favor, selecione pelo menos um elemento"
    textPlot12 <- "Criando gr\u{00E1}ficos..."
    textPlot13 <- "Gr\u{00E1}ficos a partir dos dados"
    textPlot14 <- "Selecione uma esta\u{00E7}\u{00E3}o:"
    textPlot15 <- "Selecione o tipo de altera\u{00E7}\u{00E3}o:"
    textPlot16 <- "Periodo do Tempo"
    textPlot17 <- "Esta\u{00E7}\u{00E3}o n\u{00E3}o disponivel"
    textPlot18 <- "Dados n\u{00E3}o disponiveis"
    
    ############################################################################
    # Report
    textReport00 <- "Criar Relat\u{00F3}rio"
    textReport01 <- "Cria um relat\u{00F3}rio com metadados de uma localiza\u{00E7}\u{00E3}o selecionada"
    textReport02 <- "Criando relat\u{00F3}rio..."
    textReport03 <- "Por favor, selecione uma localiza\u{00E7}\u{00E3}o"
    textReport04 <- "Guardar o relat\u{00F3}rio"
    textReport05 <- "Baixar relat\u{00F3}rio"
    textReport06 <- "Relatorio"
    textReport07 <- "Selecione uma o mais localiza\u{00E7}\u{00F5}es"
    textReport08 <- "Localiza\u{00E7}\u{00F5}es:"
    textReport09 <- "Localiza\u{00E7}\u{00F5}es"
    textReport10 <- "Metadados"
    textReport11 <- "Elementos dispon\u{00ED}veis"
    textReport12 <- c("ID da esta\u{00E7}\u{00E3}o", "Autoridade",
                      "Data de in\u{00ED}cio", "Data de fim",
                      "Longitude", "Latitude", "Altura", "ID alias")
    textReport13 <- c ("Data de in\u{00ED}cio",
                       "Data de fim",
                       "N\u{00FA}mero de registros esperados",
                       "N\u{00FA}mero real de registros",
                       "Registros ausentes (%)")
    textReport14 <- c ("N\u{00FA}o há elementos para esta\u{00E7}\u{00F5}es:")
    
    
    ############################################################################
    # Overview
    textOverview00 <- "Resumo do Banco de Dados"
    textOverview01 <- "Resumo dos dados dispon\u{00ED}veis no banco de dados"
    textOverview02 <- 'Criando resumo (Isso pode levar v\u{00E1}rios minutos)...'
    textOverview03 <- "Guardar a tabela"
    textOverview04 <- c("Vis\u{00E3}o geral", "Por esta\u{00E7}\u{00E3}o", "Por elemento")
    textOverview05 <- "Resumo.csv"
    textOverview06 <- c ("Autoridade",
                         "Elementos dispon\u{00ED}veis",
                         "N\u{00FA}m. de esta\u{00E7}\u{00F5}es",
                         "Data do primeiro registro",
                         "Data do \u{00FA}ltimo registro",
                         "Esta\u{00E7}\u{00E3}o com m\u{00E1}x. n\u{00FA}m. de registros ( 'esta\u{00E7}\u{00E3}o ID')")
    textOverview07 <- c("Nome da esta\u{00E7}\u{00E3}o",
                        "ID da esta\u{00E7}\u{00E3}o",
                        "Nome do Elemento",
                        "Periodo",
                        "Data do primeiro registro",
                        "Data do \u{00FA}ltimo registro",
                        "N\u{00FA}mero de registros",
                        "Per cento (%)")
    
    textOverview08 <- c("Nome do elemento",
                        "Descrip\u{00E7}\u{00E3}o",
                        "Periodo",
                        "codigo no Climsoft",
                        "N\u{00FA}m. de esta\u{00E7}\u{00F5}es",
                        "Data do primeiro registro",
                        "Data do \u{00FA}ltimo registro")
    
    ############################################################################
    # Users and rights
    textUserRights00 <- "Configurar Direitos de Usu\u{00E1}rio"
    textUserRights01 <- "Configurar os direitos dos usu\u{00E1}rios"
    textUserRights02 <- "Guardar as altera\u{00E7}\u{00F5}es"
    textUserRights03 <- "Lista de usu\u{00E1}rios e direitos"
    textUserRights04 <- c("Usu\u{00E1}rio",
                          "Senha", "Mapa", "Tabela",
                          "Gr\u{00E1}ficos",
                          "Relat\u{00F3}rio",
                          "Resumo",
                          "RClimDex",
                          "Direitos de Usu\u{00E1}rio",
                          "Download")
    
    ##########################################################################
    # Export data
    textExport00 <- "Baixar dados"
    textExport01 <- "Baixar dados armazenados na base de dados"
    textExport02 <- "Selecione uma ou mais esta\u{00E7}\u{00F5}es"
    textExport03 <- "Selecione um ou mais elementos"
    textExport04 <- "Intervalo de datas"
    textExport05 <- "Solicitar dados"
    textExport06 <- "Baixar os dados"
    textExport07 <- c("Nome da esta\u{00E7}\u{00E3}o", "ID da esta\u{00E7}\u{00E3}o",
                      "Autoridade", "Longitude", "Latitude",
                      "Eleva\u{00E7}\u{00E3}o (m)", "Nome do Elemento",
                      "Data/Hora", "Valor", "Unidades")
    textExport08 <- "Dados.csv"
    textExport09 <- "Solicitando dados..."
    
    ############################################################################
    # RClimDex
    textRClimDex00 <- "RClimDex"
    textRClimDex01 <- paste0("O RClimDex cria at\u{00E9} 27 \u{00ED}ndices clim\u{00E1}ticos,",
                             "portanto dados di\u{00E1}rios e o conjunto de dados ",
                             "de precipita\u{00E7}\u{00E3}o dispon\u{00ED}vel ser\u{00E3}o usados.")
    textRClimDex02 <- "C\u{00E1}lculo RClimDex"
    
    ############################################################################
    # Check precipitation
    textPrecipCheck00 <- "Verifica\u{00E7}\u{00E3}o de precipita\u{00E7}\u{00E3}o"
    textPrecipCheck01 <- paste0("Uma compara\u{00E7}\u{00E3}o de 'more prcp-data' e 'kl-data'",
                                "Ser\u{00E1} executado baseado em dados di\u{00E1}rios.")
    ####################################################################
    # LOCAL_FILE
    textLocalFile01 <- "Verifique os cabeçalhos do arquivo."
    textLocalFile02 <- "Vari\u{00E1}veis n\u{00E3}o encontradas"
    textLocalFile03 <- "Conjuntos de dados selecionados:"
  }
  
  variables <- grep("text", ls(), value=TRUE)
  textInfo <- vector("list", length(variables))
  names(textInfo) <- variables
  for (ii in 1:length(variables)){
    textInfo[[ii]] <- get(variables[ii])
  }
  return(textInfo)
}

######################################################################
#                  _       _        _____           _       _        #
#                 | |     | |      / ____|         (_)     | |       #
#  _   _ _ __   __| | __ _| |_ ___| (___   ___ _ __ _ _ __ | |_ ___  #
# | | | | '_ \ / _` |/ _` | __/ _ \\___ \ / __| '__| | '_ \| __/ __| #
# | |_| | |_) | (_| | (_| | ||  __/____) | (__| |  | | |_) | |_\__ \ #
#  \__,_| .__/ \__,_|\__,_|\__\___|_____/ \___|_|  |_| .__/ \__|___/ #
#       | |                                          | |             #
#       |_|                                          |_|             #
######################################################################
# Aplicativo para atualizar programas selecionados.
#   - Lista de features que quero implementar:
#     - Uma coisinha pra poder exportar arquivos com nomes diferentes dos originais, talvez numa pasta nova, tem que
#       pensar numa forma massa ainda;
#     - Botão de pesquisa por diretórios para adicionar incrementalmente programas a uma listagem utilizada na função;
#     - Uso de perl regex pra alterar as linhas do programa;
#     - Possivelmente disponibilizar como um aplicativo web no site do Guará;

###############################################
#  _      _ _                    _            #
# | |    (_) |                  (_)           #
# | |     _| |__  _ __ __ _ _ __ _  ___  ___  #
# | |    | | '_ \| '__/ _` | '__| |/ _ \/ __| #
# | |____| | |_) | | | (_| | |  | |  __/\__ \ #
# |______|_|_.__/|_|  \__,_|_|  |_|\___||___/ #
#                                             #
###############################################
ler_libs <- function(packages){
  instalar <- packages[!(packages %in% installed.packages()[, "Package"])]
  
  if(length(instalar) > 0){
    install.packages(pkgs = instalar, dependencies = TRUE)
  }
  invisible(sapply(packages, require, character.only = TRUE))
}

ler_libs(packages = c("shiny", "dplyr", "stringr", "readtext", "purrr", "shinyFiles", "DT"))

################################################
#  _____       _             __                #
# |_   _|     | |           / _|               #
#   | |  _ __ | |_ ___ _ __| |_ __ _  ___ ___  #
#   | | | '_ \| __/ _ \ '__|  _/ _` |/ __/ _ \ #
#  _| |_| | | | ||  __/ |  | || (_| | (_|  __/ #
# |_____|_| |_|\__\___|_|  |_| \__,_|\___\___| #
#                                              #
################################################
shinyUI(fluidPage(
    # Incluindo arquivo CSS:
    theme = "style.css",
    
    # Título da aplicação:
    withTags(
        h2(style = "text-align: center;",
           list("Atualização de ", 
                i("Scripts"),
                span(style = "margin-left: -4px;", ":")))
    ),

    # Seção de cima, com o botão e os dois text inputs:
    fluidRow(
      style = "text-align: center; margin-top: 25px; display: table; margin: 0 auto;",
      column(4,
             # Botão para selecionar os arquivos:
             fileInput(inputId = "l_arq",
                       label = "Adicione arquivos a atualizar:",
                       buttonLabel = tags$div(style = "font-family: 'Raleway', sans-serif;", "Enviar..."),
                       placeholder = "Nada escolhido",
                       multiple = TRUE)
      ),
      
      column(4,
             # Caixa de texto para o quê quer alterar: 
             textInput(inputId = "oque",
                       label = "Valor a procurar:",
                       placeholder = "Strings ou expressões regulares...")
             ),
      
      column(4,
             # Caixa de texto com a string utilizada pra substituir:
             textInput(inputId = "praoque",
                       label = "Valor atualizado:",
                       placeholder = "Uma string...")
             )
    ),
    
    # Seção do meio, com a listagem dos programas:
    fluidRow(
      column(12,
             tags$h2(style = "text-align: center; margin-top: 10px; font-size: 20px;", "Informações sobre os arquivos escolhidos:"),
             tags$div(id = "tabela-info",
                      style = "display: table; margin: 0 auto; font-family: 'Raleway'; margin-top: 25px;",
                      DTOutput("table_l_arq")))
    ),
    
    # Seção inferior, com o botão de baixar os programas alterados:
    downloadButton(outputId = "baixar",
                   label = "Atualizar e baixar")
))

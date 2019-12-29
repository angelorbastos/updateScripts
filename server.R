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

ler_libs(packages = c("shiny", "dplyr", "stringr", "readtext", "purrr", "shinyFiles"))

###############################################
#   _____                 _     _             #
#  / ____|               (_)   | |            #
# | (___   ___ _ ____   ___  __| | ___  _ __  #
#  \___ \ / _ \ '__\ \ / / |/ _` |/ _ \| '__| #
#  ____) |  __/ |   \ V /| | (_| | (_) | |    #
# |_____/ \___|_|    \_/ |_|\__,_|\___/|_|    #
#                                             #
###############################################
shinyServer(function(input, output) {
  # Definindo a tabela da listagem de arquivos:
  output$table_l_arq <- renderDT({
    # Caso ainda não tenha selecionado nenhum arquivo, não retorna nada:
    if(is.null(input$l_arq)){
      return(NULL)
    }
    
    # Pegando a lista de arquivos do input e modificando-a um pouco para renderizar:
    else{
      input$l_arq %>%
        mutate(Nome = ifelse(stringr::str_split_fixed(string = name,
                                                      pattern = "\\.",
                                                      n = 2)[, 1] == "",
                             "Vazio",
                             stringr::str_split_fixed(string = name,
                                                      pattern = "\\.",
                                                      n = 2)[, 1]),
               `Extensão` = stringr::str_split_fixed(string = name,
                                                     pattern = "\\.",
                                                     n = 2)[, 2],
               `Matches` = ifelse(is.null(input$oque) | input$oque == "",
                                  "Procure um valor",
                                  stringr::str_count(string = readtext(file = datapath,
                                                                       verbosity = 0)$text,
                                                     pattern = input$oque))) %>%
        select(Nome, `Extensão`, `Matches`)
    }
  },
  options = list(autoWidth = TRUE,
                 lengthChange = FALSE,
                 paging = FALSE,
                 scrollY = "100px",
                 scrollCollapse = TRUE,
                 language = list(search = "Filtrar na tabela:",
                                 emptyTable = "Sem dados na tabela, por favor selecione acima",
                                 info = "Mostrando _TOTAL_ arquivo(s) ",
                                 infoEmpty = "Não há arquivos a mostrar",
                                 infoFiltered = "(filtrado de um total de _MAX_ arquivos)",
                                 lengthMenu = "Mostrar _MENU_ arquivos",
                                 loadingRecords = "Carregando...",
                                 processing = "Processando...",
                                 zeroRecords = "Nenhum arquivo com este padrão foi encontrado",
                                 paginate = list(first = "Primeiro",
                                                 last = "Último",
                                                 'next' = "Próximo",
                                                 previous = "Anterior")),
                 columnDefs = list(list(className = "dt-center",
                                        targets = 1:2))),
  editable = TRUE,
  rownames = FALSE)

  # Definindo o que acontece quando clica no botão de atualizar e baixar:
  output$baixar <- downloadHandler(
    filename = function(){
      # Caso tenha upado só um arquivo:
      if(nrow(input$l_arq) == 1){
        # O nome do output é o nome do arquivo:
        paste0(input$l_arq %>% select(name))
      }
      
      # Caso tenha upado mais de um arquivo:
      else{
        # O nome do output é 'arquivos.zip', pois todos arquivos vão ser incluídos no zip:
        paste0("arquivos.zip")
      }
    },
    
    content = function(file){
      # Caso tenha upado somente um arquivo:
      if(nrow(input$l_arq) == 1){
        # Só converte a string que pediu pra converter e dá writeBin:
        readtext(file = input$l_arq$datapath,
                 verbosity = 0) %>%
          transmute(novo = str_replace_all(text, input$oque, input$praoque) %>% str_conv("UTF-8")) %>%
          pull(novo) %>%
          as.character() %>%
          writeBin(con = file)
      }
      
      # Caso tenha mais de um arquivo:
      else{
        # Move para um diretório temporário, pra não ter problemas de permissão:
        dir_orig <- setwd(tempdir())
        
        # Ao final da função, retorna ao diretório de trabalho inicial:
        on.exit(setwd(dir_orig))
        
        # Para cada arquivo, converte a string e dá writeBin ao diretório temporário, com o nome original do arquivo:
        readtext(file = input$l_arq$datapath,
                 verbosity = 0) %>%
          transmute(novo = str_replace_all(text,
                                           input$oque,
                                           input$praoque) %>%
                             str_conv("UTF-8")) %>%
          pull(novo) %>%
          as.character() %>%
          map2(.y = walk(.x = input$l_arq$name,
                          .f = file,
                          encoding = "UTF-8"),
                .f = writeBin)

        # Zipa tudo e manda:
        zip(file, 
            input$l_arq$name)
      }
    }
  )
})
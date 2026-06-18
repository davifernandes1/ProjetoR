library(shiny)
library(future)
library(promises)
library(bslib)
library(dplyr)
library(ggplot2)
library(DT)

# Configurações iniciais globais
options(shiny.maxRequestSize = 100 * 1024^2) # Limite expandido para 100MB
plan(multisession) # Paralelismo ativo para a N2

ui <- page_sidebar(
  title = "Painel Analítico de Dados Adaptativo - N3",
  sidebar = sidebar(
    fileInput("file", "Faça upload do seu arquivo CSV", accept = ".csv"),
    hr(),
    uiOutput("controles_dinamicos"), # Controles mudam com base no dataset detectado
    hr(),
    helpText("Processamento assíncrono paralelo e limpeza de dados em tempo de execução.")
  ),
  
  # Área central dinâmica que renderiza o dashboard correto
  uiOutput("dashboard_principal")
)

server <- function(input, output, session) {
  
  # 1. Pipeline de Carregamento Assíncrono e Limpeza de Dados (Data Cleaning)
  dados_processados <- reactive({
    req(input$file)
    filepath <- input$file$datapath
    
    future({
      df <- read.csv(filepath, stringsAsFactors = FALSE)
      
      # Limpeza Automática com TRAVA DE SEGURANÇA para não destruir títulos
      for(col in names(df)) {
        # Se a coluna for de título, nome ou descrição, o R ignora a regra da porcentagem
        if (!grepl("title|name|description", col, ignore.case = TRUE)) {
          if (is.character(df[[col]]) && any(grepl("%$", na.omit(df[[col]])))) {
            df[[col]] <- suppressWarnings(as.numeric(gsub("%", "", df[[col]])) / 100)
          }
        }
      }
      df
    })
  })
  
  # 2. Identificador de Contexto (Fingerprinting)
  tipo_dataset <- reactive({
    req(dados_processados())
    df <- value(dados_processados()) 
    cols <- names(df)
    
    if ("player_name" %in% cols && "acs" %in% cols) return("valorant_players")
    if ("agent_name" %in% cols && "total_utilization" %in% cols) return("valorant_agents")
    if ("map_name" %in% cols && "times_played" %in% cols) return("valorant_maps")
    if (any(c("myanimelist_id", "title") %in% cols) && "Score" %in% cols) return("anime_mal")
    
    return("generico")
  })
  
  # 3. Renderização Dinâmica dos Controles Laterais
  output$controles_dinamicos <- renderUI({
    req(tipo_dataset())
    tipo <- tipo_dataset()
    
    if (tipo == "valorant_players") {
      selectInput("métrica_player", "Ordenar Jogadores Por:", 
                  choices = c("Pontuação de Combate (ACS)" = "acs", "K/D Ratio" = "kd_ratio", "Dano Médio (ADR)" = "adr"))
    } else if (tipo == "anime_mal") {
      sliderInput("filtro_ano", "Filtrar por Ano de Lançamento:", min = 1980, max = 2026, value = c(2010, 2026), step = 1)
    } else {
      helpText("Configurações automáticas padrão otimizadas para este formato.")
    }
  })
  
  # 4. Estruturação Arquitetural dos Dashboards Especializados
  output$dashboard_principal <- renderUI({
    req(tipo_dataset())
    tipo <- tipo_dataset()
    
    if (tipo == "valorant_players") {
      tagList(
        card(card_header("Ranking dos Melhores Jogadores Profissionais"), DTOutput("tabela_players")),
        layout_columns(
          card(card_header("Top 10 Performance Absoluta"), plotOutput("plot_player_bar")),
          card(card_header("Análise de Eficiência: Impacto vs Sobrevivência"), plotOutput("plot_player_scatter"))
        )
      )
    } else if (tipo == "valorant_agents") {
      tagList(
        card(card_header("Métricas de Utilização Global dos Agentes"), DTOutput("tabela_agents")),
        layout_columns(
          card(card_header("Taxa de Escolha Global dos Agentes"), plotOutput("plot_agent_util")),
          card(card_header("Popularidade em Mapas Específicos (Ex: Lotus vs Abyss)"), plotOutput("plot_agent_maps"))
        )
      )
    } else if (tipo == "valorant_maps") {
      tagList(
        card(card_header("Dados Gerais dos Mapas"), DTOutput("tabela_maps")),
        layout_columns(
          card(card_header("Mapas mais Jogados"), plotOutput("plot_maps_pop")),
          card(card_header("Equilíbrio de Mapa: Lado Atacante x Defensor"), plotOutput("plot_maps_balance"))
        )
      )
    } else if (tipo == "anime_mal") {
      tagList(
        card(card_header("Catálogo dos Animes Mais Bem Avaliados"), DTOutput("tabela_animes")),
        layout_columns(
          card(card_header("Top 10 Produções por Média de Nota"), plotOutput("plot_anime_score")),
          card(card_header("Evolução Histórica da Qualidade das Notas"), plotOutput("plot_anime_trend"))
        )
      )
    } else {
      card(card_header("Dataset Genérico Detectado"), DTOutput("tabela_generica"))
    }
  })
  
  # ===========================================================================
  # LOGICA DE RENDERIZAÇÃO DE DADOS (VALORANT PLAYERS)
  # ===========================================================================
  
  output$tabela_players <- renderDT({
    dados_processados() %...>% (function(df) {
      req(input$métrica_player)
      ranking <- df %>% 
        select(player_name, team, acs, kd_ratio, adr, hs_percent) %>%
        arrange(desc(.data[[input$métrica_player]]))
      datatable(ranking, options = list(pageLength = 5), rownames = FALSE)
    })
  })
  
  output$plot_player_bar <- renderPlot({
    req(input$métrica_player)
    dados_processados() %...>% (function(df) {
      top10 <- df %>% arrange(desc(.data[[input$métrica_player]])) %>% head(10)
      ggplot(top10, aes(x = reorder(player_name, .data[[input$métrica_player]]), y = .data[[input$métrica_player]])) +
        geom_bar(stat = "identity", fill = "#fa4454") + 
        coord_flip() + theme_minimal() + labs(x = "Jogador", y = input$métrica_player)
    })
  })
  
  output$plot_player_scatter <- renderPlot({
    dados_processados() %...>% (function(df) {
      ggplot(df, aes(x = acs, y = kd_ratio, label = player_name)) +
        geom_point(aes(size = adr), color = "#0f1923", alpha = 0.7) +
        geom_text(vjust = -1, check_overlap = TRUE, size = 3) +
        theme_minimal() + labs(x = "Pontuação Média de Combate (ACS)", y = "Kill/Death Ratio")
    })
  })
  
  # ===========================================================================
  # LOGICA DE RENDERIZAÇÃO DE DADOS (VALORANT AGENTS)
  # ===========================================================================
  
  output$tabela_agents <- renderDT({
    dados_processados() %...>% (function(df) {
      datatable(df %>% arrange(desc(total_utilization)), options = list(pageLength = 5), rownames = FALSE)
    })
  })
  
  output$plot_agent_util <- renderPlot({
    dados_processados() %...>% (function(df) {
      ggplot(df, aes(x = reorder(agent_name, total_utilization), y = total_utilization)) +
        geom_bar(stat = "identity", fill = "#04d9c4") +
        coord_flip() + theme_minimal() + labs(x = "Agente", y = "Utilização Total")
    })
  })
  
  output$plot_agent_maps <- renderPlot({
    dados_processados() %...>% (function(df) {
      req("Lotus" %in% names(df) && "Abyss" %in% names(df))
      df_pivot <- df %>% head(8) %>% select(agent_name, Lotus, Abyss)
      ggplot(df_pivot) +
        geom_point(aes(x = agent_name, y = Lotus, color = "Lotus"), size = 4) +
        geom_point(aes(x = agent_name, y = Abyss, color = "Abyss"), size = 4) +
        theme_minimal() + labs(x = "Agente", y = "Taxa de Pick por Mapa", color = "Mapas")
    })
  })
  
  # ===========================================================================
  # LOGICA DE RENDERIZAÇÃO DE DADOS (VALORANT MAPS)
  # ===========================================================================
  
  output$tabela_maps <- renderDT({
    dados_processados() %...>% (function(df) {
      datatable(df, options = list(dom = 't'), rownames = FALSE)
    })
  })
  
  output$plot_maps_pop <- renderPlot({
    dados_processados() %...>% (function(df) {
      ggplot(df, aes(x = reorder(map_name, times_played), y = times_played)) +
        geom_bar(stat = "identity", fill = "#5c6bc0") +
        theme_minimal() + labs(x = "Nome do Mapa", y = "Vezes Jogado")
    })
  })
  
  output$plot_maps_balance <- renderPlot({
    dados_processados() %...>% (function(df) {
      req("attack_win_percent" %in% names(df))
      ggplot(df, aes(x = map_name)) +
        geom_bar(aes(y = attack_win_percent, fill = "Ataque"), stat = "identity", alpha = 0.7, width = 0.4, position = position_nudge(x = -0.2)) +
        geom_bar(aes(y = defense_win_percent, fill = "Defesa"), stat = "identity", alpha = 0.7, width = 0.4, position = position_nudge(x = 0.2)) +
        geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
        theme_minimal() + labs(x = "Mapa", y = "Taxa de Vitória por Lado", fill = "Lado")
    })
  })
  
  # ===========================================================================
  # LOGICA DE RENDERIZAÇÃO DE DADOS (ANIME MAL)
  # ===========================================================================
  
  pegar_coluna <- function(df, regex) {
    cols <- names(df)
    match <- cols[grepl(regex, cols, ignore.case = TRUE)]
    if (length(match) > 0) return(match[1])
    return(NULL)
  }
  
  output$tabela_animes <- renderDT({
    dados_processados() %...>% (function(df) {
      req(input$filtro_ano)
      
      col_titulo <- pegar_coluna(df, "^title$|^name$|title_english")
      col_ano <- pegar_coluna(df, "year")
      
      req(col_titulo, col_ano) 
      
      df_anime <- df %>% 
        mutate(Ano_Numerico = suppressWarnings(as.numeric(as.character(.data[[col_ano]])))) %>%
        filter(!is.na(Ano_Numerico)) %>%
        filter(Ano_Numerico >= input$filtro_ano[1] & Ano_Numerico <= input$filtro_ano[2]) %>%
        filter(!is.na(Score) & !is.na(.data[[col_titulo]])) %>%
        filter(nchar(trimws(as.character(.data[[col_titulo]]))) > 1) %>% 
        select(all_of(col_titulo), Ano_Numerico, Score) %>%
        arrange(desc(Score))
      
      datatable(df_anime, 
                colnames = c("Nome do Anime", "Ano de Lançamento", "Nota (Score)"),
                options = list(pageLength = 10, dom = 'ftip'), 
                rownames = FALSE)
    })
  })
  
  output$plot_anime_score <- renderPlot({
    dados_processados() %...>% (function(df) {
      col_titulo <- pegar_coluna(df, "^title$|^name$|title_english")
      req(col_titulo)
      
      top10 <- df %>% 
        filter(!is.na(Score) & !is.na(.data[[col_titulo]])) %>%
        filter(nchar(trimws(as.character(.data[[col_titulo]]))) > 1) %>%
        arrange(desc(Score)) %>% 
        head(10)
      
      top10$nome_curto <- substr(as.character(top10[[col_titulo]]), 1, 35)
      
      ggplot(top10, aes(x = reorder(nome_curto, Score), y = Score)) +
        geom_bar(stat = "identity", fill = "#ffb300") +
        coord_flip() + 
        theme_minimal() + 
        labs(x = "Título do Anime", y = "Nota (Score)", title = "Top 10 Animes por Nota")
    })
  })
  
  output$plot_anime_trend <- renderPlot({
    dados_processados() %...>% (function(df) {
      col_ano <- pegar_coluna(df, "year")
      req(col_ano)
      
      df_grouped <- df %>% 
        mutate(Ano_Numerico = suppressWarnings(as.numeric(as.character(.data[[col_ano]])))) %>%
        filter(!is.na(Ano_Numerico) & !is.na(Score)) %>%
        group_by(Ano_Numerico) %>% 
        summarise(Nota_Media = mean(Score, na.rm = TRUE))
      
      ggplot(df_grouped, aes(x = Ano_Numerico, y = Nota_Media)) +
        geom_line(color = "#007bc2", linewidth = 1) + 
        geom_point(color = "#007bc2", size = 2) +
        theme_minimal() + 
        labs(x = "Ano de Lançamento", y = "Nota Média Anual", title = "Evolução Histórica da Qualidade das Notas")
    })
  })
  
  output$tabela_generica <- renderDT({
    dados_processados() %...>% (function(df) { datatable(head(df, 100)) })
  })
}
shinyApp(ui, server)
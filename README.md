Painel Analítico de Dados Adaptativo (Projeto N3)

Este repositório/diretório contém o código-fonte do Painel Analítico de Dados Adaptativo, uma aplicação web desenvolvida para a avaliação N3 do curso de Análise e Desenvolvimento de Sistemas (UNICESUSC).

O sistema utiliza a linguagem R e o framework Shiny para realizar Análise Exploratória de Dados (AED) de forma totalmente automatizada, aplicando conceitos avançados de concorrência e limpeza de dados assíncrona.

Principais Funcionalidades

Identificação Dinâmica (Dataset Fingerprinting): O sistema lê os cabeçalhos do arquivo .csv e adapta a interface e os gráficos automaticamente para o contexto do negócio (ex: estatísticas de jogadores, dados de animes, mapas, etc.).

Processamento Assíncrono: Utilização de threads paralelas (pacote future) para o processamento de arquivos pesados, impedindo o congelamento da interface web (Non-blocking UI).

Data Cleaning Automático: Conversão automática de porcentagens em texto para decimais matemáticos, remoção de linhas nulas e padronização de formatação em tempo de execução, garantindo a integridade dos gráficos.

Pré-requisitos e Instalação

Para rodar este projeto na sua máquina local, você precisará instalar a linguagem R e o seu principal ambiente de desenvolvimento.

Passo 1: Instalação dos Softwares Base

Baixe e instale a linguagem R: CRAN R Project

Baixe e instale o RStudio (IDE): Posit RStudio Desktop

Passo 2: Instalação das Bibliotecas (Dependências)

Abra o RStudio. Na parte inferior da tela, localize a aba Console, copie o comando abaixo, cole lá e aperte Enter. Isso fará o download de todos os pacotes necessários para o projeto funcionar:

install.packages(c("shiny", "future", "promises", "bslib", "dplyr", "ggplot2", "DT"))


Como Executar o Projeto

Abra o RStudio.

Vá no menu superior e clique em File > New File > R Script.

Salve o arquivo no seu computador com o nome exato de app.R.

Copie todo o código-fonte final do projeto e cole dentro deste arquivo app.R.

No canto superior direito da janela de edição de código, um botão verde com o símbolo de "Play" chamado ▶ Run App irá aparecer. Clique nele.

A aplicação web abrirá instantaneamente em uma nova janela.

Como Testar e Usar

Com a aplicação aberta:

Clique no botão "Browse..." no menu lateral esquerdo.

Selecione qualquer arquivo .csv da sua máquina.

Aguarde o processamento assíncrono ser finalizado (o painel carregará os controles laterais dinâmicos).

Utilize os seletores (dropdowns) e filtros (sliders) para interagir com as tabelas descritivas interativas e os gráficos gerados em tempo real.

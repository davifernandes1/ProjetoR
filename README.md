# 📊 Painel Analítico de Dados Adaptativo (Projeto N3)

> Uma aplicação web em **R** e **Shiny** para automatizar a Análise Exploratória de Dados (AED) com concorrência e processamento assíncrono. Desenvolvido para a avaliação N3 do curso de Análise e Desenvolvimento de Sistemas (UNICESUSC).

---

## 🚀 Principais Funcionalidades

* **🧠 Identificação Dinâmica (Dataset Fingerprinting):** O sistema lê os cabeçalhos do arquivo `.csv` e adapta a interface e os gráficos automaticamente para o contexto do negócio (ex: estatísticas de jogadores de Valorant, dados de animes, mapas, etc.).
* **⚡ Processamento Assíncrono:** Utilização de threads paralelas (pacote `future`) para o processamento de arquivos pesados, impedindo o congelamento da interface web (*Non-blocking UI*).
* **🧹 Data Cleaning Automático:** Conversão de porcentagens em texto para decimais matemáticos, remoção de linhas nulas e padronização de formatação em tempo de execução, garantindo a integridade dos gráficos.

---

## 🛠️ Pré-requisitos e Instalação

Para rodar este projeto na sua máquina local, você precisará instalar a linguagem R e o seu ambiente de desenvolvimento.

### Passo 1: Instalação dos Softwares Base
1. Baixe e instale a linguagem R: [CRAN R Project](https://cran.r-project.org/)
2. Baixe e instale o RStudio (IDE): [Posit RStudio Desktop](https://posit.co/download/rstudio-desktop/)

### Passo 2: Instalação das Bibliotecas
Abra o **RStudio**. Na parte inferior da tela, localize a aba **Console**, copie o comando abaixo, cole lá e aperte `Enter`:

install.packages(c("shiny", "future", "promises", "bslib", "dplyr", "ggplot2", "DT"))

💻 Como Executar o Projeto
Abra o RStudio.

Vá no menu superior e clique em File > New File > R Script.

Salve o arquivo no seu computador com o nome exato de app.R.

Copie todo o código-fonte final do projeto e cole dentro deste arquivo app.R.

No canto superior direito da janela de edição de código, clique no botão verde ▶ Run App.

A aplicação web abrirá instantaneamente em uma nova janela.

📂 Como Testar e Usar
Clique no botão "Browse..." no menu lateral esquerdo.

Selecione qualquer arquivo .csv da sua máquina (Recomendamos os datasets de teste: player_stats.csv, maps_stats.csv ou mal_anime.csv).

Aguarde o processamento assíncrono finalizar.

Utilize os seletores (dropdowns) e filtros (sliders) para interagir com as tabelas interativas e os gráficos gerados em tempo real.

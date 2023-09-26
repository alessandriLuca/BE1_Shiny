#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinymaterial)
  library(shinybusy)
library(shinyWidgets)
source("/srv/shiny-server/makeDataset.R")
source("/srv/shiny-server/functions.R")

username=random_user <- generate_random_username(length=20)
# Crea la UI per la Shiny App
# Installa il pacchetto Shiny se non è già installato

# Specifica il percorso della cartella
percorso_cartella <- "/scratch/"

# Funzione per ottenere una lista di nomi di cartelle nella directory
get_folder_names <- function() {
  folder_names <- list.dirs(path = percorso_cartella, full.names = FALSE, recursive = FALSE)
  return(folder_names)
}





library(shinymanager)

showDownloadButton <- reactiveVal(FALSE)







ui <- fluidPage(

  titlePanel("Compose your new Dataset"),

  # Creazione dei box dinamici con nomi delle cartelle
  fluidRow(
    # Prima colonna
    column(6,
      uiOutput("numeri_box1")
    ),

    # Seconda colonna
    column(6,
      uiOutput("numeri_box2")
    )
  ),
  actionButton("stampare", "Generate"),
  verbatimTextOutput("risultati"),

  # Utilizza renderUI per mostrare il pulsante di download solo se showDownloadButton() è TRUE
  uiOutput("downloadButtonOutput"),
  div(
    class = "spacer",  # Nuova classe "spacer" per il div vuoto
    style = "height: 150px;"  # Imposta l'altezza desiderata
  ),
  div(
        class = "footer",
        includeHTML("footer.html")
    )


)

tags$head(
  tags$style(HTML("
    body {
      padding-bottom: 100px; /* Spazio inferiore per il footer */
    }

    .footer {
      position: fixed;
      bottom: 0;
      left: 0;
      width: 100%;
      background-color: white;
      text-align: center;
      z-index: 999; /* Imposta una z-index maggiore per il footer */
    }

    .footer-logo {
      height: 100px;
      line-height: 100px;
    }
  "))
)



# Funzione per generare i box in base al numero di cartelle e mostrare i nomi delle cartelle
server <- function(input, output, session) {

  showDownloadButton <- reactiveVal(FALSE)
  # Ottieni i nomi delle cartelle
  folder_names <- get_folder_names()
  num_folders <- length(folder_names)

  # Genera dinamicamente i box con nomi delle cartelle
  output$numeri_box1 <- renderUI({
    numeric_inputs <- lapply(1:ceiling(num_folders / 2), function(i) {
      box_name <- folder_names[i]
      numericInput(
        inputId = paste0("numero", i),
        label = paste("Cell number for ", box_name),
        value = 0

      )
    })
    do.call(tagList, numeric_inputs)
  })

  # Genera dinamicamente i box con nomi delle cartelle per la seconda colonna
  output$numeri_box2 <- renderUI({
    numeric_inputs <- lapply((ceiling(num_folders / 2) + 1):num_folders, function(i) {
      box_name <- folder_names[i]
      numericInput(
        inputId = paste0("numero", i),
        label = paste("Cell number for ", box_name),
        value = 0
      )
    })
    do.call(tagList, numeric_inputs)
  })

  risultati <- reactiveVal(NULL)

  # Funzione per stampare +10 una volta premuto il pulsante
  observeEvent(input$stampare, {
  show_modal_gif(
        src = "giphy2.gif",
        text = "Working on it!",
  modal_size = "l"
      )
      risultati_elenco <- character(0)
    cell.lines <- c()
    n.cells <- c()


    for (i in 1:num_folders) {
      input_id <- paste0("numero", i)
      numero <- as.numeric(input[[input_id]])
      risultati_elenco <- c(risultati_elenco, paste("For the dataset ", folder_names[i], "you sampled ", numero," cells."))
      cell.lines <- append(cell.lines, folder_names[i])
      if(!is.numeric(numero)){numero=0}
      n.cells <- append(n.cells, numero)
    }
    dir.create(paste("/srv/shiny-server/users/", username, sep = ""))
    F <- makeDataset(input.folder = "/scratch/", output.folder = paste("/srv/shiny-server/users/", username, sep = ""), cell.lines = cell.lines, n.cells = n.cells)
    risultati(risultati_elenco)
    #showModal(modalDialog(
    #  title = "Risultati",
    #  verbatimTextOutput("risultati")
    #))
    showDownloadButton(TRUE)
      remove_modal_gif()

  })

  # Output per i risultati
  output$risultati <- renderText({
    risultati_val <- risultati()
    if (!is.null(risultati_val)) {
      paste(risultati_val, collapse = "\n")
    }
  })

  # Renderizza il pulsante di download solo quando showDownloadButton() è TRUE
  output$downloadButtonOutput <- renderUI({
    if (showDownloadButton()) {
      downloadButton("downloadData", "Download")
    }
  })

  output$downloadData <- downloadHandler(
    filename = function() {
      basename(paste("/srv/shiny-server/users/", username, "/output.tar.gz", sep = ""))
    },
    content = function(file) {
      file.copy(
        from = paste("/srv/shiny-server/users/", username, "/output.tar.gz", sep = ""),
        to = file
      )
    }
  )




onSessionEnded(function() {
    # Elimina la cartella temporanea associata all'utente
    if (file.exists(paste("/srv/shiny-server/users/", username, sep = ""))) {
      unlink(paste("/srv/shiny-server/users/", username, sep = ""), recursive = TRUE)
    }
  }, session)

  # ...











  }

# Esegui l'app Shiny
shinyApp(ui = ui, server = server)

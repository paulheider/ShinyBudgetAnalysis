## ShinyBudgetAnalysis ui.R

shinyUI(
    fluidPage(
        titlePanel( "Fiscal Analysis" ),

        ## Create a new Row in the UI for selectInputs
        fluidRow(
            ## The empty columns center the year drop-down menu
            ## and serve as slots for later filters
            column(4,
                   "" ),
            column(4,
                   selectInput("year",
                               ## CHANGEME:  what years do you have budget
                               ##            exports for?
                               label = "Fiscal Year",
                               ## TODO: autofill these years
                               choices = c( "2015" ,
                                           "2016" ,
                                           "2017" ),
                               ## TODO:  auto select most recent data
                               ## CHANGEME:  what do you want the default year
                               ##            to be?
                               selected = "2017" )
                   ),
            column(4,
                   "" )
        ),
        fluidRow(
            tabsetPanel(
                tabPanel( "Avg. Expenses" , dataTableOutput( "monthlyExpensesTable" ) ),
                tabPanel( "Plot" , plotOutput( "monthlyExpensesPlot" ) ),
                tabPanel( "All Expenses" , dataTableOutput( "expensesTable" ) ),
                tabPanel( "Account Summaries" , 'The author intended for this widget to be empty.' ) ,
                tabPanel( "Consumables" ,
                         fluidRow(
                             plotOutput( "monthlyConsumablesPlot" ) ),
                         fluidRow( dataTableOutput( "monthlyConsumablesTable" ) )
                         ),
                tabPanel( "Nuts" , 'The author intended for this widget to be empty.' ) ,
                tabPanel( "Regulars" , 'The author intended for this widget to be empty.' ) ,
                tabPanel( "One Timers" , 'The author intended for this widget to be empty.' )
            )
            
        )
    )
)

## census-app server.R

require( 'ggplot2' )
require( 'tidyr' )
require( 'lubridate' )

source("helpers.R")

shinyServer(
    function(input, output) {
        
        expenses <- reactive({
            loadExpenses( input$year )
        })
        
        per_month_expenses <- reactive({
            expenses_breakdown( dataset = expenses() )
        })

        per_month_consumables <- reactive({ 
            expenses() %>%
                mutate( Year = year( Date ) ) %>%
                mutate( Month = months( Date ) ) %>%
                mutate( numMonth = month( Date ) ) %>%
                group_by( Year , Month , AccountName , numMonth ) %>%
                summarise( Expenses = round( sum( In ) , 0 ) ) %>%
                spread( AccountName , Expenses ) %>%
                ## CHANGEME:  Consumables consist of the three categories 'booze',
                ##            'groceries', and 'restaurants'.  If you have different
                ##            category names for your consumables, add/replace as
                ##            required here and below.
                select( Month , Year , Booze , Groceries , Restaurants , numMonth ) %>%
                mutate( Total = sum( Booze , Groceries , Restaurants , na.rm = TRUE ) ) %>%
                arrange( Year , numMonth ) %>%
                ungroup( numMonth )
        })

        plottable_consumables <- reactive({
            per_month_consumables() %>%
                select( -Total ) %>%
                ## CHANGEME:  Consumables consist of the three categories 'booze',
                ##            'groceries', and 'restaurants'.  If you have different
                ##            category names for your consumables, add/replace as
                ##            required here, above, and below.
                gather( Type , Amount , Booze:Restaurants )
        })
        
        avg_monthly_expenses <- reactive({
            average_expenses( dataset = per_month_expenses() )
        })
        
        #####################################
        output$expensesTable <- renderDataTable(
            expenses()
        )
        
        output$monthlyExpensesTable <- renderDataTable(
            per_month_expenses()
        )

        output$monthlyConsumablesTable <- renderDataTable(
            per_month_consumables() %>%
            select( -numMonth ) %>%
            ## CHANGEME:  Consumables consist of the three categories 'booze',
            ##            'groceries', and 'restaurants'.  If you have different
            ##            category names for your consumables, add/replace as
            ##            required here and above.
            rbind( c( "" , "" , sum( .$Booze ) , sum( .$Groceries ) , sum( .$Restaurants ) , sum( .$Total ) ) )
        )
        
        output$monthlyConsumablesPlot <- renderPlot({
            ggplot( data = plottable_consumables() ,
                   aes( x = numMonth ,
                       y = Amount ,
                       fill = Type , color = Type ) ) +
                geom_point( size = 3 ) +
                geom_line() +
                scale_x_discrete( labels = per_month_expenses()$Month ) +
                theme_bw() +
                theme( axis.text.x = element_text( angle = 45 , hjust = 1 ) )
        })
        
        output$monthlyExpensesPlot <- renderPlot({
            month_names <- per_month_expenses()$Month
            ##
            ggplot( data = per_month_expenses() %>%
                        select( -Total ) %>%
                        gather( Type , Amount , Nut:Regular ) ,
                   aes( x = numMonth ,
                       y = Amount ,
                       fill = Type , color = Type ) ) +
                geom_hline( data = avg_monthly_expenses() %>%
                                filter( Type != "Total" ) ,
                           aes( yintercept = Average ,
                               size = 1.5 ,
                               linetype = 3 ,
                               fill = Type , color = Type ) ) +
                scale_linetype_identity() +
                geom_point( aes( size = 2 ) ) +
                geom_line() +
                #facet_wrap( ~ Year ) +
                scale_x_discrete( labels = month_names ) +
                theme_bw() +
                theme( axis.text.x = element_text( angle = 45 , hjust = 1 ) )

        })
    }
)


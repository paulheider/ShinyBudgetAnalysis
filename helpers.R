require( 'dplyr' )
require( 'readr' )

loadAccount <- function( filename = '' ,
                         type = '' ){
    account <- read_csv( file = filename ,
                        ## CHANGEME:  you may need to update the date format
                        col_types = cols_only( Date = col_date( "%m/%d/%Y" ) ,
                                              ## Ignore all but a few critical fields
                                              `Account Name` = 'c' ,
                                              ##"Number",
                                              Description = 'c' ,
                                              ##"Notes",
                                              ##"Memo",
                                              Category = 'c' ,
                                              ##"Type",
                                              ##"Action",
                                              ##"Reconcile",
                                              ##"To With Sym",
                                              ##"From With Sym",
                                              ##"To Rate/Price",
                                              ##"From Rate/Price"
                                              `To Num.` = 'n' ,
                                              `From Num.` = 'n' ) )
    account <- 
        account %>%
        filter( !is.na( Date ) ) %>%
        rename( AccountName = `Account Name` ,
               In = `To Num.` ,
               Out = `From Num.` )
    account$AccountName <- factor( account$AccountName )
    account$Category <- factor( account$Category )
    ##
    if( type == 'expenses' ){
        account <-
            ## TODO:  allow configuration of account types in
            ##        from a file or the UI
            account %>%
            ## CHANGEME:  you probably want to personalize how accounts are
            ##            categorized to fit your own budgeting style
            ## OR together the list of accounts that you want to
            ## treat as your 'Nut' expenses (those things that
            ## you can't drop from the budget)
            mutate( Class = ifelse( AccountName == 'Electricity' |
                                    AccountName == 'Phone' |
                                    AccountName == 'Gas' |
                                    AccountName == 'Internet' |
                                    AccountName == 'Insurance' |
                                    AccountName == 'Rent' ,
                                   yes = 'Nut' ,
                                   ## OR together the list of accounts that you
                                   ## consider to be 'One Time' expenses (things
                                   ## that happened to come up this month but
                                   ## aren't part of your regular budget)
                                   no = ifelse( AccountName == 'Car Repair' |
                                                AccountName == 'Fees' |
                                                AccountName == 'Taxes' |
                                                AccountName == 'Live Event' |
                                                AccountName == 'Dental' |
                                                AccountName == 'Clothing' |
                                                AccountName == 'Airplane' ,
                                               yes = 'One Time' ,
                                               ## Everything else is considered a 'Regular'
                                               ## expense (something explicitly part of your
                                               ## budget every month)
                                               no = 'Regular' ) ) ) %>%
            select( -Out )
        account$Class <- factor( account$Class )
        ##unique( account$AccountName )
    }
    return( account )
}

## TODO: support loading expenses from a single file and use date filtering
##       to restrict which entries pass through
loadExpenses <- function( the_year ){
    ## CHANGEME:  for every year that you added to the ui.R selectInput field,
    ##            you need to add an expenses file to load here
    if( the_year == "1995" ){
        expenses <- loadAccount( filename = 'data/sample_expenses_1995.csv' , type = 'expenses' )
    } else if( the_year == "1996" ){
        ## You can combine two (or more) files into a single year like so:
        expenses <- loadAccount( filename = 'data/sample_expenses_1996H1.csv' , type = 'expenses' ) %>%
            bind_rows( loadAccount( filename = 'data/sample_expenses_1996H2.csv' , type = 'expenses' ) )
    } else if( the_year == "1997" ){
        ## Keep the latest year's expenses up to date with regular exports
        expenses <- loadAccount( filename = 'data/sample_expenses_1997_ytd.csv' , type = 'expenses' )
    }
    return( expenses )
}

expenses_breakdown <- function( dataset = expenses ){
    return( dataset %>%
            mutate( Year = year( Date ) ) %>%
            mutate( Month = months( Date ) ) %>%
            mutate( numMonth = month( Date ) ) %>%
            group_by( Year , Month , numMonth , Class ) %>%
            summarise( Expenses = sum( In ) ) %>%
            spread( Class , Expenses ) %>%
            arrange( Year , numMonth ) %>%
            select( Month , Year , Nut , `One Time` , Regular ) %>%
            mutate( Total = sum( Nut , `One Time` , Regular , na.rm = TRUE ) ) )
}

average_expenses <- function( dataset = per_month_expenses ){
    return( dataset %>%
            gather( "Type" , "Amount" , Nut:Total ) %>%
            ungroup() %>%
            group_by( Type ) %>%
            summarise( Average = mean( Amount ) ) )
}

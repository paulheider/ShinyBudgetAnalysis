ShinyBudgetAnalysis
===================

A [https://shiny.rstudio.com](Shiny app) ([https://www.r-project.org](R)-based dashboard) that gives insight into your [https://www.gnucash.org/](GnuCash) budget habits over time.


Configuration
-------------

Running this Shiny app requires a few configuration steps.

1. Download or clone this code to `$SBA_DIR` (whereever you want that to be):
   
   ```bash
   export SBA_DIR=/path/to/parent/directory/ShinyBudgetAnalysis
   
   cd $SBA_DIR
   '''

2. Export your data from GnuCash

   a. `File` -> `Export` -> `Export Transactions to CSV`
   b. Click `Forward` (Use the default settings for "Quotes" and "Separators")
   c. Select the `Expenses` radio button
   d. Click on `Expenses` in the box below the radio buttons and then click `Select Subaccounts`
   e. Choose a date range (optional)
   f. Click `Forward`
   g. Save the `.csv` file in `$SBA_DIR/data`

3. Find all the `CHANGEME` entries in the R files and update them with your preferred values

4. Launch the Shiny server from within your favorite R shell or program
   
   ```R
   ## Start the server and automatically launch my default browser to show the app
   runApp( "$SBA_DIR" )
   
   ## As above but show me the underlying code below the app
   runApp( "$SBA_DIR" , display.mode = "showcase" )
   
   ## As above but I'll open the app myself in an browser
   runApp( "$SBA_DIR" , display.mode = "showcase" , launch.browser = FALSE )
   '''


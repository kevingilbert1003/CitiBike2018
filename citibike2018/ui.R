header <- dashboardHeader(
  title = "CitiBike Trips"
)

body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("plot1", height = 550)
           )
    ),
    column(width = 3,
           box(width = NULL, status = "warning"
               , dateRangeInput('date', label = 'Trip Date',
                                start = '2018-01-01', end = '2018-12-31', 
                                min = '2018-01-01', max = '2018-12-31'
               )
               , sliderInput('start_hour', label = 'Start Hour',
                             min = 0, max = 24,
                             value = c(6,10))
               , selectInput('day_of_week', label = 'Day of Week',
                             choices = c('Sun', 'Mon', 'Tue', 'Wed'
                                         , 'Thu', 'Fri', 'Sat'),
                             selected = c('Mon', 'Tue', 'Wed', 'Thu', 'Fri'),
                             multiple = T)
               , selectInput('gender', label = 'Gender',
                             choices = list(Female = 1, Male = 2, Unknown = 0),
                             selected = c(1,2,0),
                             multiple = T)
               , selectInput('usertype', label = 'User Type',
                             choices = c('Subscriber', 'Customer'),
                             selected = c('Subscriber'),
                             multiple = T)
               , sliderInput('age', label = 'Age',
                             min = 0, max = 100,
                             value = c(18,50))
               # , p(
               #   class = "text-muted",
               #   paste("Press update to Render Map with your selected filters."
               #   )
               # )
               , actionButton("update", "Update Chart")
           )
    )
  ),
  
  fluidRow(
    column(width = 9,
           box(width = NULL, solidHeader = TRUE,
               leafletOutput("plot2", height = 550)
           )
    ),
    column(width = 3,
           box(width = NULL, status = "warning"
               , dateRangeInput('date2', label = 'Trip Date',
                                start = '2018-01-01', end = '2018-12-31', 
                                min = '2018-01-01', max = '2018-12-31'
               )
               , sliderInput('start_hour2', label = 'Start Hour',
                             min = 0, max = 24,
                             value = c(14,18))
               , selectInput('day_of_week2', label = 'Day of Week',
                             choices = c('Sun', 'Mon', 'Tue', 'Wed'
                                         , 'Thu', 'Fri', 'Sat'),
                             selected = c('Sat', 'Sun'),
                             multiple = T)
               , selectInput('gender2', label = 'Gender',
                             choices = list(Female = 1, Male = 2, Unknown = 0),
                             selected = c(1,2,0),
                             multiple = T)
               , selectInput('usertype2', label = 'User Type',
                             choices = c('Subscriber', 'Customer'),
                             selected = c('Customer'),
                             multiple = T)
               , sliderInput('age2', label = 'Age',
                             min = 0, max = 100,
                             value = c(18,50))
               # , p(
               #   class = "text-muted",
               #   paste("Press update to Render Map with your selected filters."
               #   )
               # )
               , actionButton("update2", "Update Chart")
           )
    )
  )
)

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)

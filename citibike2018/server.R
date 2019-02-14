function(input, output, session) {
  
  #' Reactively Update Filters
  filtered_data = 
    eventReactive(input$update, {
      raw %>%
        .[ds >= input$date[1] & ds <= input$date[2] & 
            gender %in% input$gender & 
            usertype %in% input$usertype & 
            age >= input$age[1] & age <= input$age[2] & 
            start_hour >= input$start_hour[1] & start_hour <= input$start_hour[1] & 
            day_of_week %in% input$day_of_week]
    }, ignoreNULL = FALSE)
  
  #' Plot density map
  output$plot1 = 
    renderLeaflet({
      if(is.null(filtered_data())) { }
      else { 
        plot_leaflet(
          data = filtered_data() %>%
            .[ , `:=`(lat = start_lat, lng = start_lng)])
      }
    })
  
  #' Reactively Update Filters
  filtered_data2 = 
    eventReactive(input$update2, {
      raw %>%
        .[ds >= input$date2[1] & ds <= input$date2[2] & 
            gender %in% input$gender2 & 
            usertype %in% input$usertype2 & 
            age >= input$age2[1] & age <= input$age2[2] & 
            start_hour >= input$start_hour2[1] & start_hour <= input$start_hour2[1] & 
            day_of_week %in% input$day_of_week2]
    }, ignoreNULL = FALSE)
  
  #' Plot density map
  output$plot2 = 
    renderLeaflet({
      if(is.null(filtered_data2())) { }
      else { 
        plot_leaflet(
          data = filtered_data2() %>%
            .[ , `:=`(lat = start_lat, lng = start_lng)])
      }
    })
}
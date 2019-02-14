
raw =
  list.files('data/cleaned/') %>%
  file.path('data/cleaned', .) %>%
  lapply(., fread) %>%
  rbindlist()

nyc_map = get_map(location = c(-74.025, 40.70, -73.9375, 40.80)
                  , source = "osm")

library(leaflet)
library(leaflet.extras)

leaflet(data = 
          raw %>%
          copy %>%
          .[ , `:=`(lat = start_lat, lng = start_lng)] %>%
          .[lng <= -73.9375 & lng >= -74.025
            & lat >= 40.70 & lat <= 40.80]) %>%
  addProviderTiles(providers$CartoDB.Positron) 



L2 <- Leaflet$new()
L2$setView(c(40.75, -74), zoom = 12)
L2$tileLayer(provider = "Esri.WorldGrayCanvas")

L2$addAssets(jshead = c(
  "http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js"
))

trip_dat = raw[ , list(count = log10(.N))
                , list(lat, lng)]
trip_dat[ , count := count / max(count)]
trip_dat = toJSONArray2(na.omit(trip_dat), json = F, names = F)

# Add javascript to modify underlying chart
L2$setTemplate(afterScript = sprintf("
                                     <script>
                                     var addressPoints = %s
                                     var heat = L.heatLayer(addressPoints).addTo(map)           
                                     </script>
                                     ", rjson::toJSON(trip_dat)
))

L2

library(htmltools)
library(htmlwidgets)

heatPlugin = htmlDependency("Leaflet.heat", "99.99.99",
                             src = c(href = "http://leaflet.github.io/Leaflet.heat/dist/"),
                             script = "leaflet-heat.js"
)

registerPlugin = function(map, plugin) {
  map$dependencies = c(map$dependencies, list(plugin))
  map
}
#' summarize density
trip_dat = 
  raw %>%
  .[start_hour >= 6 & start_hour <= 10
    & usertype == 'Subscriber'
    & day_of_week %in% c('Mon', 'Tue', 'Wed', 'Thu', 'Fri')
    & age >= 18 & age <= 50
    & gender %in% c(1,2,0)] %>%
  .[ , list(count = (.N))
     , list(lat = start_lat, lng = start_lng)]
trip_dat[ , count := count / max(count) * 25]
trip_dat = toJSONArray2(na.omit(trip_dat), json = F, names = F)

leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  setView(lat = 40.75, lng = -73.98, zoom = 12) %>%
  registerPlugin(heatPlugin) %>%
  onRender("function(el, x, data) {
      L.heatLayer(data, {radius: 35, blur: 10}).addTo(this);
           }"
           , data = trip_dat)

  

L2$addAssets(jshead = c(
  "http://leaflet.github.io/Leaflet.heat/dist/leaflet-heat.js"
))


# Add javascript to modify underlying chart
L2$setTemplate(afterScript = sprintf("
                                     <script>
                                     var addressPoints = %s
                                     var heat = L.heatLayer(addressPoints).addTo(map)           
                                     </script>
                                     ", rjson::toJSON(trip_dat)
))








ggmap(nyc_map) +
    stat_density2d(
      data = 
        raw[trip_month %in% c(201803, 201806, 201809, 201812)] %>%
        .[ , list(lat = `start station latitude`
                  , lng = `start station longitude`
                  , type = 'start'
                  , trip_month = trip_month %>% factor(levels = c(201803, 201806, 201809, 201812)
                                                       , labels = c('March', 'June', 'September', 'December')))]
      , aes(x = lng
            , y = lat
            , fill = ..level..
            , alpha = ..level..)
      , geom = "polygon"
      , size = 0.01
      , bins = 16) +
    scale_fill_gradient(low = "blue", high = "red") +
    scale_alpha(range = c(0, 0.3), guide = FALSE) + 
    theme(legend.position = 'none',
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
  facet_wrap('trip_month', ncol = 4)

  
ggmap(nyc_map) +
    stat_density2d(
      data = 
        rbind(
          raw[trip_month %in% c(201803, 201806, 201809, 201812)] %>%
            .[ , list(lat = `start station latitude`
                      , lng = `start station longitude`
                      , type = 'start')]
          , raw[trip_month %in% c(201803, 201806, 201809, 201812)] %>%
            .[ , list(lat = `end station latitude`
                      , lng = `end station longitude`
                      , type = 'end')])
      , aes(x = lng
            , y = lat
            , fill = ..level..
            , alpha = ..level..)
      , geom = "polygon"
      , size = 0.01
      , bins = 16) +
    scale_fill_gradient(low = "blue", high = "red") +
    scale_alpha(range = c(0, 0.3), guide = FALSE) + 
    theme(legend.position = 'none',
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
  facet_wrap('type', ncol = 2)

  
ggmap(nyc_map) +
    stat_density2d(
      data = 
        raw[trip_month %in% c(201803, 201806, 201809, 201812)] %>%
        .[ , list(lat = `start station latitude`
                  , lng = `start station longitude`
                  , type = 'start'
                  # , trip_month = trip_month %>% factor(levels = c(201803, 201806, 201809, 201812)
                  #                                      , labels = c('March', 'June', 'September', 'December'))
                  # , gender = gender %>% factor(levels = c(1,2)
                  #                              , labels = c('Male', 'Female'))
                  , start_hour = hour(ymd_hms(starttime)))] %>%
        .[ , start_time_bucket := 
             ifelse(start_hour <= 4
                    , '10pm-4am'
                    , ifelse(start_hour <= 10
                             , '4am-10am'
                             , ifelse(start_hour <= 16
                                      , '10am-4pm'
                                      , ifelse(start_hour <= 20
                                               , '4pm-10pm'
                                               , '10pm-4am')))) %>%
             factor(levels = c('4am-10am', '10am-4pm', '4pm-10pm', '10pm-4am'))]
      , aes(x = lng
            , y = lat
            , fill = ..level..
            , alpha = ..level..)
      , geom = "polygon"
      , size = 0.01
      , bins = 16) +
    scale_fill_gradient(low = "blue", high = "red") +
    scale_alpha(range = c(0, 0.3), guide = FALSE) + 
    theme(legend.position = 'none',
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
  facet_wrap('start_time_bucket', ncol = 4)

  
ggmap(nyc_map) +
    stat_density2d(
      data = 
        raw[trip_month %in% c(201803, 201806, 201809, 201812) & gender %in% c(1,2)] %>%
        .[ , list(lat = `start station latitude`
                  , lng = `start station longitude`
                  , type = 'start'
                  # , trip_month = trip_month %>% factor(levels = c(201803, 201806, 201809, 201812)
                  #                                      , labels = c('March', 'June', 'September', 'December'))
                  , gender = gender %>% factor(levels = c(1,2)
                                               , labels = c('Male', 'Female'))
                  , start_hour = hour(ymd_hms(starttime)))] %>%
        .[ , start_time_bucket := 
             ifelse(start_hour <= 4
                    , '10pm-4am'
                    , ifelse(start_hour <= 10
                             , '4am-10am'
                             , ifelse(start_hour <= 16
                                      , '10am-4pm'
                                      , ifelse(start_hour <= 20
                                               , '4pm-10pm'
                                               , '10pm-4am')))) %>%
             factor(levels = c('4am-10am', '10am-4pm', '4pm-10pm', '10pm-4am'))]
      , aes(x = lng
            , y = lat
            , fill = ..level..
            , alpha = ..level..)
      , geom = "polygon"
      , size = 0.01
      , bins = 16) +
    scale_fill_gradient(low = "blue", high = "red") +
    scale_alpha(range = c(0, 0.3), guide = FALSE) + 
    theme(legend.position = 'none',
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
  facet_grid(gender ~ start_time_bucket)

 
ggmap(nyc_map) +
    stat_density2d(
      data = 
        raw[trip_month %in% c(201803, 201806, 201809, 201812) & gender %in% c(1,2)] %>%
        .[ , list(lat = `start station latitude`
                  , lng = `start station longitude`
                  , type = 'start'
                  , usertype
                  , start_hour = hour(ymd_hms(starttime)))]  %>%
        .[ , start_time_bucket := 
             ifelse(start_hour <= 4
                    , '10pm-4am'
                    , ifelse(start_hour <= 10
                             , '4am-10am'
                             , ifelse(start_hour <= 16
                                      , '10am-4pm'
                                      , ifelse(start_hour <= 20
                                               , '4pm-10pm'
                                               , '10pm-4am')))) %>%
             factor(levels = c('4am-10am', '10am-4pm', '4pm-10pm', '10pm-4am'))]
      , aes(x = lng
            , y = lat
            , fill = ..level..
            , alpha = ..level..)
      , geom = "polygon"
      , size = 0.01
      , bins = 16) +
    scale_fill_gradient(low = "blue", high = "red") +
    scale_alpha(range = c(0, 0.3), guide = FALSE) + 
    theme(legend.position = 'none',
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank()) + 
  facet_grid(usertype ~ start_time_bucket)


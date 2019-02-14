library(shiny)
library(magrittr)
library(data.table)
library(shinydashboard)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(rCharts)

#' Load Data
#' =======================
raw = readRDS('data/raw.Rds')

#' Plot Leaflet Heatmap
#' =======================
heatPlugin = htmlDependency("Leaflet.heat", "99.99.99",
                            src = c(file = "js/"),
                            script = "leaflet-heat.js"
)

registerPlugin = function(map, plugin) {
  map$dependencies = c(map$dependencies, list(plugin))
  map
}

plot_leaflet = function(data) { 
  trip_dat = data[ , list(count = (.N))
                  , list(lat, lng)]
  trip_dat[ , count := count / max(count) * 25]
  trip_dat = toJSONArray2(na.omit(trip_dat), json = F, names = F)
  
  leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    setView(lat = 40.75, lng = -73.98, zoom = 12) %>%
    registerPlugin(heatPlugin) %>%
    onRender("function(el, x, data) {
             L.heatLayer(data, {radius: 50, blur: 10}).addTo(this); 
             }"
             , data = trip_dat)
  }
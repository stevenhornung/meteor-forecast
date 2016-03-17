GOOGLE_API_KEY = Meteor.settings.google.key
BASE_GOOGLE_GEOCODE_URL = "https://maps.googleapis.com/maps/api/geocode/json"

FORECAST_API_KEY = Meteor.settings.forecast.key
BASE_FORECAST_URL = "https://api.forecast.io/forecast/"

Future = Npm.require("fibers/future")
request = Npm.require('request')

Forecast = {
  getForecast: (zipCode, date) ->
    getForecast(zipCode, date)
}

getForecast = (zipCode, date) ->
  forecastIcon = null
  forecastRainChance = null
  future = new Future()
  googleGeocodeUrl = BASE_GOOGLE_GEOCODE_URL + "?address=" + zipCode + "&key=" + GOOGLE_API_KEY

  request googleGeocodeUrl, (err, res, body) ->
    if not err and res.statusCode is 200
      try
        results = JSON.parse(body).results
        geometry = _.first(results).geometry
        future.return geometry.location
      catch e
        future.return e
    else
      future.return err

  location = future.wait()

  if location and location.lat
    future = new Future()
    forecastUrl = BASE_FORECAST_URL + FORECAST_API_KEY + "/" + location.lat + "," + location.lng
    request forecastUrl, (err, res, body) ->
      if not err and res.statusCode is 200
        try
          future.return JSON.parse(body)
        catch e
          future.return e
      else
        future.return err

    fullForecast = future.wait()

    hourStart = moment(date).tz("America/New_York").startOf('hour').toDate()
    hourlyWeather = fullForecast.hourly.data
    dayHour = _.find hourlyWeather, (hour) -> moment(new Date(hour.time*1000)).tz("America/New_York").isSame(hourStart)
    forecastIcon = dayHour.icon if dayHour
    forecastPrecipChance = (dayHour.precipProbability * 100) if dayHour

  if forecastIcon
    {forecastIcon: forecastIcon, forecastPrecipChance: forecastPrecipChance}
  else
    null
appConfig = require '../config/app'

allowCrossdomain = (req, res, next) ->
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Origin', "#{appConfig.frontend.host}")

  next()

module.exports = {
  allowCrossdomain: allowCrossdomain
}
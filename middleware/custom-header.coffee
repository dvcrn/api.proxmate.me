appConfig = require '../config/app'

headerMiddleware = (req, res, next) ->
  res.header('Access-Control-Allow-Headers', 'Content-Type')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Origin', "#{appConfig.frontend.host}")

  res.header('Surrogate-Control', "max-age=#{appConfig.frontend.cdn_cache_age}")
  res.header('Cache-Control', "max-age=#{appConfig.frontend.cache_age}")
  next()

module.exports = {
  headerMiddleware: headerMiddleware
}

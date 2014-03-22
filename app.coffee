express = require 'express'
routes = require './routes'

packageApi = require './routes/api/package'
serverApi = require './routes/api/server'
countryApi = require './routes/api/country'
userApi = require './routes/api/user'
urlApi = require './routes/api/url'

{headerMiddleware} = require './middleware/custom-header'
config = require './config/app'

http = require 'http'
path = require 'path'
mongoose = require 'mongoose'

app = express()

exports.app = app
exports.server = http.createServer(app)


app.set 'port', process.argv[2] || 3000
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ejs'
app.use express.favicon()
app.use express.logger('dev')
app.use express.json()
app.use express.urlencoded()
app.use headerMiddleware
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, 'public'))
app.disable('x-powered-by')


if 'development' == app.get('env')
  app.use(express.errorHandler())

app.get('/package/list.json', packageApi.list)
app.get('/package/update.json', packageApi.update)
app.get('/package/:id/install.json', packageApi.install)
app.get('/package/:id.json', packageApi.detail)

app.get('/server/list.json', serverApi.list)

app.get('/user/validate/:key.json', userApi.validate)
app.get('/user/:id.json', userApi.detail)

app.get('/country/:id.json', countryApi.detail)
app.get('/url/list.json', urlApi.list)

if __dirname + '/server.js' == process.argv[1]
  http.createServer(app).listen app.get('port'), ->
    mongoose.connect(config.database.mongo_url)
    console.log('Express server listening on port ' + app.get('port'))

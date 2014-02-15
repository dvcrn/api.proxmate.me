Server = exports.Server = require('../../models/server')
ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Server, {}, res, (collection) ->
    res.json(collection)
  )
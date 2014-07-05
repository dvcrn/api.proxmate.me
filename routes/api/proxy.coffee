Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')

config = require '../../config/app'

ApiHelper = require('./api-helper')

exports.whitelist = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    whitelist = {}

    for pkg in packageCollection
      for routing in pkg.routing
        if routing.host
          whitelist[routing.host] = true

      for host in pkg.hosts
        whitelist[host] = true

    res.json(Object.keys(whitelist))
  )

Server = exports.Server = require('../../models/server')
ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  handleRequest = (isDonator) ->
    ApiHelper.setJson(res)
    ApiHelper.handleFind(Server, {}, res, (collection) ->
      servers = collection.filter (server) ->
        # Do not show private servers
        if server.isPrivate 
          return

        # Only show servers that doesn't require key
        # Or the user provides a valid key
        if server.requireKey and !isDonator
          return

        return {
          "host": server.host,
          "port": server.port,
          "user": server.user,
          "password": server.password,
          "country": server.country,
          "ip": server.ip
        }

      res.json(servers)
    )

  if req.query.key?
    ApiHelper.validateKey req.query.key, (status, message) ->
      if status
        handleRequest true
      else 
        handleRequest false
  else
    handleRequest false


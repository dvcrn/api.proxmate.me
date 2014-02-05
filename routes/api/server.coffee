Server = exports.Server = require('../../models/server')

exports.list = (req, res) ->
  res.set('Content-Type', 'application/json')

  Server.find({}, (err, servers) ->
    if err
      res.send(500, [])
    else
      for server in servers
        delete server.ip

      res.json(servers)
  )
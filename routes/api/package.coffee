
User = exports.User = require('../../models/user')
Pkg = exports.Pkg = require('../../models/package')

exports.list = (req, res) ->
  res.set('Content-Type', 'application/json')

  Pkg.find({}, (err, packages) ->
    if err
      res.send(500, '[]')
    else
      responseArray = []
      # Strip package information down
      for pkg in packages
        responseArray.push {
          id: pkg._id,
          name: pkg.name,
          version: pkg.version,
          url: pkg.url,
          createdAt: pkg.createdAt
        }

      res.json(responseArray)
  )

exports.update = (req, res) ->
  res.set('Content-Type', 'application/json')

  Pkg.find({}, (err, packages) ->
    if err
      res.send(500, '[]')
    else
      responseObject = {}
      for pkg in packages
        responseObject[pkg._id] = pkg.version

      res.json(responseObject)
  )

exports.detail = (req, res) ->
  res.set('Content-Type', 'application/json')

  id = req.params.id
  Pkg.findById(id, (err, pkg) ->
    if err
      res.send(500, '[]')
    else if !pkg
      res.send(404, '[]')
    else
      res.json(pkg)
  )
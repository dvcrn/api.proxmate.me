
User = exports.User = require('../models/user.js');
Pkg = exports.Pkg = require('../models/package.js');

exports.list = (req, res) ->
  res.set('Content-Type', 'application/json');

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

exports.detail = (req, res) ->
  res.set('Content-Type', 'application/json');

  id = req.params.id
  Pkg.findById(id, (err, pkg) ->
    if err or pkg.length == 0
      res.send(500, '[]')
    else
      res.json(pkg)
  )
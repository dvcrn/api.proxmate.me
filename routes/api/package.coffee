User = exports.User = require('../../models/user')
Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')

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
          description: pkg.description,
          smallIcon: pkg.smallIcon,
          pageUrl: pkg.pageUrl
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
      if err.name is 'CastError'
        res.send(404, '[]')
      else
        res.send(500, '[]')
    else if !pkg
      res.send(404, '[]')
    else
      Country.findById(pkg.country, (err, countryResult) ->
        domains = []
        for routing in pkg.routing
          if routing.startsWith
            domains.push("#{routing.startsWith}*")

          if routing.host
            domains.push("#{routing.host}")

          for containRule in routing.contains
            domains.push("*#{containRule}*")

        res.json({
          id: pkg._id,
          name: pkg.name,
          version: pkg.version,
          description: pkg.description,
          smallIcon: pkg.smallIcon,
          bigIcon: pkg.bigIcon,
          pageUrl: pkg.pageUrl,
          country: {
            'title': countryResult.title,
            'flag': countryResult.flag,
            'shortHand': countryResult.shortHand
          },
          screenshots: pkg.screenshots,
          touchedDomains: domains,
          hosts: pkg.hosts,
          createdAt: pkg.createdAt
        })
      )
  )

exports.install = (req, res) ->
  res.set('Content-Type', 'application/json')

  id = req.params.id
  Pkg.findById(id, (err, pkg) ->
    if err
      if err.name is 'CastError'
        res.send(404, '[]')
      else
        res.send(500, '[]')
    else if !pkg
      res.send(404, '[]')
    else
      res.json({
        id: pkg._id,
        name: pkg.name,
        version: pkg.version,
        smallIcon: pkg.smallIcon,
        pageUrl: pkg.pageUrl,
        country: pkg.country,
        routing: pkg.routing,
        hosts: pkg.hosts
      })
  )
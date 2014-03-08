User = exports.User = require('../../models/user')
Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')

ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    responseArray = []
    # Strip package information down
    for pkg in packageCollection
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
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    responseObject = {}
    for pkg in packageCollection
      responseObject[pkg._id] = pkg.version

    res.json(responseObject)
  )


exports.detail = (req, res) ->
  ApiHelper.setJson(res)
  # Get the package content
  ApiHelper.handleFindById(Pkg, req.params.id, res, (packageObject) ->
    # Query the Country
    ApiHelper.handleFindById(Country, packageObject.country, res, (countryObject) ->
      # Query the user
      ApiHelper.handleFindById(User, packageObject.user, res, (userObject) ->
        domains = []
        for routing in packageObject.routing
          if routing.startsWith
            domains.push("#{routing.startsWith}*")

          if routing.host
            domains.push("#{routing.host}")

          for containRule in routing.contains
            domains.push("*#{containRule}*")

        res.json({
          id: packageObject._id,
          name: packageObject.name,
          version: packageObject.version,
          description: packageObject.description,
          smallIcon: packageObject.smallIcon,
          bigIcon: packageObject.bigIcon,
          pageUrl: packageObject.pageUrl,
          user: {
            'username': userObject.username,
            'email': userObject.email,
            'twitterHandle': userObject.twitterHandle
          },
          country: {
            'title': countryObject.title,
            'flag': countryObject.flag,
            'shortHand': countryObject.shortHand
          },
          screenshots: packageObject.screenshots,
          touchedDomains: domains,
          hosts: packageObject.hosts,
          createdAt: packageObject.createdAt
        })
      )
    )
  )

exports.install = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFindById(Pkg, req.params.id, res, (packageObject) ->
    res.json({
      id: packageObject._id,
      name: packageObject.name,
      version: packageObject.version,
      smallIcon: packageObject.smallIcon,
      pageUrl: packageObject.pageUrl,
      country: packageObject.country,
      routing: packageObject.routing,
      hosts: packageObject.hosts
    })
  )
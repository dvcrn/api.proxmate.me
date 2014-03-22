User = exports.User = require('../../models/user')
Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')

config = require '../../config/app'

ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    responseArray = []
    # Strip package information down
    for pkg in packageCollection
      responseArray.push {
        id: pkg._id,
        requireKey: pkg.requireKey,
        name: pkg.name,
        description: pkg.description,
        smallIcon: pkg.smallIcon,
        pageUrl: pkg.pageUrl
      }

    res.json(responseArray)
  )


exports.update = (req, res) ->

  handleRequest = (isDonator) ->
    ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
      responseObject = {}
      for pkg in packageCollection
        # In case a key requires a key, we need to check if the user is providing one
        if pkg.requireKey
          responseObject[pkg._id] = -1

          if isDonator
            responseObject[pkg._id] = pkg.version
        else
          responseObject[pkg._id] = pkg.version

      return res.json(responseObject)
    )

  if req.query.key?
    ApiHelper.validateKey req.query.key, (status, message) ->
      if status
        handleRequest true
      else
        handleRequest false
  else
     handleRequest false


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
          requireKey: packageObject.requireKey,
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
    # Prepare response object
    responseObject =
      id: packageObject._id,
      name: packageObject.name,
      version: packageObject.version,
      smallIcon: packageObject.smallIcon,
      pageUrl: packageObject.pageUrl,
      country: packageObject.country,
      routing: packageObject.routing,
      hosts: packageObject.hosts

    # Check for accessLevel
    if packageObject.requireKey
      # Check if we even have a access key set
      ApiHelper.requireKey req, res, ->
        res.json(responseObject)
    else
      res.json(responseObject)
  )

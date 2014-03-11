User = exports.User = require('../../models/user')
Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')

config = require '../../config/app'
crypto = require('crypto')

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
    # Check for accessLevel
    if packageObject.requireKey
      # Check if we even have a access key set
      if not req.query.key
        res.json({message: 'This ressource requires a valid key. Do you have one?'}, 401)
        return

      # Try to decrypt the key
      decipher = crypto.createDecipher('aes-256-cbc', config.crypto.pepper)
      decryptedKey = decipher.update(req.query.key, 'base64', 'utf8');
      try
        decryptedKey = decryptedKey + decipher.final('utf8')
      catch error
        res.json({message: 'The key you entered is invalid. Please provide a valid one.'}, 401)
        return

      # Query to see if we have a user with that key
      User.findById(decryptedKey, (err, obj) ->
        if err or !obj
          res.json({message: 'The key you entered is invalid. Please provide a valid one.'}, 401)
          return

        if new Date() >= obj.expiresAt
          res.json({message: 'The key you have entered is not valid anymore. Please consider renewing it :)'}, 401)
          return
      )

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
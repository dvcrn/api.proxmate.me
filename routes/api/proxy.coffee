Pkg = exports.Pkg = require('../../models/package')
Country = exports.Country = require('../../models/country')
Server = exports.Server = require('../../models/server')

Config = require '../../config/app'
Cloudflare = require '../../library/cloudflare'

ApiHelper = require('./api-helper')

Url = require 'url'

exports.whitelist = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    whitelist = {}
    addHostToWhitelist = (host) ->
      # Check if there is already a wildcard entry covering the current host
      if "*.#{host}" in Object.keys(whitelist) or ".#{host}" in Object.keys(whitelist)
        return

      # Check if the current element is a wildcard host (*.foo.com, .foo.com)
      if host.indexOf("*") != -1 or host.search(/^\./g) != -1
        wildcardhost = host.replace("*", "")
        # Generate a regex rule which matches subdomains for the current entry
        regexWildcardhost = host.replace("*.", ".*")
        if host.search(/^\./g) != -1
          regexWildcardhost = host.replace(".", ".*")

        # Check all existing hosts if they match the current wildcard
        # if we find a match, delete it. It shouldn't be in the output
        for we in Object.keys(whitelist)
          regexObject = new RegExp(regexWildcardhost, "g")
          if we.search(regexObject) != -1
            delete whitelist[we]

        # Also delete the original wildcard entry. * is not valid for squid
        delete whitelist[host]

        # Add the correct one (without star)
        whitelist[wildcardhost] = true
      else
        whitelist[host] = true

    for pkg in packageCollection
      for routing in pkg.routing
        if routing.startsWith
          addHostToWhitelist Url.parse(routing.startsWith).host

        if routing.host
          addHostToWhitelist(routing.host)


      for host in pkg.hosts
        addHostToWhitelist(host)



    res.json(Object.keys(whitelist))
  )

exports.heartbeat = (req, res) ->
  ip = req.headers['fastly-client-ip'] || req.ip
  if req.method == 'GET'
    res.send('please use post')
    return

  if req.query.accesskey != Config.cloudflare.accesskey
    res.send('invalid access key')
    return

  ApiHelper.setJson(res)
  ApiHelper.handleFind(Server, {'host': req.body.hostname}, (serverCollection) ->
    if serverCollection == null or serverCollection.length == 0
      Server.create({
        host: req.body.hostname,
        port: req.body.port,
        user: req.body.username,
        password: req.body.password,
        country: req.body.countryId,
        ip: ip,
        isPrivate: true
      }, (err, server) ->
        Cloudflare.addARecord(req.body.hostname, ip, ->
          res.json({success: true, created: true})
        )
      )
    else
      res.json({success: true, created: false})
  )


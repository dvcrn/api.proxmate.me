config = exports.config = require '../config/app'

class Cloudflare
  constructor: ->
    @cloudflare = require('cloudflare').createClient {
      email: config.cloudflare.email
      token: config.cloudflare.token
    }

  findDomain: (domain, fn) ->
    @cloudflare.listDomainRecords config.cloudflare.domain, (err, res) ->
      fn res.reduce (prev, current) ->
        if current.name == domain
          return current
        return prev
      , false

  addARecord: (domain, target, fn) ->
    @cloudflare.addDomainRecord config.cloudflare.domain, {
      type: 'A',
      name: domain,
      content: target
    }, (err, res) ->
      fn res

  addCname: (domain, target, fn) ->
    @cloudflare.addDomainRecord config.cloudflare.domain, {
      type: 'CNAME',
      name: domain,
      content: target
    }, (err, res) ->
      fn res

module.exports = new Cloudflare()

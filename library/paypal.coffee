class Paypal
  # TODO expand api with real evaluation
  extractIpnFromRequest: (request) ->
    return request

  verifyIpn: (ipn, callback) ->
    callback true

  module.exports = new Paypal()

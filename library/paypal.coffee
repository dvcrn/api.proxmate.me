exports.request = request = require 'request'

class Paypal
  getRequest: ->
    return request

  verifyIpn: (ipn, callback) ->
    request = @getRequest()

    console.log request

    requestParams = []

    for param, value of ipn
      value = value.replace(/%0A/ig, "%0D%0A")
      requestParams.push "#{param}=#{value}"
    requestString = requestParams.join '&'

    console.log requestString

    request.get "https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate&#{requestString}", (err, res, body) ->
      if body == 'VERIFIED'
        callback true
      else
        callback false

  module.exports = new Paypal()

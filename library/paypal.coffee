exports.request = request = require 'request'

class Paypal
  getRequest: ->
    return request

  extractIpnFromRequest: (request) ->
    paypalParams = [
      "mc_gross",
      "protection_eligibility",
      "address_status",
      "payer_id",
      "tax",
      "address_street",
      "payment_date",
      "payment_status",
      "charset",
      "address_zip",
      "first_name",
      "mc_fee",
      "address_country_code",
      "address_name",
      "notify_version",
      "custom",
      "payer_status",
      "address_country",
      "address_city",
      "quantity",
      "verify_sign",
      "payer_email",
      "txn_id",
      "payment_type",
      "last_name",
      "address_state",
      "receiver_email",
      "payment_fee",
      "receiver_id",
      "txn_type",
      "item_name",
      "mc_currency",
      "item_number",
      "residence_country",
      "test_ipn",
      "handling_amount",
      "transaction_subject",
      "payment_gross",
      "shipping"]

    out = {}
    for param in paypalParams
      if request[param]?
        out[param] = request[param]

    return out

  verifyIpn: (ipn, callback) ->
    request = @getRequest()

    requestParams = []
    for param, value of ipn
      requestParams.push "#{param}=#{value}"
    requestString = requestParams.join '&'

    request.get "https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate&#{requestString}", (err, res, body) ->
      if body == 'VERIFIED'
        callback true
      else
        callback false

  module.exports = new Paypal()

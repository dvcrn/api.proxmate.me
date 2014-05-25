ApiHelper = exports.ApiHelper = require('./api-helper')
Paypal = exports.Paypal = require('../../library/paypal')
User = exports.User = require('../../models/user')

exports.endpoint = (req, res) ->
  if req.method == 'GET'
    res.send('please use post')
    return

  # Make sure we are getting valid json in the request
  if !req.body.txn_type?
    res.send('invalid payload')
    return

  # Only allow web accept and recurring payment
  if req.body.txn_type != 'web_accept' && req.body.txn_type != 'recurring_payment'
    res.send('invalid transaction type')
    return

  # Make sure the IPN request is valid
  ipn = req.body
  Paypal.verifyIpn ipn, (isValid) ->
    if !isValid
      res.send('failure')
      return

    # Pass sanitized IPN to model for db stuffz
    User.createOrUpdateIpn ipn, (success) ->
      if !success
        res.send 'failure'
        return

      res.send 'success'

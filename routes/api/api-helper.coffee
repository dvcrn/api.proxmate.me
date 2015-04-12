User = exports.User = require('../../models/user')

config = exports.config = require '../../config/app'
crypto = exports.crypto = require('../../library/crypto')

class ApiHelper
  handle: (model, functionName, query, responseObject, callback) ->
    directlyHandleRequest = true
    if typeof responseObject == 'function'
      callback = responseObject
      directlyHandleRequest = false

    result = []
    error = false
    model[functionName](query, (err, databaseObject) ->
      if err
        error = true
        if err.name is 'CastError'
          result = [404, '[]']
        else
          result = [500, '[]']
      else if !databaseObject
        error = true
        result = [404, '[]']
      else
        result = [databaseObject]

      if error and directlyHandleRequest
        responseObject.send.apply(this, result)
      else if error
        callback null
      else
        callback.apply(this, result)
    )

  handleFindById: (model, id, responseObject, callback) ->
    @handle(model, 'findById', id, responseObject, callback)

  handleFind: (model, query, responseObject, callback) ->
    @handle(model, 'find', query, responseObject, callback)

  setJson: (responseObject) ->
    responseObject.set('Content-Type', 'application/json')

  validateKey: (donationKey, callback) ->
    # Try to decrypt the key
    decryptedKey = crypto.decryptKey(donationKey)

    if not decryptedKey
      callback false, 'Misformated key.'

    # Query to see if we have a user with that key
    User.findById(decryptedKey, (err, obj) ->
      if err or !obj
        callback false, 'The key you entered is invalid or misformated. Please provide a valid one.'
        return

      if new Date() >= obj.expiresAt
        callback false, 'Sorry, the key you have entered is not valid anymore. Please consider renewing it :). (Note: If you just renewed your key, it could take up to 10 minutes until the new one is propagated correctly)'
        return

      return callback true
    )

  requireKey: (req, res, callback) ->
    if not req.query.key
      res.json({message: 'This is a donator only package, sorry. Please make sure you have a valid donation key.'}, 401)
      return false

    @validateKey(req.query.key, (status, message) ->
      if status
        callback()
      else
        res.json({message: message}, 401)
    )

module.exports = new ApiHelper()

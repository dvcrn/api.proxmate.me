User = exports.User = require('../../models/user')

config = exports.config = require '../../config/app'
crypto = exports.crypto = require('../../library/crypto')

class ApiHelper
  handle: (model, functionName, query, responseObject, callback) ->
    model[functionName](query, (err, databaseObject) ->
      if err
        if err.name is 'CastError'
          responseObject.send(404, '[]')
        else
          responseObject.send(500, '[]')
      else if !databaseObject
        responseObject.send(404, '[]')
      else
        callback databaseObject
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
        callback false, 'The key you entered is invalid. Please provide a valid one.'
        return

      if new Date() >= obj.expiresAt
        callback false, 'The key you have entered is not valid anymore. Please consider renewing it :)'
        return

      return callback true
    )

  requireKey: (req, res, callback) ->
    if not req.query.key
      res.json({message: 'This ressource requires a valid key. Do you have one?'}, 401)
      return false

    @validateKey(req.query.key, (status, message) ->
      if status
        callback()
      else
        res.json({message: message}, 401)
    )

module.exports = new ApiHelper()

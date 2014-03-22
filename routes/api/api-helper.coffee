User = exports.User = require('../../models/user')

config = exports.config = require '../../config/app'
crypto = exports.crypto = require('crypto')

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

  validateKey: (donationKey) ->
    # Try to decrypt the key
    decipher = crypto.createDecipher('aes-256-cbc', config.crypto.pepper)
    decryptedKey = decipher.update(donationKey, 'base64', 'utf8');
    try
      decryptedKey = decryptedKey + decipher.final('utf8')
    catch error
      return {success: false, message: 'The key you entered is invalid. Please provide a valid one.'}

    # Query to see if we have a user with that key
    User.findById(decryptedKey, (err, obj) ->
      if err or !obj
        return {success: false, message: 'The key you entered is invalid. Please provide a valid one.'}

      if new Date() >= obj.expiresAt
        return {success: false, message: 'The key you have entered is not valid anymore. Please consider renewing it :)'}

      return {success: true}
    )

  requireKey: (req, res) ->
    if not req.query.key
      res.json({message: 'This ressource requires a valid key. Do you have one?'}, 401)
      return

    validationResult = @validateKey(req.query.key)
    if validationResult.success
      return true

    res.json({message: validationResult.message}, 401)
    return false


module.exports = new ApiHelper()

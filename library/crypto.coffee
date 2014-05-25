crypto = require 'crypto'
config = exports.config = require '../config/app'

class Crypto
  getCipher: ->
    crypto.createCipher('aes-256-cbc', config.crypto.pepper)

  getDecipher: ->
    crypto.createDecipher('aes-256-cbc', config.crypto.pepper)

  encryptKey: (key) ->
    try
      # Long key
      cipher = @getCipher()
      encryptedKey = cipher.update(key, 'utf8', 'base64')
      encryptedKey = encryptedKey + cipher.final('base64')
    catch error
      # Short key
      cipher = @getCipher()
      cipher.update(key, 'utf8', 'base64')
      encryptedKey = cipher.final('base64')

    return encryptedKey

  decryptKey: (key) ->
    try
      # Long Key
      cipher = @getDecipher()
      decryptedKey = cipher.update(key, 'base64', 'utf8')
      decryptedKey = decryptedKey + cipher.final('utf8')
    catch error
      # Short key
      decipher = @getDecipher()
      cipher.update(key, 'base64', 'utf8')
      decryptedKey = decipher.final('utf8')

    return decryptedKey

module.exports = new Crypto()

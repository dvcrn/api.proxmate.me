{assert} = require 'chai'
sinon = require 'sinon'

crypto = require '../../library/crypto'

config = exports.config = require '../../config/app'

describe 'Crypto', ->
  beforeEach ->
    config.crypto.pepper = 'salt'

  describe 'normal length', ->
    token = '532ee1f1beb64d4cd8859fad'
    encryptedToken = "s+/KdIdPLWzsSVywB47hESKLK0Y7q1u6vjWig8EulTY="
    it 'encrypt keys', ->
      assert.equal(encryptedToken, crypto.encryptKey(token))

    it 'decrypt keys', ->
      assert.equal(token, crypto.decryptKey(encryptedToken))

  describe 'short keys', ->
    token = 'foo'
    encryptedToken = "aVPxwNcXDqwyFllMz+ID3Q=="

    it 'encrypt keys', ->
      assert.equal(encryptedToken, crypto.encryptKey(token))

    it 'decrypt keys', ->
      assert.equal(token, crypto.decryptKey(encryptedToken))

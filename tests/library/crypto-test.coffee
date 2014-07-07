{assert} = require 'chai'
sinon = require 'sinon'

crypto = require '../../library/crypto'

config = exports.config = require '../../config/app'

describe 'Crypto', ->
  beforeEach ->
    config.crypto.pepper = 'salt'

  describe 'invalid key', ->
    token = '5381b860467088b687097307'
    encryptedToken = "eACZH/aqRS C4 cqrTFX + uuCdXEKPV06ItIu1w2jygJw="
    it 'encrypt keys', ->
      assert.equal("eACZH/aqRSC4/cqrTFX+uuCdXEKPV06ItIu1w2jygJw=", crypto.encryptKey(token))

    it 'decrypt keys', ->
      assert.equal(null, crypto.decryptKey(encryptedToken))

  describe 'normal length', ->
    token = '5381b860467088b687097307'
    encryptedToken = "eACZH/aqRSC4/cqrTFX+uuCdXEKPV06ItIu1w2jygJw="
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

request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'

{mockUser} = require '../../testdata/single-user'

ApiHelper = require('../../../routes/api/api-helper')

describe 'User Api', ->

  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  afterEach ->
    this.sandbox.restore()

  describe 'detail', ->
    it 'generates the detail page correctly', (done) ->
      # Fake helper to directly return the object
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> callback mockUser

      expectedData = {
        username: mockUser.username,
        twitterHandle: mockUser.twitterHandle,
        email: mockUser.email
      }

      request "http://127.0.0.1:3000/user/52e51a98217d32e2270e211f.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)
        done()

    it 'reacts correctly on nonexisting ID', (done) ->
      # Fake helper to always return 404
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> res.send('[]', 404)

      request "http://127.0.0.1:3000/user/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

  describe 'validate', ->
    it 'should return isValid:false on invalid key', (done) ->
      # the validator module will return false so we can test our response
      validateKeyStub = this.sandbox.stub ApiHelper, 'validateKey', (k, c) -> c false, 'foo'

      request "http://127.0.0.1:3000/user/validate/foo.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), {isValid: false, message: 'foo'})
        done()

    it 'should return isValid: true on correct key', (done) ->
      validateKeyStub = this.sandbox.stub ApiHelper, 'validateKey', (k, c) -> c true

      request "http://127.0.0.1:3000/user/validate/asdf.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), {isValid: true})
        done()

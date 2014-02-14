api = require '../../../routes/api/user'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
{baseTests} = require './helper'

{mockUser} = require '../../testdata/single-user'

describe 'User Api', ->

  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  describe 'detail', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

      # Stub the findById function and return a mock user
      this.sandbox.stub(api.User, 'findById', (id, callback) ->
        if id is mockUser._id
          callback null, mockUser
        else
          callback({
            message: 'Cast to ObjectId failed for value "52e51a98217d32e2270e211f" at path "_id"',
            name: 'CastError',
            type: 'ObjectId',
            value: '52e51a98217d32e2270e211f',
            path: '_id'
          }, null)
      )

    afterEach ->
      this.sandbox.restore()


    # We only want these 2 elements to be in the output json
    expectedData = {
      username: mockUser.username,
      email: mockUser.email
    }

    # Call our helper, which will execute all necessary functions
    baseTests.call(
      this,
      'http://127.0.0.1:3000/user/52e51a98217d32e2270e211f.json',
      expectedData,
      api.User
    )

    it 'reacts correctly on nonexisting ID', (done) ->
      request "http://127.0.0.1:3000/user/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()
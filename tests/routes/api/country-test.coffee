api = require '../../../routes/api/country'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
{baseTests} = require './helper'

{mockCountry} = require '../../testdata/country'

describe 'Country API', ->
  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  describe 'detail', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      # Stub the findById function and return a mock country
      this.sandbox.stub(api.Country, 'findById', (id, callback) ->
        if id is mockCountry._id
          callback null, mockCountry
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

    expectedData = {
      title: mockCountry.title,
      shortHand: mockCountry.shortHand,
      flag: mockCountry.flag
    }

    baseTests.call(
      this,
      'http://127.0.0.1:3000/country/52e5c40294ed6bd4032daa49.json',
      expectedData,
      api.Country
    )

    it 'reacts correctly on nonexisting ID', (done) ->
      request "http://127.0.0.1:3000/country/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'

{mockCountry} = require '../../testdata/country'

ApiHelper = require('../../../routes/api/api-helper')

describe 'Country API', ->
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

    it 'generates the country detail page correctly', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> callback mockCountry

      expectedData = {
        title: mockCountry.title,
        shortHand: mockCountry.shortHand,
        flag: mockCountry.flag
      }

      request "http://127.0.0.1:3000/country/52e5c40294ed6bd4032daa49.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)
        done()

    it 'reacts correctly on nonexisting ID', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> res.send('[]', 404)

      request "http://127.0.0.1:3000/country/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

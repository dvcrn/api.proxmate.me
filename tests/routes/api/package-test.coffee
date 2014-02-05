api = require '../../../routes/api/package'
{app} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
{baseTests} = require './helper'
sinon = require 'sinon'

mockPackages = [{
  "name": "Test Package",
  "version": 1,
  "url": "http://pandora.com",
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",
  "_id": "52e5c59e18bf010c04b0ef9e",
  "createdAt": new Date(1390790046874).getTime(),
  "routeRegex": [
    "host == 'www.pandora.com'"
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com"
  ],
  "__v": 0
}, {
  "name": "Test Package 2",
  "version": 2,
  "url": "http://google.com",
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",
  "_id": "1337",
  "createdAt": new Date(1390790046874).getTime(),
  "routeRegex": [
    "host == 'www.pandora.com'"
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com"
  ],
  "__v": 0
}]

describe 'Package Api', ->
  before (done) ->
    app.listen 3000
    done()

  after (done) ->
    app.close()
    done()

  # Generate stubs for mongoose functions
  before ->
    this.stubs = [
      sinon.stub(api.Pkg, 'findById', (id, callback) ->
        for pkg in mockPackages
          if pkg._id == id
            callback(null, pkg)
            return

        callback(null, [])
      ),
      sinon.stub(api.Pkg, 'find', (config, callback) ->
        callback null, mockPackages
      )
    ]

  # Restore original functions
  after ->
    for stub in this.stubs
      stub.restore()


  testEndpoint = 'http://127.0.0.1:3000/api/package/list.json'
  describe "list", ->
    expectedArray = []
    for pkg in mockPackages
      expectedArray.push {
        id: pkg._id,
        name: pkg.name,
        version: pkg.version,
        url: pkg.url,
        createdAt: pkg.createdAt
      }

    baseTests(testEndpoint, expectedArray)

  describe "update list", ->
    updateUrl = 'http://127.0.0.1:3000/api/package/update.json'

    expectedObject = {}
    for pkg in mockPackages
      expectedObject[pkg._id] = pkg.version

    baseTests(updateUrl, expectedObject)

  describe 'detail', ->
    it 'reacts correctly on nonexisting ID', (done) ->
      request "http://127.0.0.1:3000/api/package/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 500)
        assert.deepEqual(JSON.parse(body), [])
        done()

    # Execute basetests for every detail page available
    for pkg in mockPackages
      testUrl = "http://127.0.0.1:3000/api/package/#{pkg._id}.json"
      describe "#{testUrl}", ->
        baseTests(testUrl, pkg)



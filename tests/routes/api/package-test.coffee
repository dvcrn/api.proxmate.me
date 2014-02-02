api = require '../../../routes/api/package'
{app} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'

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

PackageMock =
  findMock: (query, callback) ->
    callback(null, mockPackages)

  findMockThrowingError: (query, callback) ->
    callback('you suck', [])

  findByIdMock: (id, callback) ->
    for pkg in mockPackages
      if pkg._id == id
        callback(null, pkg)
        return

    callback(null, [])

  findByIdMockThrowingError: (id, callback) ->
    callback('you suck', {})


api.Pkg.find = PackageMock.findMock
api.Pkg.findById = PackageMock.findByIdMock

baseTests = (testEndpoint) ->
  it 'response successfully', (done) ->
    request testEndpoint, (err, res, body) ->
      assert.equal(res.statusCode, 200)
      done()

  it 'has the correct content-type', (done) ->
    request testEndpoint, (err, res, body) ->
      assert.equal(res.headers['content-type'], 'application/json')
      done()

  it 'reacts on database errors', (done) ->
    api.Pkg.find = PackageMock.findMockThrowingError
    api.Pkg.findById = PackageMock.findByIdMockThrowingError

    request testEndpoint, (err, res, body) ->
      assert.deepEqual(JSON.parse(body), [])
      assert.equal(res.statusCode, 500)

      api.Pkg.find = PackageMock.findMock
      api.Pkg.findById = PackageMock.findByIdMock

      done()

describe 'Package Api', ->
  before (done) ->
    app.listen 3000
    done()

  after (done) ->
    app.close()
    done()

  testEndpoint = 'http://127.0.0.1:3000/api/package/list.json'
  describe "list", ->
    baseTests(testEndpoint)

    it 'has the correct body', (done) ->
      request testEndpoint, (err, res, body) ->
        expectedArray = []
        for pkg in mockPackages
          expectedArray.push {
            id: pkg._id,
            name: pkg.name,
            version: pkg.version,
            url: pkg.url,
            createdAt: pkg.createdAt
          }

        assert.deepEqual(JSON.parse(body), expectedArray)
        done()

  describe "update", ->
    updateUrl = 'http://127.0.0.1:3000/api/package/update.json'
    baseTests(updateUrl)

    it 'has the correct body', (done) ->
      request updateUrl, (err, res, body) ->
        expectedObject = {}
        for pkg in mockPackages
          expectedObject[pkg._id] = pkg.version

        assert.deepEqual(JSON.parse(body), expectedObject)
        done()

  describe 'detail', ->
    it 'reacts correctly on nonexisting ID', (done) ->
      request "http://127.0.0.1:3000/api/package/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 500)
        assert.deepEqual(JSON.parse(body), [])
        done()

    for pkg in mockPackages
      testUrl = "http://127.0.0.1:3000/api/package/#{pkg._id}.json"
      describe "#{testUrl}", ->
        baseTests(testUrl)

        it 'has the correct body', (done) ->
          request testUrl, (err, res, body) ->
            assert.deepEqual(JSON.parse(body), pkg)
            done()



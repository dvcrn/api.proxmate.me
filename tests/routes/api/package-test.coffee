api = require '../../../routes/api/package'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'

{mockPackages} = require '../../testdata/packages'
{mockCountry} = require '../../testdata/country'
{mockUser} = require '../../testdata/single-user'

ApiHelper = require('../../../routes/api/api-helper')

describe 'Package Api', ->

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

  describe 'list', ->
    beforeEach ->
      this.sandbox.stub(ApiHelper, 'handleFind').callsArgWith(3, mockPackages)

    it 'should generate the package list correctly', (done) ->
      expectedArray = []
      for pkg in mockPackages
        expectedArray.push {
          id: pkg._id,
          requireKey: pkg.requireKey,
          name: pkg.name,
          description: pkg.description,
          smallIcon: pkg.smallIcon,
          pageUrl: pkg.pageUrl
        }

      request "http://127.0.0.1:3000/package/list.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedArray)
        done()

    it 'should generate the update list correctly', (done) ->
      expectedObject = {}
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey').callsArgWith(1, true)

      for pkg in mockPackages
        expectedObject[pkg._id] = pkg.version

      request "http://127.0.0.1:3000/package/update.json?key=asdf", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedObject)

        assert.isTrue(validateKeyStub.calledOnce)
        done()

    it 'should set donator packages to version -1 on wrong or no key', (done) ->
      expectedObject = {}
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey').callsArgWith(1, false)

      for pkg in mockPackages
        expectedObject[pkg._id] = pkg.version
        if pkg.requireKey
          expectedObject[pkg._id] = -1

      request "http://127.0.0.1:3000/package/update.json?key=asdf", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedObject)
        assert.isTrue(validateKeyStub.calledOnce)

        request "http://127.0.0.1:3000/package/update.json", (err, res, body) ->
          assert.equal(res.statusCode, 200)
          assert.deepEqual(JSON.parse(body), expectedObject)

          # No additional validation should get done if no key is set
          assert.isTrue(validateKeyStub.calledOnce)
          done()


  describe 'detail', ->
    it 'displays detail pages correctly', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) ->
        if model is api.User
          callback mockUser
        if model is api.Country
          callback mockCountry
        if model is api.Pkg
          callback mockPackages[0]

      testPkg = mockPackages[0]

      domains = []
      for routing in testPkg.routing
        if routing.startsWith
          domains.push("#{routing.startsWith}*")

        if routing.host
          domains.push("#{routing.host}")

        for containRule in routing.contains
          domains.push("*#{containRule}*")

      testUrl = "http://127.0.0.1:3000/package/#{testPkg._id}.json"
      expectedData = {
        id: testPkg._id,
        name: testPkg.name,
        description: testPkg.description,
        smallIcon: testPkg.smallIcon,
        bigIcon: testPkg.bigIcon,
        pageUrl: testPkg.pageUrl,
        requireKey: testPkg.requireKey,
        user: {
          'twitterHandle': mockUser.twitterHandle,
          'username': mockUser.username,
          'email': mockUser.email
        },
        country: {
          'title': mockCountry.title,
          'flag': mockCountry.flag,
          'shortHand': mockCountry.shortHand
        },
        touchedDomains: domains,

        version: testPkg.version,
        screenshots: testPkg.screenshots,
        hosts: testPkg.hosts,
        createdAt: testPkg.createdAt
      }

      request testUrl, (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)
        done()

    it 'reacts correctly on nonexisting ID', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> res.send('[]', 404)

      request "http://127.0.0.1:3000/package/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

  describe 'install', ->
    it 'generates install page correctly', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> callback mockPackages[0]

      testPkg = mockPackages[0]
      testUrl = "http://127.0.0.1:3000/package/#{testPkg._id}/install.json"

      expectedData = {
        id: testPkg._id,
        name: testPkg.name,
        version: testPkg.version,
        smallIcon: testPkg.smallIcon,
        pageUrl: testPkg.pageUrl,
        country: testPkg.country,
        routing: testPkg.routing,
        hosts: testPkg.hosts,
        contentScripts: testPkg.contentScripts
      }

      request testUrl, (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)

        done()

    it 'validates key if necessary', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> callback mockPackages[1]
      requireKeyStub = this.sandbox.stub ApiHelper, 'requireKey', (req, res, callback) -> callback()

      testPkg = mockPackages[1]
      testUrl = "http://127.0.0.1:3000/package/#{testPkg._id}/install.json?key=foo"

      expectedData = {
        id: testPkg._id,
        name: testPkg.name,
        version: testPkg.version,
        smallIcon: testPkg.smallIcon,
        pageUrl: testPkg.pageUrl,
        country: testPkg.country,
        routing: testPkg.routing,
        hosts: testPkg.hosts,
        contentScripts: testPkg.contentScripts
      }

      request testUrl, (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)
        assert.isTrue(requireKeyStub.calledOnce)

        done()

    it 'reacts correctly on nonexisting ID', (done) ->
      this.sandbox.stub ApiHelper, 'handleFindById', (model, id, res, callback) -> res.send('[]', 404)
      request "http://127.0.0.1:3000/package/ASDF/install.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

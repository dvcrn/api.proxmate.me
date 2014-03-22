api = require '../../../routes/api/package'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
{baseTests} = require './helper'

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

  # Generate stubs for mongoose functions
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

    this.findByIdStub = this.sandbox.stub(api.Pkg, 'findById', (id, callback) ->
      for pkg in mockPackages
        if pkg._id == id
          callback(null, pkg)
          return

      callback({
        message: 'Cast to ObjectId failed for value "asdfa345345sdfakosdfjasdf" at path "_id"',
        name: 'CastError',
        type: 'ObjectId',
        value: 'asdfa345345sdfakosdfjasdf',
        path: '_id'
      }, null)
    )

    this.sandbox.stub(api.Country, 'findById', (id, callback) ->
      callback(null, mockCountry)
    )

    this.userStub = this.sandbox.stub(api.User, 'findById', (id, callback) ->
      callback(null, mockUser)
    )

    this.findStub = this.sandbox.stub(api.Pkg, 'find', (config, callback) ->
      callback null, mockPackages
    )

  # Restore original functions
  afterEach ->
    this.sandbox.restore()

  describe 'list', ->
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
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey', ->
        return {success:true}
      )

      for pkg in mockPackages
        expectedObject[pkg._id] = pkg.version

      request "http://127.0.0.1:3000/package/update.json?key=asdf", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedObject)

        assert.isTrue(validateKeyStub.calledOnce)
        done()

    it 'should set premium packages to version -1 on wrong key', (done) ->
      expectedObject = {}
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey', ->
        return {success:false}
      )

      for pkg in mockPackages
        expectedObject[pkg._id] = pkg.version
        if pkg.requireKey
          expectedObject[pkg._id] = -1

      request "http://127.0.0.1:3000/package/update.json?key=asdf", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedObject)

        assert.isTrue(validateKeyStub.calledOnce)
        done()


  describe 'detail', ->
    it 'displays detail pages correctly', (done) ->
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
      request "http://127.0.0.1:3000/package/ASDF.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

  describe 'install', ->
    it 'generates install page correctly', (done) ->
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
        hosts: testPkg.hosts
      }

      request testUrl, (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedData)
        done()

    it 'reacts correctly on nonexisting ID', (done) ->
      request "http://127.0.0.1:3000/package/ASDF/install.json", (err, res, body) ->
        assert.equal(res.statusCode, 404)
        assert.deepEqual(JSON.parse(body), [])
        done()

api = require '../../../routes/api/package'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
{baseTests} = require './helper'

{mockPackages} = require '../../testdata/packages'

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

      callback(null, null)
    )

    this.findStub = this.sandbox.stub(api.Pkg, 'find', (config, callback) ->
      callback null, mockPackages
    )

  # Restore original functions
  afterEach ->
    this.sandbox.restore()


  apiTestData = []

  # Since literally every test of this API results in the same thing:
  # - Test response code
  # - Test content type
  # - Test handling of database errors
  # - Test body
  # the most dry way is to just create a big array and pass everything to a helper


  # API List
  expectedArray = []
  for pkg in mockPackages
    expectedArray.push {
      id: pkg._id,
      name: pkg.name,
      description: pkg.description,
      icon: pkg.icon,
      pageUrl: pkg.pageUrl
    }

  apiTestData.push({
    'endpoint': 'http://127.0.0.1:3000/package/list.json',
    'expectedData': expectedArray
  })



  # API update list
  expectedObject = {}
  for pkg in mockPackages
    expectedObject[pkg._id] = pkg.version

  apiTestData.push({
    'endpoint': 'http://127.0.0.1:3000/package/update.json',
    'expectedData': expectedObject
  })



  # API detail pages
  for pkg in mockPackages
    testUrl = "http://127.0.0.1:3000/package/#{pkg._id}.json"
    expectedData = {
      id: pkg._id,
      name: pkg.name,
      icon: pkg.icon,
      pageUrl: pkg.pageUrl,
      version: pkg.version,
      country: pkg.country,
      routeRegex: pkg.routeRegex,
      hosts: pkg.hosts
    }

    apiTestData.push({
      'endpoint': testUrl,
      'expectedData': expectedData
    })


  it 'reacts correctly on nonexisting ID', (done) ->
    request "http://127.0.0.1:3000/package/ASDF.json", (err, res, body) ->
      assert.equal(res.statusCode, 404)
      assert.deepEqual(JSON.parse(body), [])
      done()


  for element in apiTestData
    baseTests(element.endpoint, element.expectedData, api.Pkg)
api = require '../../../routes/api/package'
request = require 'request'
sinon = require 'sinon'

{app} = require '../../../app.coffee'
{assert} = require 'chai'
{baseTests} = require './helper'

{mockPackages} = require '../../testdata/packages'

describe 'Package Api', ->

  before (done) ->
    app.listen 3000
    done()

  after (done) ->
    app.close()
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
      version: pkg.version,
      url: pkg.url,
      createdAt: pkg.createdAt
    }

  apiTestData.push({
    'endpoint': 'http://127.0.0.1:3000/api/package/list.json',
    'expectedData': expectedArray
  })



  # API update list
  expectedObject = {}
  for pkg in mockPackages
    expectedObject[pkg._id] = pkg.version

  apiTestData.push({
    'endpoint': 'http://127.0.0.1:3000/api/package/update.json',
    'expectedData': expectedObject
  })



  # API detail pages
  for pkg in mockPackages
    testUrl = "http://127.0.0.1:3000/api/package/#{pkg._id}.json"
    apiTestData.push({
      'endpoint': testUrl,
      'expectedData': pkg
    })


  it 'reacts correctly on nonexisting ID', (done) ->
    request "http://127.0.0.1:3000/api/package/ASDF.json", (err, res, body) ->
      assert.equal(res.statusCode, 404)
      assert.deepEqual(JSON.parse(body), [])
      done()


  for element in apiTestData
    baseTests(element.endpoint, element.expectedData, api.Pkg)
packageApi = require '../../../routes/api/package'
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

describe 'Api Helper', ->

  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  # Generate stubs for mongoose functions
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  # Restore original functions
  afterEach ->
    this.sandbox.restore()

  describe 'requireKey validation', ->
    it 'should return 401 on no key', ->
      resMock =
        json: this.sandbox.spy()

      reqMock =
        query: {}

      ApiHelper.requireKey(reqMock, resMock)
      assert.isTrue(resMock.json.calledOnce)
      assert.isTrue(resMock.json.calledWith({message: 'This ressource requires a valid key. Do you have one?'}, 401))

    it 'should return 401 and message on key error', ->
      validationStub = this.sandbox.stub(ApiHelper, 'validateKey', ->
        return {success: false, message: 'foobar'}
      )

      resMock =
        json: this.sandbox.spy()

      reqMock =
        query:
          key: 'foo'

      ApiHelper.requireKey(reqMock, resMock)
      assert.isTrue(resMock.json.calledOnce)
      assert.isTrue(resMock.json.calledWith({message: 'foobar'}, 401))

    it 'should return true on valid key', ->
      validationStub = this.sandbox.stub(ApiHelper, 'validateKey', ->
        return {success: true}
      )

      resMock =
        json: this.sandbox.spy()

      reqMock =
        query:
          key: 'foo'

      res = ApiHelper.requireKey(reqMock, resMock)
      assert.isTrue(res)

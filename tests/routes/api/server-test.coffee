serverApi = require '../../../routes/api/server'
{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
{baseTests} = require './helper'
sinon = require 'sinon'

{mockServers} = require '../../testdata/servers'

describe 'Server Api', ->
  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  describe 'list', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      this.sandbox.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

    afterEach ->
      this.sandbox.restore()

    baseTests.call(
      this,
      'http://127.0.0.1:3000/server/list.json',
      mockServers,
      serverApi.Server
    )
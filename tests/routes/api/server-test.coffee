serverApi = require '../../../routes/api/server'
{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
sinon = require 'sinon'

ApiHelper = require('../../../routes/api/api-helper')

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

    afterEach ->
      this.sandbox.restore()

    it 'should generate the list correctly', (done) ->
      this.sandbox.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

      expectedServers = mockServers.filter (server) ->
        if not server.isPrivate and not server.requireKey
          return {
            "host": server.host,
            "port": server.port,
            "user": server.user,
            "password": server.password,
            "country": server.country,
            "ip": server.ip
          }

      request "http://127.0.0.1:3000/server/list.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedServers)
        done()

    it 'should display packages with key if key is valid', (done) ->
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey').callsArgWith(1, true)

      this.sandbox.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

      expectedServers = mockServers.filter (server) ->
        if not server.isPrivate 
          return {
            "host": server.host,
            "port": server.port,
            "user": server.user,
            "password": server.password,
            "country": server.country,
            "ip": server.ip
          }

      request "http://127.0.0.1:3000/server/list.json?key=foo", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedServers)
        done()


    it 'should not display all packages if key is invalid', (done) ->
      validateKeyStub = this.sandbox.stub(ApiHelper, 'validateKey').callsArgWith(1, false)

      this.sandbox.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

      expectedServers = mockServers.filter (server) ->
        if not server.isPrivate and not server.requireKey
          return {
            "host": server.host,
            "port": server.port,
            "user": server.user,
            "password": server.password,
            "country": server.country,
            "ip": server.ip
          }

      request "http://127.0.0.1:3000/server/list.json?key=foo", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedServers)
        done()

serverApi = require '../../../routes/api/server'
{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
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

    afterEach ->
      this.sandbox.restore()

    it 'should generate the list correctly', ->
      this.sandbox.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

      request "http://127.0.0.1:3000/server/list.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), mockServers)
        done()

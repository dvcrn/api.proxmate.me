packageApi = require '../../../routes/api/package'
{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
sinon = require 'sinon'
request = require 'request'

{mockPackages} = require '../../testdata/packages'

describe 'Proxy Api', ->
  before (done) ->
    server.listen 3000
    done()

  after (done) ->
    server.close()
    done()

  describe 'whitelist', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()

    afterEach ->
      this.sandbox.restore()

    it 'should generate the list correctly', (done) ->
      this.sandbox.stub(packageApi.Pkg, 'find', (config, callback) ->
        callback null, mockPackages
      )

      responseArray = [
        '.netflix.com',
        '.muh.com',
        '.pandora.com'
      ]

      request "http://127.0.0.1:3000/proxy/whitelist.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), responseArray)
        done()

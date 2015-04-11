urlApi = require '../../../routes/api/url'
{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
sinon = require 'sinon'

{mockServers} = require '../../testdata/servers'

describe 'Url Api', ->
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
    it 'should generate the url list correctly', (done) ->
      mockPackages = [
        {_id: 'foo'},
        {_id: 'foo123'},
        {_id: 'foo12345'}
      ]

      expectedOutput = []
      expectedOutput.push('https://proxmate.me/#!/')
      expectedOutput.push('https://proxmate.me/#!/packages')
      expectedOutput.push('https://proxmate.me/#!/about')
      expectedOutput.push('https://proxmate.me/#!/donate')
      expectedOutput.push('https://proxmate.me/#!/package/foo')
      expectedOutput.push('https://proxmate.me/#!/package/foo123')
      expectedOutput.push('https://proxmate.me/#!/package/foo12345')
      expectedOutput.sort()

      this.sandbox.stub(urlApi.Pkg, 'find', (config, callback) ->
        callback null, mockPackages
      )

      request "http://127.0.0.1:3000/url/list.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), expectedOutput)
        done()

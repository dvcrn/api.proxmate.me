packageApi = require '../../../routes/api/package'
proxyApi = require '../../../routes/api/proxy'

{app} = require '../../../app.coffee'
{server} = require '../../../app.coffee'
{assert} = require 'chai'
sinon = require 'sinon'
request = require 'request'

{mockPackages} = require '../../testdata/packages'

ApiHelper = require('../../../routes/api/api-helper')
Cloudflare = require('../../../library/cloudflare')
{mockServers} = require '../../testdata/servers'

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
        'www.beatsmusic.com'
        '.pandora.com',
      ]

      request "http://127.0.0.1:3000/proxy/whitelist.json", (err, res, body) ->
        assert.equal(res.statusCode, 200)
        assert.deepEqual(JSON.parse(body), responseArray)
        done()

  describe 'heartbeat / sync', ->
    beforeEach ->
      this.sandbox = sinon.sandbox.create()
      this.sandbox.stub(proxyApi.Server, 'find').callsArgWith(1, null, mockServers)
    afterEach ->
      this.sandbox.restore()

    it 'should take only post', (done) ->
      request "http://127.0.0.1:3000/proxy/heartbeat.json", (err, res, body) ->
        assert.equal(200, res.statusCode)
        assert.deepEqual(body, 'please use post')

        request.post "http://127.0.0.1:3000/proxy/heartbeat.json", (err, res, body) ->
          assert.equal(200, res.statusCode)
          assert.notDeepEqual(body, 'please use post')
          done()

    it 'should not work on invalid access key', (done) ->
      request.post "http://127.0.0.1:3000/proxy/heartbeat.json?accesskey=foo", (err, res, body) ->
        assert.equal(200, res.statusCode)
        assert.deepEqual(body, 'invalid access key')

        request.post "http://127.0.0.1:3000/proxy/heartbeat.json?accesskey=foobar", (err, res, body) ->
          assert.equal(200, res.statusCode)
          assert.notDeepEqual(body, 'invalid access key')
          done()

    it 'should return success on existing domain', (done) ->
      request.post "http://127.0.0.1:3000/proxy/heartbeat.json?accesskey=foobar", {
        form: {
          'hostname': 'foo.bar',
        }
      }, (err, res, body) ->
        assert.deepEqual(JSON.parse(body), {'success': true, 'created': false})
        assert.equal(200, res.statusCode)
        done()

    it "should create a new domain record if doesn't exist", (done) ->
      addARecordStub = this.sandbox.stub(Cloudflare, 'addARecord').callsArgWith(2, {rec_id: 'foo'})
      proxyApi.Server.find.restore()
      this.sandbox.stub(proxyApi.Server, 'find').callsArgWith(1, null, [])
      serverCreateStub = this.sandbox.stub(proxyApi.Server, 'create').callsArgWith(1, null, [])

      request.post "http://127.0.0.1:3000/proxy/heartbeat.json?accesskey=foobar", {
        form: {
          'hostname': 'foo.bar',
          'username': 'foo',
          'password': 'foobar',
          'countryId': 'foobar',
          'port': '8000',
        },
        headers: {
          'fastly-client-ip': "127.0.0.1"
        }
      }, (err, res, body) ->
        assert.isTrue(addARecordStub.calledOnce, 'addARecord called')
        assert.isTrue(serverCreateStub.calledOnce, 'server create called')
        assert.isTrue(addARecordStub.calledWith('foo.bar', '127.0.0.1'), 'addarecord got correct parameters')
        assert.isTrue(serverCreateStub.calledWith({
          host: 'foo.bar',
          port: '8000',
          user: 'foo',
          password: 'foobar',
          country: 'foobar',
          ip: '127.0.0.1',
          isPrivate: true
        }), 'serverCreate got correct parameters')

        assert.deepEqual(JSON.parse(body), {'success': true, 'created': true})
        assert.equal(200, res.statusCode)
        done()

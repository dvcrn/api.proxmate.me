
paypalApi = require '../../../routes/api/paypal'
request = require 'request'
sinon = require 'sinon'


{server} = require '../../../app.coffee'
{assert} = require 'chai'
{app} = require '../../../app.coffee'

{mockIpn} = require '../../testdata/ipn.coffee'

describe 'Paypal API', ->
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

  describe 'endpoint', ->
    beforeEach ->
      this.verifyIpnStub = this.sandbox.stub paypalApi.Paypal, 'verifyIpn', (ipn, callback) ->
        callback true

      this.createOrUpdateIpnStub = this.sandbox.stub paypalApi.User, 'createOrUpdateIpn', (ipn, callback) ->
        callback true

    it 'should take only post', (done) ->
      request "http://127.0.0.1:3000/paypal/endpoint.json", (err, res, body) ->
        assert.equal(200, res.statusCode)
        assert.deepEqual(body, 'please use post')

        request.post "http://127.0.0.1:3000/paypal/endpoint.json", (err, res, body) ->
          assert.notDeepEqual(body, 'please use post')
          done()

    it 'should ignore requests that are not donation or recurring payment', (done) ->
      # Invalid txn_type
      request.post "http://127.0.0.1:3000/paypal/endpoint.json", {
        form: {
          "txn_type": 'foo'
        }
      },(err, res, body) ->
        assert.equal(200, res.statusCode)
        assert.deepEqual(body, 'invalid transaction type')

        # Valid transaction type
        request.post "http://127.0.0.1:3000/paypal/endpoint.json", {
          form: {
            "txn_type": 'web_accept'
          }
        },(err, res, body) ->
          assert.equal(200, res.statusCode)
          assert.notEqual(body, 'invalid transaction type')

          request.post "http://127.0.0.1:3000/paypal/endpoint.json", {
            form: {
              "txn_type": 'recurring_payment'
            }
          },(err, res, body) ->
            assert.equal(200, res.statusCode)
            assert.notEqual(body, 'invalid transaction type')
            done()

    it 'should verify IPN and create a new user', (done) ->
      self = this

      request.post "http://127.0.0.1:3000/paypal/endpoint.json", {
        form: mockIpn
      }, (err, res, body) ->
        assert.equal(200, res.statusCode)
        assert.equal(body, 'success')
        assert.isTrue(self.createOrUpdateIpnStub.calledWith(mockIpn))
        done()

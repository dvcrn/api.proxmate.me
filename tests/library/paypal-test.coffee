{assert} = require 'chai'
sinon = require 'sinon'

paypal = require '../../library/paypal'

request = require 'request'

describe 'Paypal', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  afterEach ->
    this.sandbox.restore()

  it 'should verify the IPN correctly', ->
    # Build a mock object we can pass
    requestStub = {}
    getStub = this.sandbox.stub()
    getStub.callsArgWith(1, null, null, 'VERIFIED')
    requestStub.get = getStub

    this.sandbox.stub(paypal, 'getRequest').returns(requestStub)

    callbackSpy = sinon.spy()
    testparam = {'foo': 'bar'}
    paypal.verifyIpn(testparam, callbackSpy)
    assert.isTrue(callbackSpy.calledWith(true))
    assert.isTrue(requestStub.get.calledWith('https://www.paypal.com/cgi-bin/webscr?cmd=_notify-validate&foo=bar'))

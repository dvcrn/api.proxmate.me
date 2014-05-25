{assert} = require 'chai'
sinon = require 'sinon'

paypal = require '../../library/paypal'

request = require 'request'

describe 'Paypal', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  afterEach ->
    this.sandbox.restore()

  it 'should return only IPN information from input', ->
    test1 = { 'foo': 'bar', 'payment_type': 'web_accept'}
    test2 = { 'foo': 'bar', 'somethingElse': '123'}
    test3 = { "address_zip": "95131", "first_name": "Test", "mc_fee": "0.88" }

    assert.deepEqual({'payment_type': 'web_accept'}, paypal.extractIpnFromRequest(test1))
    assert.deepEqual({}, paypal.extractIpnFromRequest(test2))
    assert.deepEqual(test3, paypal.extractIpnFromRequest(test3))

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

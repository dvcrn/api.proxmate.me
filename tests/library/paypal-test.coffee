{assert} = require 'chai'
sinon = require 'sinon'

paypal = require '../../library/paypal'

describe 'Paypal', ->
  it 'should extract IPN information correctly from input', ->
    assert.deepEqual({'foor': 'bar'}, paypal.extractIpnFromRequest({'foor': 'bar'}))

  it 'should verify the IPN correctly', ->
    spy = sinon.spy()
    paypal.verifyIpn({'foo'}, spy)
    assert.isTrue(spy.calledWith(true))

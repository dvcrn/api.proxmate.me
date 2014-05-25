sendgrid = require '../../library/sendgrid'
{assert} = require 'chai'
sinon = require 'sinon'

describe 'Sendgrid', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  afterEach ->
    this.sandbox.restore()

  it 'should call send on sendDonationNotice', (done) ->
    sendGridStub = {}
    sendGridStub.send = this.sandbox.stub().callsArg(1)

    ejsStub = {}
    ejsStub.render = this.sandbox.stub().returns('template')

    this.sandbox.stub(sendgrid, 'getSendgrid').returns(sendGridStub)
    this.sandbox.stub(sendgrid, 'getEjs').returns(ejsStub)

    sendgrid.sendDonationNotice('foo@bar.de', '123456789', ->
      assert.isTrue(ejsStub.render.calledWith(sinon.match.any, {'donationKey': '123456789'}))
      assert.isTrue(sendGridStub.send.calledWith({
        to: 'foo@bar.de',
        from: 'proxmate@personalitycores.com',
        fromname: 'ProxMate',
        subject: 'Your Donation to ProxMate!',
        html: 'template'
      }))
      done()
    )


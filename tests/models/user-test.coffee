{assert} = require 'chai'
sinon = require 'sinon'

user = require '../../models/user'
sendgrid = require('../../library/sendgrid')
crypto = require('../../library/crypto')

request = require 'request'

describe 'User', ->
  beforeEach ->
    this.sandbox = sinon.sandbox.create()

  afterEach ->
    this.sandbox.restore()

  describe 'donation history', ->

    it 'should add a donation correctly to donationHistory', ->
      userStub = {
        donationHistory: [],
        expiresAt: new Date(1401002097116),
        save: this.sandbox.stub()
      }

      ipn = {
        'mc_gross': 1,
        'currency': 'EUR',
        'payment_date': new Date(1401002097116),
        'txn_id': 'foobar'
      }

      user.addDonationFromIpn(userStub, ipn)
      assert.isTrue(userStub.save.calledOnce)
      assert.deepEqual([{
        'amount': 1,
        'currency': 'EUR',
        'date': new Date(1401002097116),
        'paymentId': 'foobar'
      }], userStub.donationHistory)

    it 'should call sendgrid and crypto on adding donationHistory', ->
      userStub = {
        _id: 'foo',
        donationHistory: [],
        expiresAt: new Date(1401002097116),
        save: this.sandbox.stub().callsArg(0)
      }

      ipn = {
        'mc_gross': 1,
        'currency': 'EUR',
        'payment_date': new Date(1401002097116),
        'txn_id': 'foobar'
      }

      sendgridSendStub = this.sandbox.stub(sendgrid, 'sendDonationNotice')
      cryptoStub = this.sandbox.stub(crypto, 'encryptKey')

      callbackSpy = this.sandbox.spy()
      user.addDonationFromIpn(userStub, ipn, callbackSpy)
      assert.isTrue(sendgridSendStub.calledOnce)
      assert.isTrue(cryptoStub.calledOnce)
      assert.isTrue(callbackSpy.calledOnce)

  describe 'get or create', ->
    it 'should create a new user if doenst exist yet', ->
      findMock = this.sandbox.stub(user, 'find').callsArgWith(1, null, [])
      createStub = this.sandbox.stub(user, 'create')

      ipn = {
        first_name: 'first'
        last_name: 'last',
        payer_email: 'email',
      }

      user.createOrUpdateIpn(ipn)
      assert.isTrue(createStub.calledWith({
        'firstName': 'first',
        'lastName': 'last',
        'email': 'email',
        'donationHistory': []
      }, sinon.match.any))

    it 'should add donation history point if user exists', ->
      findMock = this.sandbox.stub(user, 'find').callsArgWith(1, null, [{'foo': 'bar'}])
      donationHistoryStub = this.sandbox.stub(user, 'addDonationFromIpn')

      callback = this.sandbox.spy()
      ipn = {
        first_name: 'first'
        last_name: 'last',
        payer_email: 'email',
      }

      user.createOrUpdateIpn(ipn, callback)
      assert.isTrue(donationHistoryStub.calledWith({'foo': 'bar'}, ipn, callback))

    it 'should calculate the new expiry date correctly if user exists', ->
      now = new Date()
      mockUser = [{'foo': 'bar', 'donationHistory': [], 'expiresAt': now, save: -> }]
      findMock = this.sandbox.stub(user, 'find').callsArgWith(1, null, mockUser)

      callback = this.sandbox.spy()
      ipn = {
        first_name: 'first'
        last_name: 'last',
        payer_email: 'email',
      }

      user.createOrUpdateIpn(ipn, callback)
      expectedDate = new Date(now.getTime())
      expectedDate.setDate(now.getDate() + 30)
      assert.isTrue(mockUser[0].expiresAt > expectedDate)

    it 'should calculate the new expiry date if in the old date is in the past', ->
      now = new Date()
      fakeDate = new Date(now.getTime())
      fakeDate.setDate(now.getDate() - 31)

      mockUser = [{'foo': 'bar', 'donationHistory': [], 'expiresAt': fakeDate, save: -> }]
      findMock = this.sandbox.stub(user, 'find').callsArgWith(1, null, mockUser)

      callback = this.sandbox.spy()
      ipn = {
        first_name: 'first'
        last_name: 'last',
        payer_email: 'email',
      }

      user.createOrUpdateIpn(ipn, callback)
      expectedDate = new Date(now.getTime())
      expectedDate.setDate(now.getDate() + 30)
      assert.isTrue(mockUser[0].expiresAt > expectedDate)

    it 'should add donation history point on user createion', ->
      findMock = this.sandbox.stub(user, 'find').callsArgWith(1, null, [])
      donationHistoryStub = this.sandbox.stub(user, 'addDonationFromIpn')
      createStub = this.sandbox.stub(user, 'create').callsArgWith(1, null, {'foo': 'bar'})

      callback = this.sandbox.spy()
      ipn = {
        first_name: 'first'
        last_name: 'last',
        payer_email: 'email',
      }

      user.createOrUpdateIpn(ipn, callback)
      assert.isTrue(donationHistoryStub.calledWith({'foo': 'bar'}, ipn, callback))

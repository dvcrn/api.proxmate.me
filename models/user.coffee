mongoose = require('mongoose')
sendgrid = require('../library/sendgrid')
crypto = require('../library/crypto')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Mixed = Schema.Types.Mixed


userSchema = new Schema(
  firstName: String,
  lastName: String,
  twitterHandle: String,
  email: String,
  donationHistory: [{
    amount: Number,
    currency: String,
    date: {type: Date, default: Date.now},
    paymentId: String
  }],

  expiresAt: {type: Date, default: Date.now},
  createdAt: {type: Date, default: Date.now}
)

userSchema.statics.addDonationFromIpn = (user, ipn, callback) ->
  user.donationHistory.push {
    'amount': ipn.mc_gross,
    'currency': ipn.currency,
    'date': ipn.payment_date,
    'paymentId': ipn.txn_id
  }

  # Add up the expiresAt date by 31 days
  oldExpireDate = user.expiresAt
  newExpireDate = new Date(oldExpireDate.getTime())

  if oldExpireDate.getTime() < new Date().getTime()
    newExpireDate = new Date(new Date().getTime())

  newExpireDate.setDate(oldExpireDate.getDate() + 31)
  user.expiresAt = newExpireDate

  user.save (err) ->
    if err
      callback false
    else
      donationKey = crypto.encryptKey(user._id.toString())
      sendgrid.sendDonationNotice(ipn.payer_email, donationKey)
      callback true

userSchema.statics.createOrUpdateIpn = (ipn, callback) ->
  # Add reference to outer scope, since we need it in callback
  self = this
  self.find({email: ipn.payer_email}, (err, obj) ->
    # Skip in case we have an error
    if err?
      callback false

    # Did we get a result back? If no, create a new user
    else if !obj or obj.length == 0
      self.create({
        firstName: ipn.first_name
        lastName: ipn.last_name
        email: ipn.payer_email,
        donationHistory: []
      }, (err, user) ->
        # Again, skip on error
        if err
          callback false
          return

        # Finally add the actual donation to the user object
        self.addDonationFromIpn(user, ipn, callback)
      )
    else
      existingUser = obj[0]
      self.addDonationFromIpn(existingUser, ipn, callback)
  )

module.exports = mongoose.model('User', userSchema)

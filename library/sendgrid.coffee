sendgrid  = require('sendgrid')
config = exports.config = require '../config/app'
fs = require 'fs'
path = require 'path'
ejs = require 'ejs'

class Sendgrid
  constructor: ->
    @sendgrid = sendgrid config.sendgrid.username, config.sendgrid.password

  getSendgrid: ->
    return @sendgrid

  getEjs: ->
    return ejs

  sendDonationNotice: (receiver, donationKey, callback) ->
    sg = @getSendgrid()
    ejs = @getEjs()
    fs.readFile path.join(__dirname, '../templates/email/donation.html'), 'utf8', (err, html) ->

      renderedTemplate = ejs.render(html, {'donationKey': donationKey})
      sg.send({
          to: receiver,
          from: 'david@proxmate.me',
          fromname: 'ProxMate',
          subject: 'Your Donation to ProxMate!',
          html: renderedTemplate
        }, (err, json) ->
          if err
            console.info err

          callback()
      )

module.exports = new Sendgrid()

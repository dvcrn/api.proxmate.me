Country = exports.Country = require('../../models/country')

ApiHelper = require('./api-helper')

exports.detail = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFindById(Country, req.params.id, res, (country) ->
    res.json({
      title: country.title,
      shortHand: country.shortHand,
      flag: country.flag
    })
  )
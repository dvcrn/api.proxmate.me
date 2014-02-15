User = exports.User = require('../../models/user')

ApiHelper = require('./api-helper')

exports.detail = (req, res) ->
  ApiHelper.setJson(res)
  ApiHelper.handleFindById(User, req.params.id, res, (user) ->
    res.json({
      username: user.username,
      email: user.email
    })
  )
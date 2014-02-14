User = exports.User = require('../../models/user')

exports.detail = (req, res) ->
  res.set('Content-Type', 'application/json')

  id = req.params.id
  User.findById(id, (err, user) ->
    if err
      if err.name is 'CastError'
        res.send(404, '[]')
      else
        res.send(500, '[]')
    else if !user
      res.send(404, '[]')
    else
      res.json({
        username: user.username,
        email: user.email
      })
  )
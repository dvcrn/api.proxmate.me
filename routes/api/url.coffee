Pkg = exports.Pkg = require('../../models/package')

ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  urls = []
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    for pkg in packageCollection
      urls.push("http://proxmate.me/package/#{pkg._id}")

    urls.push('http://proxmate.me/')
    urls.push('http://proxmate.me/packages')
    urls.push('http://proxmate.me/about')
    urls.push('http://proxmate.me/donate')
    urls.sort()

    res.json(urls)
  )

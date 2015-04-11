Pkg = exports.Pkg = require('../../models/package')

ApiHelper = require('./api-helper')

exports.list = (req, res) ->
  urls = []
  ApiHelper.setJson(res)
  ApiHelper.handleFind(Pkg, {}, res, (packageCollection) ->
    for pkg in packageCollection
      urls.push("https://proxmate.me/#!/package/#{pkg._id}")

    urls.push('https://proxmate.me/#!/')
    urls.push('https://proxmate.me/#!/packages')
    urls.push('https://proxmate.me/#!/about')
    urls.push('https://proxmate.me/#!/donate')
    urls.sort()

    res.json(urls)
  )

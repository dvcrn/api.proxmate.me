express = require 'express'
devConfig = require './development/app'
prodConfig = require './production/app'

if 'development' == express().get('env')
  module.exports = devConfig
else
  module.exports = prodConfig
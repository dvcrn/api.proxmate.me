{assert} = require 'chai'

sinon = require 'sinon'

devConfig = require '../../config/development/app'
prodConfig = require '../../config/production/app'

describe 'Config provider', ->
  beforeEach ->
    devConfig.env = 'dev'
    prodConfig.env = 'prod'

    name = require.resolve '../../config/app'
    delete require.cache[name]

  it 'should load the production config in production environment', ->
    process.env.NODE_ENV = 'production'

    config = require '../../config/app'
    assert.equal(config.env, 'prod')

  it 'should load the development config in production environment', ->
    process.env.NODE_ENV = 'development'
    config = require '../../config/app'
    assert.equal(config.env, 'dev')

  it 'should load the development config if no environment is set', ->
    config = require '../../config/app'
    assert.equal(config.env, 'dev')
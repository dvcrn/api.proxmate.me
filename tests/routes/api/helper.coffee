request = require 'request'
{assert} = require 'chai'
sinon = require 'sinon'

###*
 * Base test helper. Simply checks for statuscode 200, application/json
 * and if the view returns 500 on database error
 * Also does a comparison between the json parsed body and expectedObject
 * @param  {String} testEndpoint  URL to test
 * @param  {Object} expectedObject expected body
###
baseTests = (testEndpoint, expectedObject) ->
  it 'response successfully', (done) ->
    request testEndpoint, (err, res, body) ->
      assert.equal(res.statusCode, 200)
      done()

  it 'has the correct content-type', (done) ->
    request testEndpoint, (err, res, body) ->
      assert.equal(res.headers['content-type'], 'application/json')
      done()

  it 'has the correct body', (done) ->
    request testEndpoint, (err, res, body) ->
      assert.deepEqual(JSON.parse(body), expectedObject)
      done()

module.exports = {
  baseTests: baseTests
}
request = require 'request'
{assert} = require 'chai'
sinon = require 'sinon'

###*
 * Base test helper. Simply checks for statuscode 200, application/json
 * and if the view returns 500 on database error
 * Also does a comparison between the json parsed body and expectedObject
 * @param  {String} testEndpoint  URL to test
 * @param  {Object} expectedObject expected body
 * @param  {Object} databaseModel Database object to mock
###
baseTests = (testEndpoint, expectedData, requiredModel) ->
  ((apiEndpoint, expectedData, requiredModel) ->
    describe "#{apiEndpoint} base tests", ->

      it 'should return the correct statuscode', (done) ->
        request apiEndpoint, (err, res, body) ->
          assert.equal(res.statusCode, 200)
          done()

      it 'should return the correct headers', (done) ->
        request apiEndpoint, (err, res, body) ->
          assert.equal(res.headers['content-type'], 'application/json')
          assert.equal(res.headers['access-control-allow-headers'], 'Content-Type')
          assert.equal(res.headers['access-control-allow-methods'], 'GET,PUT,POST,DELETE')
          assert.equal(res.headers['access-control-allow-origin'], 'http://127.0.0.1:9000')
          done()

      it 'should have the correct body', (done) ->
        request apiEndpoint, (err, res, body) ->
          assert.deepEqual(JSON.parse(body), expectedData)
          done()

      it 'should react correctly on database errors', (done) ->
        if requiredModel.findById.restore
          requiredModel.findById.restore()

        if requiredModel.find.restore
          requiredModel.find.restore()

        this.findByIdStub = this.sandbox.stub(requiredModel, 'findById', (id, callback) ->
          callback('you suck', null)
        )
        this.findStub = this.sandbox.stub(requiredModel, 'find', (string, callback) ->
          callback('you suck', null)
        )

        request apiEndpoint, (err, res, body) ->
          assert.equal(res.statusCode, 500)
          done()
  )(testEndpoint, expectedData, requiredModel)

module.exports = {
  baseTests: baseTests
}
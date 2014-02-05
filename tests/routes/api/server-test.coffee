serverApi = require '../../../routes/api/server'
{app} = require '../../../app.coffee'
request = require 'request'
{assert} = require 'chai'
{baseTests} = require './helper'
sinon = require 'sinon'

mockServers = [{
  "host": "nq-us05.personalitycores.com",
  "port": 8000,
  "user": "",
  "password": "",
  "country": { "$oid" : "52e5c40294ed6bd4032daa49" },
  "ip": "184.95.52.214",
  "_id": { "$oid" : "52f22892121decd40b9a9917" },
  "createdAt": { "$date": 1391601810857 },
  "__v": 0
},{
  "host": "nq-us06.personalitycores.com",
  "port": 8000,
  "user": "",
  "password": "",
  "country": "52e5c40294ed6bd4032daa49",
  "ip": "66.85.140.75",
  "_id": "52f228c35816c2ed0b8e548a",
  "createdAt": { "$date": 1391601859514 },
  "__v": 0
}]


describe 'Server Api', ->
  before (done) ->
    app.listen 3000
    done()

  after (done) ->
    app.close()
    done()

  describe 'list', ->
    beforeEach ->
      this.stub = sinon.stub(serverApi.Server, 'find', (config, callback) ->
        callback null, mockServers
      )

    afterEach ->
      this.stub.restore()

    testEndpoint = 'http://127.0.0.1:3000/api/server/list.json'
    expectedArray = []
    baseTests(testEndpoint, mockServers)
class ApiHelper
  handle: (model, functionName, query, responseObject, callback) ->
    responseObject.set('Content-Type', 'application/json')

    model[functionName](query, (err, databaseObject) ->
      if err
        if err.name is 'CastError'
          responseObject.send(404, '[]')
        else
          responseObject.send(500, '[]')
      else if !databaseObject
        responseObject.send(404, '[]')
      else
        callback databaseObject
    )

  handleFindById: (model, id, responseObject, callback) ->
    @handle(model, 'findById', id, responseObject, callback)

  handleFind: (model, query, responseObject, callback) ->
    @handle(model, 'find', query, responseObject, callback)

module.exports = new ApiHelper()
module.exports =
  frontend:
    host: "http://127.0.0.1:9000"

  database:
    mongo_url: process.env['MONGOHQ_URL']
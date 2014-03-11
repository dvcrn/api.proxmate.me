module.exports =
  frontend:
    host: "http://proxmate.me"

  database:
    mongo_url: process.env['MONGOHQ_URL']

  crypto:
    pepper: process.env['PASSWORD_PEPPER']
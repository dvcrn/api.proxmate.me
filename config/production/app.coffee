module.exports =
  frontend:
    host: "http://proxmate.me"
    cache_age: 1800
    cdn_cache_age: 10800

  database:
    mongo_url: process.env['MONGOHQ_URL']

  crypto:
    pepper: process.env['PASSWORD_PEPPER']
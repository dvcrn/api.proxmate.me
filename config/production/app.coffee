module.exports =
  frontend:
    host: "http://proxmate.me"
    cache_age: 1800
    cdn_cache_age: 3600

  database:
    mongo_url: process.env['MONGOHQ_URL']

  crypto:
    pepper: process.env['PASSWORD_PEPPER']

  sendgrid:
    username: process.env.SENDGRID_USERNAME
    password: process.env.SENDGRID_PASSWORD

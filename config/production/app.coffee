module.exports =
  frontend:
    host: "https://promate.me"
    cache_age: 1800
    cdn_cache_age: 3600

  database:
    mongo_url: process.env['MONGOHQ_URL']

  crypto:
    pepper: process.env['PASSWORD_PEPPER']

  sendgrid:
    username: process.env.SENDGRID_USERNAME
    password: process.env.SENDGRID_PASSWORD

  cloudflare:
    accesskey: process.env.CLOUDFLARE_ACCESS_KEY
    email: process.env.CLOUDFLARE_EMAIL
    token: process.env.CLOUDFLARE_TOKEN
    domain: process.env.CLOUDFLARE_DOMAIN

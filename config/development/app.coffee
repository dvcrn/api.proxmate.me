module.exports =
  frontend:
    host: "http://127.0.0.1:9000"
    cache_age: 0
    cdn_cache_age: 0

  database:
    mongo_url: "mongodb://localhost/proxmate"

  crypto:
    pepper: "salt"

  sendgrid:
    username: 'foo'
    password: 'bar'

  cloudflare:
    accesskey: 'foobar'
    email: ''
    token: 'token'
    domain: 'proxmate.me'

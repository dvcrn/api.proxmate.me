# The sourcecode for api.proxmate.me has been moved. This version here is no longer being maintained.


# api.proxmate.me
[![Built Status](https://travis-ci.org/dvcrn/api.proxmate.me.png "Build Status")](https://travis-ci.org/dvcrn/api.proxmate.me/)

This is the code running on [api.proxmate.me](http://api.proxmate.me). It has been designed to run on heroku, but you should not have any problems running it somewhere else.


## Running

### Requirements

- node
- mongodb
- coffeescript

To run, simply execute `node server.js` which will spawn a webserver listening on port 3000 by default. By default, the configuration inside `config/development` is being used.

### Configuration

Since api.proxmate.me has been designed to run on heroku, all configuration can be done through environment variables. 

If you want sendgrid support (sending of emails), add your sendgrid username/password inside `config/xxx/app.coffee`.

api.proxmate.me is also able to automatically add DNS records if needed (for example a new proxy server is being added. The server will ping the api server, which will then automatically create the needed dns entry.). To use this feature, you will have to use cloudflare and have a valid token inside `config/xxx/app.coffee`. 

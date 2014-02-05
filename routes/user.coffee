

User = exports.User = require('../models/user');
Pkg = exports.Pkg = require('../models/package');
Country = exports.Country = require('../models/country');
Server = exports.Server = require('../models/server')


exports.list = (req, res) ->
	# Country.create({title: "USA", shortHand: "US"})
	Server.create(
		host: "nq-us06.personalitycores.com"
		port: 8000
		user: ""
		password: ""
		country: "52e5c40294ed6bd4032daa49",
		ip: "66.85.140.75"
	)
	# Pkg.create({
	# 	name: "Test Package",
	# 	version: 1,
	# 	url: "http://pandora.com",
	# 	user: '52e51a98217d32e2270e211f',
	# 	country: '52e5c40294ed6bd4032daa49',
	# 	hosts: [
	# 		'pandora.com',
	# 		'*.pandora.com'
	# 	],
	# 	routeRegex: [
	# 		"host == 'www.pandora.com'"
	# 	]
	# }, (err) ->
	# 	console.info(err)
	# )

	res.send("respond with a resource");
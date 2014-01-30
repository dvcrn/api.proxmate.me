
/*
 * GET home page.
 */

var User = require('../models/user.js');
var Pkg = require('../models/package.js');

exports.index = function(req, res){
    new User({firstName: 'David', lastName: 'Mohl', username: 'Aqua', email: 'dave@dave.cx'}).save()
    res.render('index', { title: 'Express' });
};
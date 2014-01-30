var mongoose = require('mongoose')
   ,Schema = mongoose.Schema
   ,ObjectId = Schema.ObjectId
   ,Mixed = Schema.Mixed;

var countrySchema = new Schema({
  	title: String,
    shortHand: String
});

module.exports = mongoose.model('Country', countrySchema);
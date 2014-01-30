var mongoose = require('mongoose')
,Schema = mongoose.Schema
,ObjectId = Schema.Types.ObjectId
,Mixed = Schema.Types.Mixed;

var packageSchema = new Schema({
	name: String,
	version: Number,
  url: String,
  user: ObjectId,
  country: ObjectId,
  hosts: Array,
  routeRegex: Array,
  // contentScripts: Mixed,
  createdAt: {type: Date, default: Date.now}
});

module.exports = mongoose.model('Package', packageSchema);
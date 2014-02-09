mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
Mixed = Schema.Types.Mixed

packageSchema = new Schema(
  name: String,
  description: String,
  icon: String,
  pageUrl: String,

  version: Number,
  user: ObjectId,
  country: ObjectId,

  hosts: Array,
  routing: Array,
  # contentScripts: Mixed,

  createdAt: {type: Date, default: Date.now}
)

module.exports = mongoose.model('Package', packageSchema)
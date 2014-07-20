mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Mixed = Schema.Mixed


serverSchema = new Schema(
  host: String,
  port: Number,
  user: String,
  password: String,
  country: ObjectId,
  ip: String,
  createdAt: {type: Date, default: Date.now},
  isPrivate: {type: Boolean, default: false},
  requireKey: {type: Boolean, default: false}
)

module.exports = mongoose.model('Server', serverSchema)

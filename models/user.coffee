mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Mixed = Schema.Mixed


userSchema = new Schema(
  firstName: String,
  lastName: String,
  username: String,
  email: String,
  createdAt: {type: Date, default: Date.now}
)

module.exports = mongoose.model('User', userSchema)
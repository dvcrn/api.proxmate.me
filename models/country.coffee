mongoose = require('mongoose')

Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Mixed = Schema.Mixed

countrySchema = new Schema(
  title: String,
  shortHand: String
)

module.exports = mongoose.model('Country', countrySchema)
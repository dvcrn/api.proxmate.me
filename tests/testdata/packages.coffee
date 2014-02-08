test = [{
  "name": "Test Package",
  "version": 1,
  "url": "http://pandora.com",
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",
  "_id": "52e5c59e18bf010c04b0ef9e",
  "createdAt": new Date(1390790046874).getTime(),
  "routeRegex": [
    "host == 'www.pandora.com'"
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com"
  ],
  "__v": 0
}, {
  "name": "Test Package 2",
  "version": 2,
  "url": "http://google.com",
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",
  "_id": "1337",
  "createdAt": new Date(1390790046874).getTime(),
  "routeRegex": [
    "host == 'www.pandora.com'"
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com"
  ],
  "__v": 0
}]

exports.mockPackages = test
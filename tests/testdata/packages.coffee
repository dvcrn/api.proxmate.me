test = [{

  "name": "Test Package",
  "description": "Your bones don't break, mine do. That's clear. Your cells react to bacteria and viruses differently than mine. You don't get sick, I do. That's also clear. But for some reason, you and I react the exact same way to water. We swallow it too fast, we choke. We get some in our lungs, we drown. However unreal it may seem, we are connected, you and I. We're on the same curve, just on opposite ends.",
  "smallIcon": "https://proxmatedavecx.s3.amazonaws.com/service_imgs/pandora.png",
  "bigIcon": "https://proxmatedavecx.s3.amazonaws.com/service_imgs/pandora.png",
  "screenshots": [
    "https://photos-5.dropbox.com/t/0/AADLVMgInaLkelem7hb6rANO6AhzwoeigPiHy-7UpbYgmA/12/27953127/png/1024x768/3/1392375600/0/2/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202014-02-14%2018.33.25.png/owx93-1LSNjEVRAKmVnKkub6GEPBowFOXEXVlZrO4Ko"
  ]
  "pageUrl": "http://pandora.com",

  "_id": "52e5c59e18bf010c04b0ef9e",
  "requireKey": false,
  "version": 1,
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",

  "createdAt": new Date(1390790046874).getTime(),
  "routing": [
    {
      "startsWith": "",
      "contains": [
        "vevo.com",
        "vevo2.com"
      ],
      "host": ""
    }
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com",
    "foo.bar.netflix.com",
    "abc.netflix.com",
    "netflix.com",
    "*.netflix.com",
    "muh.com",
    "abc.muh.com",
    ".muh.com"
  ],
  "contentScripts": [{
    "matches": "foo\\.com\\/.*",
    "script": "Y29uc29sZS5pbmZvKCJoZWxsbyB3cm9sZCIpOw=="
  }, {
    "matches": "abc\\.com\\/.*",
    "script": "Y29uc29sZS5pbmZvKCJoZWxsbyB3cm9sZCIpOw=="
  }],
  "__v": 0
}, {
  "name": "Test Package 2",
  "description": "Your bones don't break, mine do. That's clear. Your cells react to bacteria and viruses differently than mine. You don't get sick, I do. That's also clear. But for some reason, you and I react the exact same way to water. We swallow it too fast, we choke. We get some in our lungs, we drown. However unreal it may seem, we are connected, you and I. We're on the same curve, just on opposite ends.",
  "smallIcon": "https://proxmatedavecx.s3.amazonaws.com/service_imgs/pandora.png",
  "bigIcon": "https://proxmatedavecx.s3.amazonaws.com/service_imgs/pandora.png",
  "screenshots": [
    "https://photos-5.dropbox.com/t/0/AADLVMgInaLkelem7hb6rANO6AhzwoeigPiHy-7UpbYgmA/12/27953127/png/1024x768/3/1392375600/0/2/%E3%82%B9%E3%82%AF%E3%83%AA%E3%83%BC%E3%83%B3%E3%82%B7%E3%83%A7%E3%83%83%E3%83%88%202014-02-14%2018.33.25.png/owx93-1LSNjEVRAKmVnKkub6GEPBowFOXEXVlZrO4Ko"
  ]
  "pageUrl": "http://google.com",

  "_id": "1337",
  "requireKey": true,
  "version": 2,
  "user": "52e51a98217d32e2270e211f",
  "country": "52e5c40294ed6bd4032daa49",

  "createdAt": new Date(1390790046874).getTime(),
  "routing": [
    {
      "startsWith": "http://www.beatsmusic.com",
      "contains": [],
      "host": ""
    }
  ],
  "hosts": [
    "pandora.com",
    "*.pandora.com"
  ],
  "contentScripts": [{
    "matches": "foo\\.com\\/.*",
    "script": "Y29uc29sZS5pbmZvKCJoZWxsbyB3cm9sZCIpOw=="
  }, {
    "matches": "abcd\\.com\\/.*",
    "script": "Y29uc29sZS5pbmZvKCJoZWxsbyB3cm9sZCIpOw=="
  }],
  "__v": 0
}]

exports.mockPackages = test

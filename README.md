Node application allowing to scrap torrent informations on "cpasbien" web site.
This node application expose a REST API and a command line interface to manage torrents.
The application allows to send torrents to your Synlogy download station with Synology REST API.

An IOS client is provided to exploit Node REST API.
This client use new Apple programming language (Swift)

![iOSApp](https://github.com/dtissera/cpasbien/blob/master/shots/IMG_2433_small.png)

# NodeJs
## Requirements
- [NodeJs](https://nodejs.org/) v0.10.36

## Installation
Install dependances provided in `package.json` 
Go to `node` folder
```bash
npm install
```

## Configuration
1. Go to folder: `cpasbien/node/configuration/`
2. Clone file `config-orig.json` to `config.json`
3. Customize values

> - serverPort: node Rest Api server port
> - userAgent: user agent that will be uses during scraping process
> - synoHost: IP adress of your synology NAS
> - synoPort: Port of your synology admin interface, by default 5000
> - synoAccount: Account user of your diskstation. I recommand to use your usual account name because downloads won't be visible to every users if you don't have true rights.
> - synoPasswd: Password of your syno account
> - synoDownloadDestinationFolder: Torrents will be download to your destination folder. You should use the same folder than DownloadSation to avoid permissions errors.

```json
{
	"serverPort": 8080,
	"userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.94 Safari/537.36",

	"synoHost": "192.168.1.20",
	"synoPort": 5000,
	"synoAccount": "download",
	"synoPasswd": "download",
	"synoDownloadDestinationFolder": "downloads"
}	
```

## REST API

### /api/1

- [GET    /ping](https://github.com/dtissera/cpasbien/wiki/API-:-Ping)

### /api/1/research

- [GET    /all](https://github.com/dtissera/cpasbien/wiki/Research-:-get-list-of-search)
- [GET    /:id](https://github.com/dtissera/cpasbien/wiki/Research-:-search-detail)
- [DELETE /:id](https://github.com/dtissera/cpasbien/wiki/Research-:-delete-a-search-or-a-torrent)
- [POST   /create](https://github.com/dtissera/cpasbien/wiki/Research-:-create-new-search)
- [POST   /update](https://github.com/dtissera/cpasbien/wiki/Research-:-update-existing-research)
- [POST   /disable](https://github.com/dtissera/cpasbien/wiki/Research-:-disable-one-all-torrents-from-a-search)
- [POST   /enable](https://github.com/dtissera/cpasbien/wiki/Research-:-enable-one-all-torrents-from-a-search)
- [POST   /download](https://github.com/dtissera/cpasbien/wiki/Research-:-download-all-torrents-with-state-enabled-from-a-search)

### /api/1/syno

- [GET    /check](https://github.com/dtissera/cpasbien/wiki/Syno-:-check)
- [POST   /download](https://github.com/dtissera/cpasbien/wiki/Syno-:-send-torrent-file-to-the-NAS-Download-Station)

## Command line interface

> All API web methods are available through command line interface

```bash
Usage: cpasbien [options]

  Options:

    -h, --help          output usage information
    -V, --version       output the version number
    --list              list research
    --id [value]        display search <id>
    --remove [value]    remove search <id>
    --create [value]    new search <title>
    --update [value]    update search <id>
    --disable [value]   disable torrent <id,order?>
    --enable [value]    enable torrent <id,order?>
    --download [value]  downloads missing torrents <id>
    --compactdb         compact database
```

# IOS Client
## Requirements
- xcode 6.2
- [CocoaPods](http://cocoapods.org/) 0.36.0

## Installation
Install dependances provided in `Podfile` 
Go to `ios` folder
```bash
pod install
```

## Configuration
1. Go to folder: `cpasbien/ios/`
2. Open workspace file: `cpasbien.xcworkspace`
3. Customize file: `Configuration.swift` according to your node config (server IP and port)

```
class Configuration {
    struct Consts {
        #if LOCAL
        static let serverUrl = "http://127.0.0.1:8080/api/1/"
        #else
        static let serverUrl = "http://192.168.1.20:8080/api/1/"
        #endif
    }
}
```

> Switch from LOCAL to RELEASE build by customizing your Scheme (Debug -> DebugLocal)

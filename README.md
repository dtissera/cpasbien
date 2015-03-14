Node application allowing to scrap torrent informations on "cpasbien" web site.
This node application expose a REST API and a command line interface to manage torrents.
The application allows to send torrents to your Synlogy download station with Synology REST API.

An IOS client is provided to exploit Node REST API.
This client use new Apple programming language (Swift)

# NodeJs
## Requirements
- [NodeJs](https://nodejs.org/) v0.10.36

## Installation
Install dependances provided in `package.json` 
Go to node folder
```bash
npm install
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

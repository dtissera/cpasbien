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
`GET    /ping`

> Ping the server

```
{
  "message": "Welcome"
}
```

### /api/1/research
`GET    /all`
> Get list of search

`GET    /:id`
> Get search detail

`DELETE /:id`
> Delete a search

`POST   /create`
> Create a search

`POST   /update`
> Update existing search

`POST   /disable`
> Disable one/all torrents from a search

`POST   /enable`
> Enable one/all torrents from a search

`POST   /download`
> Download all torrents with state enabled from a search

### /api/1/syno
`GET    /check`
> Check connexion with NAS Synology

`POST   /download`
> Send torrent to the NAS

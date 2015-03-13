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

**Response**
```
{
  "message": "Welcome"
}
```

### /api/1/research
`GET    /all`
> Get list of search

**Response**
```
[
  {
    "id": "BmRMxaJJFiZ0c5e8",
    "research": "arrow",
    "missingCount": 93,
    "count": 94,
    "added": "2015-02-14T16:35:40.712Z",
    "updated": "2015-03-08T10:51:31.314Z"
  },
  {
    "id": "2XIgnZ21UF8JpC2u",
    "research": "banshee",
    "missingCount": 1,
    "count": 43,
    "added": "2015-02-14T16:36:32.428Z",
    "updated": "2015-03-12T10:29:52.948Z"
  }
]
```

`GET    /:id`
> Get search detail

**Response**
```
{
  "id": "BmRMxaJJFiZ0c5e8",
  "research": "arrow",
  "missingCount": 93,
  "count": 94,
  "added": "2015-02-14T16:35:40.712Z",
  "updated": "2015-03-08T10:51:31.314Z",
  "torrents": [
    {
      "order": 0,
      "name": "Arrow S03E15 VOSTFR HDTV",
      "enabled": true,
      "fileSize": "349.2 Mo",
      "date": "2015-02-26T00:00:00.000Z",
      "url": "http://www.cpasbien.pw/telechargement/arrow-s03e15-vostfr-hdtv.torrent"
    },
    {
      "order": 1,
      "name": "Arrow S03E14 VOSTFR HDTV",
      "enabled": true,
      "fileSize": "350.3 Mo",
      "date": "2015-02-19T00:00:00.000Z",
      "url": "http://www.cpasbien.pw/telechargement/arrow-s03e14-vostfr-hdtv.torrent"
    }
  ]
}
```

`DELETE /:id`
> Delete a search

**Response**
```
{
  "id": "vGHpUPbeMM8Y1smo"
}
```

`POST   /create`
> Create a search

**Response**
```
{
  "id": "DSVQd2apJ5XfgDmH",
  "research": "superman",
  "missingCount": 3,
  "count": 3,
  "added": "2015-03-13T22:28:54.806Z",
  "updated": "2015-03-13T22:28:56.107Z",
  "torrents": [
    {
      "order": 0,
      "name": "Superman: Unbound FRENCH DVDRIP 2013",
      "enabled": true,
      "fileSize": "702.0 Mo",
      "date": "2013-04-24T00:00:00.000Z",
      "url": "http://www.cpasbien.pw/telechargement/superman-unbound-french-dvdrip-2013.torrent"
    },
    {
      "order": 1,
      "name": "Superman Returns FRENCH DVDRIP 2006",
      "enabled": true,
      "fileSize": "699.5 Mo",
      "date": "2010-10-27T00:00:00.000Z",
      "url": "http://www.cpasbien.pw/telechargement/superman-returns-french-dvdrip-2006.torrent"
    },
    {
      "order": 2,
      "name": "Superman Batman Apocalypse FRENCH DVDRIP 2010",
      "enabled": true,
      "fileSize": "708.6 Mo",
      "date": "2010-09-27T00:00:00.000Z",
      "url": "http://www.cpasbien.pw/telechargement/superman-batman-apocalypse-french-dvdrip-2010.torrent"
    }
  ]
}
```

`POST   /update`
> Update existing search

**Response**
```
```

`POST   /disable`
> Disable one/all torrents from a search

**Response**
```
```

`POST   /enable`
> Enable one/all torrents from a search

**Response**
```
```

`POST   /download`
> Download all torrents with state enabled from a search

**Response**
```
```

### /api/1/syno
`GET    /check`
> Check connexion with NAS Synology

**Response**
```
```

`POST   /download`
> Send torrent to the NAS

**Response**
```
```

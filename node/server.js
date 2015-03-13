// call the packages we need
var express = require("express");	// call express
var app = express();				// define our app using express
var bodyParser = require("body-parser");
var routerResearch = require("./routes/research");
var routerDs214play = require("./routes/ds214play");
var routerVersion = express.Router();
var util = require('util');
var config = require('./config');

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

var port = process.env.PORT || config.serverPort;        // set our port

// ROUTES FOR OUR API
// =============================================================================
var routerApi = express.Router();              // get an instance of the express Router

// middleware to use for all requests
routerApi.use(function(req, res, next) {
    // do logging
    // console.log('Something is happening.');
    next(); // make sure we go to the next routes and don't stop here
});

// test route to make sure everything is working (accessed at GET http://localhost:8080/api)
routerApi.get('/', function(req, res) {
    console.log(util.format("%s %s", req.method, req.originalUrl));
    res.json({ message: 'cpasbien API !' });   
});

routerVersion.get('/ping', function(req, res) {
    console.log(util.format("%s %s", req.method, req.originalUrl));
    res.json({ message: 'Welcome' });   
});

// REGISTER OUR ROUTES -------------------------------
app.use("/api", routerApi);
routerApi.use("/1", routerVersion);
routerVersion.use("/research", routerResearch);
routerVersion.use("/syno", routerDs214play);

// START THE SERVER
// =============================================================================
app.listen(port);
console.log('Running cpasbien server on port ' + port);

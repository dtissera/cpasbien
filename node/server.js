// call the packages we need
var express = require("express");	// call express
var util = require('util');
var when = require('when');
var bodyParser = require("body-parser");
var app = express();				// define our app using express
var routerResearch = require("./routes/research");
var routerDs214play = require("./routes/ds214play");
var routerPlex = require("./routes/plex");
var routerVersion = express.Router();
var config = require('./config');
var routeHelper = require("./routehelper");

// configure app to use bodyParser()
// this will let us get the data from a POST
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

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
routerVersion.use("/plex", routerPlex);
//console.log(util.inspect(routerVersion, {showHidden: true, depth: null}));

// READ Configuration
console.log("Loading configuration\n");
config.load().then(
	function() {
		config.print();
		console.log("");

		var port = process.env.PORT || config.serverPort;        // set our port

		// START THE SERVER
		// =============================================================================
		app.listen(port, function() {
			console.log("Loading Routes \n");
			//console.log(routerVersion.stack);
			routeHelper.print("/api/1", routerVersion);
			routeHelper.print("/api/1/research", routerResearch);
			routeHelper.print("/api/1/syno", routerDs214play);
			routeHelper.print("/api/1/plex", routerPlex);

			console.log('Running cpasbien server on port ' + port);
		});
	},
	function(error) {
		console.log(error.message);
	}
);

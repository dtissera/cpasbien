var express = require('express');
var plex = require('../plex');
var config = require('../config');
var when = require('when');
var router = express.Router();
var util = require('util');

var ErrorManager = function () {
};

ErrorManager.prototype.handleError500 = function(error, response) {
	console.error(error.stack);
	response.status(500).send({message: error.message});
} 

var errorManager = new ErrorManager();

router.route('/refresh')
	.get(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		plex.apiRefresh().then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

exports = module.exports = router;
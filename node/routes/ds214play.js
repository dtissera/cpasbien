var express = require('express');
var syno = require('../syno');
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

router.route('/check')
	.get(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		syno.login().then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/download')
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		syno.apiCreate(req.body.uri).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/list')
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));

		var path = util.format("/%s%s", config.synoDownloadDestinationFolder, req.body.path);

		syno.apiList(path).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/rename')
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));

		var path = util.format("/%s%s", config.synoDownloadDestinationFolder, req.body.path);
		var name = req.body.name;

		syno.apiRename(path, name).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/move')
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));

		var path = util.format("/%s%s", config.synoDownloadDestinationFolder, req.body.path);
		var destPath = config.synoMoveDestinationFolder;

		syno.apiMove(path, destPath).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

exports = module.exports = router;

var express = require('express');
var when = require('when');
var router = express.Router();
var dao = require("../dao");
var scraper = require("../scraper");
var util = require('util');
var api = require("../api");

var ErrorManager = function () {
};

ErrorManager.prototype.handleError500 = function(error, response) {
	console.error(error.stack);
	response.status(500).send({message: error.message});
} 

var errorManager = new ErrorManager();

router.route('/all')
	.get(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchAll().then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/:id')
	.get(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchById(req.params.id).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	})
	.delete(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchRemoveById(req.params.id, req.body.order).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route('/create')
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchCreate(req.body.title).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route("/update")
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchUpdate(req.body.id).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route("/disable")
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchChangeTorrentState(req.body.id, false, req.body.order).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route("/enable")
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchChangeTorrentState(req.body.id, true, req.body.order).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});

router.route("/download")
	.post(function(req, res) {
		console.log(util.format("%s %s", req.method, req.originalUrl));
		api.searchDownloadMissingTorrentById(req.body.id).then(
			function(result) {
				res.json(result);
			},
			function(error) {
				errorManager.handleError500(error, res);
			}
		);
	});


module.exports=router;
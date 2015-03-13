var util = require('util');
var when = require('when');
var api = require("./api");
var tools = require('./tools');

var Cmd = function() {
}

/*
 * Tools
 */

Cmd.prototype.outputHeader = function(title) {
	console.log("");
	console.log(title);
	console.log("");
}

Cmd.prototype.outputFooter = function() {
	console.log("");
}

Cmd.prototype.outputResearch = function(researchItem) {
	console.log(util.format('[%s] %s (%d torrent(s))', researchItem.id, researchItem.research, researchItem.torrents.length));
	console.log("");
	researchItem.torrents.forEach(function(torrent) {
		console.log(util.format(' %s %s: %s - %s - %s', 
            torrent.enabled ? "+" : "-", 
            tools.pad(4, torrent.order+"", " "), 
            torrent.name, torrent.date.toISOString().slice(0, 10), torrent.fileSize));
	});
}

Cmd.prototype.fail = function(err) {
	if (err instanceof Error) {
		console.log("ERROR: "+err.message);
	}
	else {
		console.log("ERROR: "+err);
	}
	// console.log(util.inspect(err, {showHidden: true, depth: null}));
	console.log(" ");
}

/*
 * For command line
 */
Cmd.prototype.searchAll = function() {
	var self = this;

	self.outputHeader("> list research");
	api.searchAll().then(
		function(result) {
			result.forEach(function(item) {
				console.log(util.format('[%s] %s %s (%d torrent(s))', 
					item.id, 
					tools.pad(4, item.missingCount+"", " "), 
					item.research, 
					item.count));
			});

			self.outputFooter();
		},
		self.fail
	).catch(function(e) {
	});
}

Cmd.prototype.searchById = function(id) {
	var self = this;

	self.outputHeader(util.format("> research [%s]", id));

	api.searchById(id).then(
		function(result) {
			self.outputResearch(result);
			self.outputFooter();
		},
		self.fail
	).catch(function(e) {
	});
}

Cmd.prototype.searchRemoveById = function(id) {
	var self = this;

	self.outputHeader(util.format("> remove research [%s]", id));

	api.searchRemoveById(id).then(
		function(result) {
			console.log("deleted");
			self.outputFooter();
		},
		self.fail
	).catch(function(e) {
	});
}

Cmd.prototype.searchCreate = function(title) {
	var self = this;

	self.outputHeader(util.format("> create research [%s]", title));

	api.searchCreate(title).then(
		function(result) {
			self.outputResearch(result);
			self.outputFooter();
		},
		self.fail
	).catch(function(e) {
	});
}

Cmd.prototype.searchUpdate = function(id) {
	var self = this;

	self.outputHeader(util.format("> update research [%s]", id));

	api.searchUpdate(id).then(
		function(result) {
			self.outputResearch(result);
			self.outputFooter();
		},
		self.fail
	).catch(function(e) {
	});
}

Cmd.prototype.compactDatabase = function() {
	var self = this;

	var msg = api.compactDatabase();
	self.outputHeader(util.format("> compact database [%s bytes]", msg.sizeBefore));
	console.log("compacting... (no callback when terminated !)");
	self.outputFooter();
}


exports = module.exports = new Cmd()
var util = require('util');
var fs = require("fs");
var mkdirp = require("mkdirp");
var Datastore = require('nedb');
var when = require('when');
var tools = require('./tools');
var SearchInfo = require("./searchinfo");

var Dao = function() {
	mkdirp.sync("db");

	this.dbfname = "db/cpasbien.db";
	// Type 2: Persistent datastore with manual loading
	this.db = new Datastore({filename: this.dbfname, autoload: true});
}

Dao.prototype.fail = function(err) {
	console.log("ERROR: "+err);
}

Dao.prototype.findAll = function() {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		self.db.find({}).sort({words: 1}).exec(function (err, docs) {
			if (err) {
				reject(new Error(err));
			}
			else {
				var all = [];
				docs.forEach(function(item){
					all.push(new SearchInfo(item))
				});
				resolve(all);
			}
		});

	});

	return promise;
}

Dao.prototype.findItem = function(searchText) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		self.db.find({ words: searchText }, function (err, docs) {
			if (err) {
				reject(new Error(err));
			}
			else {
				if (docs.length > 0) {
					resolve(new SearchInfo(docs[0]));
				}
				else {
					resolve(null);
				}
			}
		});

	});

	return promise;
}

Dao.prototype.findItemById = function(id) {
	var self = this;
	var promise = when.promise(function(resolve, reject) {
		self.db.find({_id: id}, function (err, docs) {
			if (err) {
				reject(new Error(err));
			}
			else {
				if (docs.length > 0) {
					resolve(new SearchInfo(docs[0]));
				}
				else {
					reject(new Error("not found !"));
				}
			}
		});

	});

	return promise;
}

Dao.prototype.createEmptyItem = function(searchText) {
	var self = this;

	var si = new SearchInfo(searchText);

	var promise = when.promise(function(resolve, reject) {
		self.db.insert(si.model(), function (err, newDoc) {
			if (err) {
				reject(new Error(err));
			}
			else {
				resolve(new SearchInfo(newDoc));
			}
		});

	});

	return promise;
}

Dao.prototype.updateItem = function(item) {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		item.updated = new Date();
		self.db.update({ _id: item.getId() }, item.model(), {}, function (err, numReplaced, newDoc) {
			if (err) {
				reject(new Error(err));
			}
			else {
				if (numReplaced > 0) {
					resolve({id: item.getId()});
				}
				else {
					reject(new Error("not found !"));
				}

			}
		});

	});

	return promise;
}

Dao.prototype.removeItem = function(id) {
	var self = this;

	var promise = when.promise(function(resolve, reject) {
		self.db.remove({_id: id}, {}, function (err, numRemoved) {
			if (err) {
				reject(new Error(err));
			}
			else {
				if (numRemoved > 0) {
					resolve({id: id});
				}
				else {
					reject(new Error("not found !"));
				}
			}
		});
	});
	return promise;
}

Dao.prototype.compactDatabase = function() {
	var self = this;

	var stats = fs.statSync(this.dbfname);
	var fileSizeInBytes = stats["size"];

	self.db.persistence.compactDatafile();

	return {sizeBefore: fileSizeInBytes};
}

exports = module.exports = new Dao();
